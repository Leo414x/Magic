import UIKit
import WidgetKit

enum WidgetBridge {
    private static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConfig.appGroupID)
    }
    private static var imageURL: URL? { containerURL?.appendingPathComponent("widget_mat.png") }

    /// Widget 默认渲染尺寸（systemMedium 近似像素，@2x）
    private static let widgetRenderSize = CGSize(width: 676, height: 312)

    #if !WIDGET
    private static var pendingPublish: DispatchWorkItem?

    /// App 侧：发布当前 mat 到 Widget 并触发刷新。
    /// 防抖：连续操作（换色、移动/调整图层等）只在停顿后执行一次，避免每次都同步渲染卡顿。
    static func publish(document: MatDocument) {
        pendingPublish?.cancel()
        let work = DispatchWorkItem { publishNow(document: document) }
        pendingPublish = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }

    private static func publishNow(document: MatDocument) {
        let mat = MatRenderCache.shared.image(
            styleID: document.styleID, themeID: document.themeID, size: widgetRenderSize
        )
        let composed = StickerCompositor.composite(
            matImage: mat, stickers: document.stickers, size: widgetRenderSize
        )
        guard let data = composed.pngData(), let url = imageURL else { return }
        try? data.write(to: url)
        WidgetCenter.shared.reloadAllTimelines()
    }
    #endif

    /// Widget 侧：读取
    static func readSnapshot() -> UIImage? {
        guard let url = imageURL, let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

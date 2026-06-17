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
    /// App 侧：发布当前 mat 到 Widget 并触发刷新
    static func publish(document: MatDocument) {
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

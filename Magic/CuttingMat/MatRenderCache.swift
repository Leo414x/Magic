import UIKit

/// 渲染缓存。key = styleID + themeID + size，避免重复渲染同一配置。
/// 与 SwiftData Model 解耦，不依赖 @Transient。
final class MatRenderCache {
    static let shared = MatRenderCache()
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "mat.render.cache")

    private func key(styleID: String, themeID: String, size: CGSize) -> String {
        "\(styleID)_\(themeID)_\(Int(size.width))x\(Int(size.height))"
    }

    func image(styleID: String, themeID: String, size: CGSize) -> UIImage {
        let k = key(styleID: styleID, themeID: themeID, size: size)
        if let hit = queue.sync(execute: { cache[k] }) { return hit }
        let theme = MatTheme.preset(id: themeID)
        let img = MatRenderer.render(size: size, styleID: styleID, colorScheme: theme.colorScheme)
        queue.sync { cache[k] = img }
        return img
    }

    func invalidate(themeID: String) {
        queue.sync { cache = cache.filter { !$0.key.contains("_\(themeID)_") } }
    }
}

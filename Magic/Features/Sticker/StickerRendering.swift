import UIKit

/// 把 StickerItem 的原图 + 纸边参数渲染成最终展示图（带缓存）。
/// 画布显示与 Widget 合成共用，保证两处效果一致。
enum StickerRendering {
    private static let cache = NSCache<NSString, UIImage>()

    static func styled(for sticker: StickerItem) -> UIImage {
        guard let base = UIImage(data: sticker.imageData) else { return UIImage() }
        // 文字 sticker 的 imageData 已含背景+文字，直接用；纸边仅对照片 sticker
        if sticker.isText { return base }
        guard sticker.edgeStyle != .none, sticker.edgeWidth > 0, base.size.width > 0 else { return base }

        let key = "\(sticker.id)_\(sticker.edgeStyleRaw)_\(sticker.edgeColorHex)_\(sticker.edgeWidth)" as NSString
        if let hit = cache.object(forKey: key) { return hit }

        let widthPx = CGFloat(sticker.edgeWidth) * base.size.width
        let img = PaperEdge.apply(to: base,
                                  style: sticker.edgeStyle,
                                  color: UIColor(hex: sticker.edgeColorHex),
                                  widthPx: widthPx)
        cache.setObject(img, forKey: key)
        return img
    }
}

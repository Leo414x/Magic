import UIKit

/// 把 sticker 合成到一张 mat 图上（用于 Widget 快照）。
/// 坐标规则与 StickerCanvasView 完全一致：位置归一化×尺寸，基准宽 = 宽×0.33，绕中心旋转。
/// 仅主 App 使用（依赖 StickerItem），不属于 Widget target。
enum StickerCompositor {
    static func composite(matImage: UIImage, stickers: [StickerItem], size: CGSize) -> UIImage {
        guard !stickers.isEmpty else { return matImage }
        let baseWidth = size.width * 0.33
        return UIGraphicsImageRenderer(size: size).image { ctx in
            matImage.draw(in: CGRect(origin: .zero, size: size))
            let cg = ctx.cgContext
            for s in stickers.sorted(by: { $0.zIndex < $1.zIndex }) {
                let img = StickerRendering.styled(for: s)
                guard img.size.width > 0 else { continue }
                let w = baseWidth * CGFloat(s.scale)
                let h = w * (img.size.height / img.size.width)
                cg.saveGState()
                cg.translateBy(x: CGFloat(s.posX) * size.width, y: CGFloat(s.posY) * size.height)
                cg.rotate(by: CGFloat(s.rotation))
                img.draw(in: CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
                cg.restoreGState()
            }
        }
    }
}

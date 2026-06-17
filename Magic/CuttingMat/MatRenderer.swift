import UIKit

/// 纯函数渲染器：根据 styleID 取对应风格的 Layer 组，逐层绘制。
enum MatRenderer {
    static func render(size: CGSize, styleID: String, colorScheme: MatColorScheme) -> UIImage {
        let style = MatStyleRegistry.style(id: styleID)
        let geo = MatGeometry(canvasSize: size)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let c = ctx.cgContext
            // 风格可选的整画布裁剪（网格风格返回圆角矩形）。在层循环外设置，
            // 因而能跨每层的 save/restore 持续生效。
            if let clip = style.clipPath(for: geo) {
                c.addPath(clip.cgPath); c.clip()
            }
            for layer in style.layers {
                c.saveGState()
                layer.draw(in: c, geometry: geo, colors: colorScheme)
                c.restoreGState()
            }
        }
    }
}

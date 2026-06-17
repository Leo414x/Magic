import UIKit

/// 网格 cutting mat 风格：重构前写死在 renderer 里的那组 Layer。
struct GridMatStyle: MatStyle {
    let id = "grid"
    var aspectRatio: CGFloat { SharedLayoutTokens.aspectRatio }
    var layers: [MatLayer] {
        [BackgroundLayer(), VignetteLayer(), GridLayer(),
         BorderLayer(), TickLayer(), ArcLayer(), NumberLayer()]
    }

    /// 圆角矩形裁剪，使 R10/R20 完整圆弧被 mat 圆角裁切（保持重构前视觉）。
    func clipPath(for g: MatGeometry) -> UIBezierPath? {
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: g.canvasSize),
                     cornerRadius: g.cornerRadius)
    }
}

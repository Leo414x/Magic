import UIKit
struct VignetteLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        ctx.setFillColor(colors.vignette.withAlphaComponent(GridStyleTokens.Opacity.vignette).cgColor)
        ctx.fill(CGRect(origin: .zero, size: g.canvasSize))
    }
}

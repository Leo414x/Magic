import UIKit
struct BorderLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let rect = CGRect(origin: g.gridOrigin, size: g.gridSize)
        colors.grid.withAlphaComponent(GridStyleTokens.Opacity.border).setStroke()
        let p = UIBezierPath(rect: rect)
        p.lineWidth = g.scaled(GridStyleTokens.Stroke.border)
        p.stroke()
    }
}

import UIKit
struct BackgroundLayer: MatLayer {
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let rect = CGRect(origin: .zero, size: g.canvasSize)
        let clip = UIBezierPath(roundedRect: rect, cornerRadius: g.cornerRadius)
        ctx.addPath(clip.cgPath); ctx.clip()
        ctx.setFillColor(colors.base.cgColor); ctx.fill(rect)
    }
}

import UIKit
struct ArcLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        // 仅截断弧线下方：不超过最底部水平线（gridEnd.y）。
        // 上方与左右维持原样（由 GridMatStyle 的圆角矩形全局裁切控制）。
        // renderer 已为每层 save/restore，此 clip 仅作用本层。
        ctx.clip(to: CGRect(x: 0, y: 0, width: g.canvasSize.width, height: g.gridEnd.y))
        let cx = g.gridOrigin.x + g.stepX * T.Arc.centerOffsetXFactor
        let cy = g.gridEnd.y + g.stepY * T.Arc.centerOffsetYFactor
        let r10 = g.stepX * T.Arc.r10RadiusFactor
        let r20 = g.stepX * T.Arc.r20RadiusFactor
        let lw = g.scaled(T.Stroke.arc)
        func ring(_ r: CGFloat, _ op: CGFloat) {
            let p = UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: r,
                                 startAngle: 0, endAngle: .pi*2, clockwise: true)
            colors.arc.withAlphaComponent(op).setStroke(); p.lineWidth = lw; p.stroke()
        }
        ring(r10, T.Opacity.r10Arc)
        ring(r20, T.Opacity.r20Arc)
    }
}

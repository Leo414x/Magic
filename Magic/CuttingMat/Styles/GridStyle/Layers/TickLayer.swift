import UIKit
struct TickLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self
        let c = colors.grid.withAlphaComponent(T.Opacity.tick); c.setFill()
        for i in 0...G.columns {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            let major = i % G.majorColumnInterval == 0
            let len = g.scaled(major ? T.Tick.majorLength : T.Tick.minorLength)
            let th = g.scaled(major ? T.Stroke.majorTick : T.Stroke.minorTick)
            ctx.fill(CGRect(x: x - th/2, y: g.gridOrigin.y - len, width: th, height: len))
            ctx.fill(CGRect(x: x - th/2, y: g.gridEnd.y, width: th, height: len))
        }
        for j in 0...G.rows {
            let y = g.gridOrigin.y + CGFloat(j) * g.stepY
            let major = j % G.majorRowInterval == 0
            let len = g.scaled(major ? T.Tick.majorLength : T.Tick.minorLength)
            let th = g.scaled(major ? T.Stroke.majorTick : T.Stroke.minorTick)
            ctx.fill(CGRect(x: g.gridOrigin.x - len, y: y - th/2, width: len, height: th))
            ctx.fill(CGRect(x: g.gridEnd.x, y: y - th/2, width: len, height: th))
        }
    }
}

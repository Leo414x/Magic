import UIKit
struct GridLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self

        // ===== 竖线：col 1..19（col0/col20 由外框承担，不在此绘制）=====
        // 次（暗）线
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.minorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.minorGrid))
        for i in 1..<G.columns where i % G.majorColumnInterval != G.majorColumnPhase {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            ctx.move(to: CGPoint(x: x, y: g.gridOrigin.y)); ctx.addLine(to: CGPoint(x: x, y: g.gridEnd.y))
        }
        ctx.strokePath()
        // 主（亮）线：col 4,9,14,19（与数字标签列对齐）
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.majorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.majorGrid))
        for i in stride(from: G.majorColumnPhase, to: G.columns, by: G.majorColumnInterval) {
            let x = g.gridOrigin.x + CGFloat(i) * g.stepX
            ctx.move(to: CGPoint(x: x, y: g.gridOrigin.y)); ctx.addLine(to: CGPoint(x: x, y: g.gridEnd.y))
        }
        ctx.strokePath()

        // ===== 横线：row 1..7（row0/row8 由外框承担，不在此绘制）=====
        // 次（暗）线
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.minorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.minorGrid))
        for j in 1..<G.rows where j != G.majorRowLine {
            let y = g.gridOrigin.y + CGFloat(j) * g.stepY
            ctx.move(to: CGPoint(x: g.gridOrigin.x, y: y)); ctx.addLine(to: CGPoint(x: g.gridEnd.x, y: y))
        }
        ctx.strokePath()
        // 主（亮）线：仅中线 row 4
        ctx.setStrokeColor(colors.grid.withAlphaComponent(T.Opacity.majorGrid).cgColor)
        ctx.setLineWidth(g.scaled(T.Stroke.majorGrid))
        let yMid = g.gridOrigin.y + CGFloat(G.majorRowLine) * g.stepY
        ctx.move(to: CGPoint(x: g.gridOrigin.x, y: yMid)); ctx.addLine(to: CGPoint(x: g.gridEnd.x, y: yMid))
        ctx.strokePath()
    }
}

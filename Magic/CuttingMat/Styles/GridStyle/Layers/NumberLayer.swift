import UIKit
struct NumberLayer: MatLayer {
    private typealias T = GridStyleTokens
    func draw(in ctx: CGContext, geometry g: MatGeometry, colors: MatColorScheme) {
        let G = T.Grid.self, N = T.Number.self
        let fs = g.scaled(N.fontSize)
        // Figma 设计字体为 Roboto Mono Regular；未打包字体时用系统等宽字体兜底（SF Mono）。
        let font = UIFont(name: "RobotoMono-Regular", size: fs)
            ?? .monospacedSystemFont(ofSize: fs, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: colors.grid.withAlphaComponent(T.Opacity.numberLabel)
        ]
        let topY = g.gridOrigin.y + g.scaled(N.topY)
        let botY = g.gridEnd.y + g.scaled(N.bottomY)
        // 数字 5/10/15/20 居中在主亮线列 col 4,9,14,19（与 GridLayer 主竖线对齐）
        for col in stride(from: G.majorColumnPhase, to: G.columns, by: G.majorColumnInterval) {
            let n = col + 1   // 4→5, 9→10, 14→15, 19→20
            let x = g.gridOrigin.x + CGFloat(col) * g.stepX
            let t = "\(n)" as NSString
            let sz = t.size(withAttributes: attrs)
            t.draw(at: CGPoint(x: x - sz.width/2, y: topY), withAttributes: attrs)
            t.draw(at: CGPoint(x: x - sz.width/2, y: botY), withAttributes: attrs)
        }
        let leftX = g.gridOrigin.x + g.scaled(N.leftX)
        let rightX = g.gridEnd.x + g.scaled(N.rightX)
        for row in stride(from: G.majorRowInterval, to: G.rows, by: G.majorRowInterval) {
            let y = g.gridOrigin.y + CGFloat(row) * g.stepY
            let t = (row == 4 ? "5" : "\(row)") as NSString
            let sz = t.size(withAttributes: attrs)
            t.draw(at: CGPoint(x: leftX, y: y - sz.height/2), withAttributes: attrs)
            t.draw(at: CGPoint(x: rightX, y: y - sz.height/2), withAttributes: attrs)
        }
        let r10Attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: colors.grid.withAlphaComponent(T.Opacity.r10Label)
        ]
        // R10 标签贴 R10 弧线外侧，间距固定 r10LabelGap。
        // 方位由 r10LabelX/YFactor 决定，距离由弧线半径推出（弧线移动时标签自动跟随）。
        let arcCx = g.gridOrigin.x + g.stepX * T.Arc.centerOffsetXFactor
        let arcCy = g.gridEnd.y + g.stepY * T.Arc.centerOffsetYFactor
        let r10 = g.stepX * T.Arc.r10RadiusFactor
        let aimX = g.gridOrigin.x + g.stepX * N.r10LabelXFactor
        let aimY = g.gridOrigin.y + g.stepY * N.r10LabelYFactor
        let len = max(hypot(aimX - arcCx, aimY - arcCy), 0.0001)
        let ux = (aimX - arcCx) / len, uy = (aimY - arcCy) / len
        let r10Text = "R10" as NSString
        let r10Sz = r10Text.size(withAttributes: r10Attrs)
        let centerDist = r10 + g.scaled(N.r10LabelGap) + r10Sz.height / 2
        let lx = arcCx + ux * centerDist, ly = arcCy + uy * centerDist
        r10Text.draw(at: CGPoint(x: lx - r10Sz.width / 2, y: ly - r10Sz.height / 2), withAttributes: r10Attrs)
    }
}

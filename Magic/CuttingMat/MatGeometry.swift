import CoreGraphics

struct MatGeometry {
    let canvasSize: CGSize
    let scale: CGFloat
    let padding, cornerRadius: CGFloat
    let gridOrigin: CGPoint
    let gridSize: CGSize
    let gridEnd: CGPoint
    let stepX, stepY: CGFloat

    init(canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.scale = canvasSize.width / SharedLayoutTokens.referenceWidth
        self.padding = canvasSize.width * SharedLayoutTokens.paddingRatio
        self.cornerRadius = canvasSize.width * SharedLayoutTokens.cornerRadiusRatio
        let gw = canvasSize.width - padding * 2
        let gh = canvasSize.height - padding * 2
        self.gridOrigin = CGPoint(x: padding, y: padding)
        self.gridSize = CGSize(width: gw, height: gh)
        self.gridEnd = CGPoint(x: padding + gw, y: padding + gh)
        self.stepX = gw / CGFloat(GridStyleTokens.Grid.columns)
        self.stepY = gh / CGFloat(GridStyleTokens.Grid.rows)
    }
    func scaled(_ ref: CGFloat) -> CGFloat { ref * scale }
}

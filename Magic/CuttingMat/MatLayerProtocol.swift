import UIKit
protocol MatLayer {
    func draw(in context: CGContext, geometry: MatGeometry, colors: MatColorScheme)
}

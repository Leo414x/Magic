import UIKit

struct MatColorScheme: Equatable {
    let base: UIColor
    let grid: UIColor
    let arc: UIColor
    let vignette: UIColor

    /// Phase 2: 从 base 自动派生
    static func derive(from base: UIColor) -> MatColorScheme {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        base.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let isDark = b < 0.5
        let gridH = fmod(h + 0.28, 1.0)
        let gridS: CGFloat = isDark ? max(s * 0.55, 0.3) : min(s + 0.15, 0.8)
        let gridB: CGFloat = isDark ? min(b + 0.60, 0.85) : max(b - 0.35, 0.35)
        let grid = UIColor(hue: gridH, saturation: gridS, brightness: gridB, alpha: 1)
        let arc = UIColor(hue: fmod(gridH - 0.01, 1.0), saturation: gridS + 0.01,
                          brightness: gridB - 0.02, alpha: 1)
        let vignette = UIColor(hue: h, saturation: min(s + 0.1, 1.0),
                               brightness: max(b - 0.08, 0.0), alpha: 1)
        return MatColorScheme(base: base, grid: grid, arc: arc, vignette: vignette)
    }
}

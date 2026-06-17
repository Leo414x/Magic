import SwiftUI

struct MatTheme: Identifiable, Equatable {
    let id: String
    let styleID: String   // 该主题所属的风格（现有预设均为 "grid"）
    let baseHex, gridHex, arcHex, vignetteHex: String

    var colorScheme: MatColorScheme {
        MatColorScheme(
            base: UIColor(hex: baseHex), grid: UIColor(hex: gridHex),
            arc: UIColor(hex: arcHex), vignette: UIColor(hex: vignetteHex)
        )
    }
    var baseColor: Color { Color(uiColor: colorScheme.base) }
    var gridColor: Color { Color(uiColor: colorScheme.grid) }

    static func preset(id: String) -> MatTheme {
        allPresets.first { $0.id == id } ?? .defaultGreen
    }
}

extension MatTheme {
    static let defaultGreen = MatTheme(id: "green", styleID: "grid", baseHex: "#063B31", gridHex: "#C4CF5D", arcHex: "#B8C95A", vignetteHex: "#052820")
    static let pink = MatTheme(id: "pink", styleID: "grid", baseHex: "#F2C7D1", gridHex: "#8C4D5A", arcHex: "#854759", vignetteHex: "#D9AEBB")
    static let navy = MatTheme(id: "navy", styleID: "grid", baseHex: "#0F193D", gridHex: "#99B3D9", arcHex: "#8CA6CC", vignetteHex: "#0A1230")
    static let charcoal = MatTheme(id: "charcoal", styleID: "grid", baseHex: "#242426", gridHex: "#8C8C80", arcHex: "#808076", vignetteHex: "#1A1A1A")
    static let brown = MatTheme(id: "brown", styleID: "grid", baseHex: "#332114", gridHex: "#B89E66", arcHex: "#AD9461", vignetteHex: "#24170D")
    static let wine = MatTheme(id: "wine", styleID: "grid", baseHex: "#40141F", gridHex: "#C78073", arcHex: "#BA766B", vignetteHex: "#2E0A14")
    static let teal = MatTheme(id: "teal", styleID: "grid", baseHex: "#0D3338", gridHex: "#73BFAD", arcHex: "#6BB3A3", vignetteHex: "#082429")
    static let slate = MatTheme(id: "slate", styleID: "grid", baseHex: "#292E38", gridHex: "#9EADBF", arcHex: "#94A1B3", vignetteHex: "#1C2129")

    static let allPresets: [MatTheme] = [.defaultGreen, .pink, .navy, .charcoal, .brown, .wine, .teal, .slate]
}

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

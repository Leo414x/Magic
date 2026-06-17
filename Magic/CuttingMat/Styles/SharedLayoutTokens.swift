import CoreGraphics

/// 跨风格共享的画布几何常量。被 MatGeometry 使用，与具体风格无关。
/// 各风格可在自己的 MatStyle.aspectRatio 中覆盖默认比例。
enum SharedLayoutTokens {
    static let referenceWidth: CGFloat = 1280
    static let referenceHeight: CGFloat = 590
    static let paddingRatio: CGFloat = 58.0 / 1280.0
    static let cornerRadiusRatio: CGFloat = 44.0 / 1280.0
    static let aspectRatio: CGFloat = 1280.0 / 590.0
}

import UIKit

/// 一种背景风格：决定用哪组 Layer、专属设计参数与画布比例。
/// 网格版 (GridMatStyle) 是其中一种风格；未来可新增黑白版等。
protocol MatStyle {
    var id: String { get }
    var layers: [MatLayer] { get }
    var aspectRatio: CGFloat { get }

    /// 可选：绘制前对整张画布应用的裁剪路径。默认不裁剪。
    /// 网格风格返回圆角矩形，使 R10/R20 完整圆弧被 mat 圆角裁切。
    func clipPath(for geometry: MatGeometry) -> UIBezierPath?
}

extension MatStyle {
    func clipPath(for geometry: MatGeometry) -> UIBezierPath? { nil }
}

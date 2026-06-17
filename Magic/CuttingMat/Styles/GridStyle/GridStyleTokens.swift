import CoreGraphics

/// 网格风格 (GridMatStyle) 专属的绘制常量。
/// 数值与重构前的 MatDesignTokens 完全一致，未作任何修改。
enum GridStyleTokens {
    enum Grid {
        static let columns = 20
        static let rows = 8
        static let majorColumnInterval = 5
        static let majorRowInterval = 4
        /// 主（亮）竖线相位：位于 col % majorColumnInterval == majorColumnPhase，
        /// 即 col 4/9/14/19——与数字标签列对齐（匹配 Figma 11:872）。
        static let majorColumnPhase = 4
        /// 唯一的主（亮）横线：中线 row 4（顶/底由外框承担）。
        static let majorRowLine = 4
    }
    enum Stroke {
        static let minorGrid: CGFloat = 1.0
        static let majorGrid: CGFloat = 1.4
        static let border: CGFloat = 2.5
        static let arc: CGFloat = 1.5
        static let minorTick: CGFloat = 1.2
        static let majorTick: CGFloat = 1.8
    }
    enum Opacity {
        static let vignette: CGFloat = 0.18
        static let minorGrid: CGFloat = 0.18
        static let majorGrid: CGFloat = 0.80   // 明（主）线，按设计明暗分级（Figma dev 读到 0.5，以设计指定 80% 为准）
        static let border: CGFloat = 1.0
        static let tick: CGFloat = 0.72
        static let numberLabel: CGFloat = 0.85
        static let r10Arc: CGFloat = 0.62
        static let r20Arc: CGFloat = 0.56
        static let r10Label: CGFloat = 0.78
    }
    enum Tick {
        static let majorLength: CGFloat = 22
        static let minorLength: CGFloat = 14
    }
    enum Arc {
        static let r10RadiusFactor: CGFloat = 10.05
        static let r20RadiusFactor: CGFloat = 20.15
        static let centerOffsetXFactor: CGFloat = -0.15
        static let centerOffsetYFactor: CGFloat = 0.08
    }
    enum Number {
        static let fontSize: CGFloat = 18
        static let topY: CGFloat = -44
        static let bottomY: CGFloat = 20
        static let leftX: CGFloat = -48
        static let rightX: CGFloat = 24
        static let r10LabelXFactor: CGFloat = 7.23   // R10 标签方位锚点 X（决定标签在弧线哪个方位）
        static let r10LabelYFactor: CGFloat = 0.62   // R10 标签方位锚点 Y
        static let r10LabelGap: CGFloat = 2          // R10 文字到 R10 弧线的间距（px@ref）
    }
}

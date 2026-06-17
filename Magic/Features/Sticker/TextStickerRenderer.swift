import UIKit
import CoreText

/// 文字模板 sticker（橙色喷溅背景 + 可编辑手写体文字）。
enum TextStickerTemplate: String, CaseIterable, Identifiable {
    case goodVibes
    var id: String { rawValue }
    var backgroundName: String { "GoodVibesBG" }
    var defaultText: String { "good vibes no rules" }
}

/// 把模板背景 + 文字合成成 sticker 图。文字内容可编辑。
enum TextStickerRenderer {
    private static var fontRegistered = false
    static let fontName = "OleoScript-Bold"

    static func ensureFontRegistered() {
        guard !fontRegistered else { return }
        fontRegistered = true
        if let url = Bundle.main.url(forResource: "OleoScript-Bold", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func render(template: TextStickerTemplate, text: String) -> UIImage {
        ensureFontRegistered()
        guard let bg = UIImage(named: template.backgroundName) else { return UIImage() }
        return compose(background: bg, text: text, fontName: fontName)
    }

    /// 核心合成：背景图上按 Figma 参数绘制文字（205px Oleo Script Bold, #0b0506,
    /// 居中, 字距 -4, 行高 184.5, 旋转 8.29°）。坐标基于 1574×792 设计空间。
    /// 设计参考宽（Figma 容器 1574pt），用于把所有坐标按背景实际尺寸等比缩放。
    private static let referenceWidth: CGFloat = 1574

    static func compose(background bg: UIImage, text: String, fontName: String) -> UIImage {
        let size = bg.size
        let s = size.width / referenceWidth   // 分辨率无关缩放
        return UIGraphicsImageRenderer(size: size).image { ctx in
            bg.draw(in: CGRect(origin: .zero, size: size))
            let cg = ctx.cgContext

            let font = UIFont(name: fontName, size: 205 * s) ?? .systemFont(ofSize: 205 * s, weight: .heavy)
            let para = NSMutableParagraphStyle()
            para.alignment = .center
            para.maximumLineHeight = 184.5 * s
            para.minimumLineHeight = 184.5 * s
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(hex: "#0b0506"),
                .paragraphStyle: para,
                .kern: -4 * s
            ]
            let ns = text as NSString
            let boxW: CGFloat = 1063.637 * s
            let bound = ns.boundingRect(with: CGSize(width: boxW, height: .greatestFiniteMagnitude),
                                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                                        attributes: attrs, context: nil)
            let centerX = 751.69 * s
            let centerY = (203.93 + 602.131 / 2) * s

            cg.saveGState()
            cg.translateBy(x: centerX, y: centerY)
            cg.rotate(by: 8.29 * .pi / 180)
            let rect = CGRect(x: -boxW / 2, y: -bound.height / 2, width: boxW, height: bound.height)
            ns.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs, context: nil)
            cg.restoreGState()
        }
    }
}

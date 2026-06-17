import UIKit
import CoreImage

/// 纸边风格。
enum PaperEdgeStyle: String, Codable, CaseIterable, Identifiable {
    case none    // 无边
    case clean   // 均匀白边（die-cut 贴纸）
    case torn    // 细颗粒磨砂毛边
    case ripped  // 碎纸张：大起伏 + 毛刺的手撕纸边
    var id: String { rawValue }
}

/// 给透明背景的 sticker 加纸边效果。统一被画布显示与 Widget 合成使用。
enum PaperEdge {
    private static let context = CIContext()

    /// - widthPx: 边缘像素宽（相对 sticker 原始像素）。输出图四周扩大以容纳边缘，主体居中。
    static func apply(to image: UIImage, style: PaperEdgeStyle, color: UIColor, widthPx: CGFloat) -> UIImage {
        guard style != .none, widthPx >= 1 else { return image }

        // 1) 扩边画布，避免膨胀被原 extent 裁掉
        let pad = ceil(widthPx) + 4
        let paddedSize = CGSize(width: image.size.width + pad * 2, height: image.size.height + pad * 2)
        let padded = UIGraphicsImageRenderer(size: paddedSize).image { _ in
            image.draw(in: CGRect(x: pad, y: pad, width: image.size.width, height: image.size.height))
        }
        guard let cg = padded.cgImage else { return image }
        let base = CIImage(cgImage: cg)
        let extent = base.extent

        // 2) 膨胀 alpha 得到外扩轮廓
        var silhouette = base.applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: widthPx])

        // 3) 用噪声位移轮廓边缘
        if let noise = CIFilter(name: "CIRandomGenerator")?.outputImage {
            func displace(_ img: CIImage, noiseScale: CGFloat, amount: CGFloat) -> CIImage {
                let map = noise.transformed(by: CGAffineTransform(scaleX: noiseScale, y: noiseScale)).cropped(to: extent)
                return img.applyingFilter("CIDisplacementDistortion", parameters: [
                    "inputDisplacementImage": map,
                    kCIInputScaleKey: amount
                ]).cropped(to: extent)
            }
            switch style {
            case .torn:
                // 细颗粒磨砂毛边
                silhouette = displace(silhouette, noiseScale: 3, amount: widthPx)
            case .ripped:
                // 碎纸张：低频大起伏 + 高频毛刺两层
                silhouette = displace(silhouette, noiseScale: 14, amount: widthPx * 2.0)
                silhouette = displace(silhouette, noiseScale: 4, amount: widthPx * 0.7)
            default:
                break
            }
        }

        // 4) 给轮廓上色
        guard let colorFilter = CIFilter(name: "CIConstantColorGenerator",
                                         parameters: ["inputColor": CIColor(color: color)]),
              let colorImg = colorFilter.outputImage?.cropped(to: extent) else { return image }
        let edge = colorImg.applyingFilter("CISourceInCompositing",
                                           parameters: [kCIInputBackgroundImageKey: silhouette])

        // 5) 原图叠在彩色轮廓之上
        let result = base.applyingFilter("CISourceOverCompositing",
                                         parameters: [kCIInputBackgroundImageKey: edge])

        guard let out = context.createCGImage(result, from: extent) else { return image }
        return UIImage(cgImage: out, scale: image.scale, orientation: .up)
    }
}

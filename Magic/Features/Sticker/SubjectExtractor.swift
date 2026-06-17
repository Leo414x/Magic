import UIKit
import Vision
import CoreImage

/// 用 iOS 17 Vision 自动抠出照片主体（前景实例 mask）。
enum SubjectExtractor {
    enum ExtractError: Error { case noCGImage, noSubject, render }

    private static let ciContext = CIContext()

    /// 抠出主体，返回裁剪到主体范围的透明背景图。失败时抛错（调用方可回退整张图）。
    /// Vision 同步推理放到后台队列，避免阻塞主线程。
    static func extract(from image: UIImage) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let normalized = image.normalizedUp()
                    guard let cg = normalized.cgImage else { throw ExtractError.noCGImage }

                    let request = VNGenerateForegroundInstanceMaskRequest()
                    let handler = VNImageRequestHandler(cgImage: cg, options: [:])
                    try handler.perform([request])

                    guard let result = request.results?.first, !result.allInstances.isEmpty else {
                        throw ExtractError.noSubject
                    }
                    let masked = try result.generateMaskedImage(
                        ofInstances: result.allInstances,
                        from: handler,
                        croppedToInstancesExtent: true)
                    let ci = CIImage(cvPixelBuffer: masked)
                    guard let out = ciContext.createCGImage(ci, from: ci.extent) else {
                        throw ExtractError.render
                    }
                    continuation.resume(returning: UIImage(cgImage: out))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension UIImage {
    /// 将 EXIF 方向烘焙进像素，返回 .up 方向的图（Vision 需要正确方向）。
    func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// 等比缩小到最长边不超过 maxDim（用于预览，避免实时滤镜卡顿）。
    func downscaled(maxDim: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDim else { return self }
        let s = maxDim / longest
        let newSize = CGSize(width: size.width * s, height: size.height * s)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

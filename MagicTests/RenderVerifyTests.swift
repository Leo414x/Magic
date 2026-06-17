import XCTest
import UIKit
import SwiftData
@testable import Magic

final class RenderVerifyTests: XCTestCase {
    func testRenderGreenMat() throws {
        let outDir = URL(fileURLWithPath: "/Users/leo/Developer/Magic/_verify", isDirectory: true)
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

        // Full editor size (reference aspect) + thumbnail size, default green.
        let cases: [(String, CGSize, MatTheme)] = [
            ("mat_green_full", CGSize(width: 1280, height: 590), .defaultGreen),
            ("mat_green_thumb", CGSize(width: 320, height: 148), .defaultGreen),
            ("mat_pink_full", CGSize(width: 1280, height: 590), .pink),
            ("mat_navy_full", CGSize(width: 1280, height: 590), .navy)
        ]
        for (name, size, theme) in cases {
            let img = MatRenderer.render(size: size, styleID: theme.styleID, colorScheme: theme.colorScheme)
            let data = try XCTUnwrap(img.pngData())
            try data.write(to: outDir.appendingPathComponent("\(name).png"))
        }
    }

    func testCompositeSticker() throws {
        let outDir = URL(fileURLWithPath: "/Users/leo/Developer/Magic/_verify", isDirectory: true)
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

        let container = try ModelContainer(
            for: MatDocument.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let ctx = ModelContext(container)

        func solid(_ color: UIColor, _ s: CGFloat) -> Data {
            UIGraphicsImageRenderer(size: CGSize(width: s, height: s)).image { c in
                color.setFill(); c.fill(CGRect(x: 0, y: 0, width: s, height: s))
            }.pngData()!
        }

        // 透明背景蓝圆（看阴影立体感）
        func circle(_ color: UIColor) -> Data {
            UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300)).image { c in
                color.setFill()
                c.cgContext.fillEllipse(in: CGRect(x: 40, y: 40, width: 220, height: 220))
            }.pngData()!
        }
        // 中央蓝圆带白边(scale 1) + 右下橙圆(scale 0.55, 旋转 22°)
        let red = StickerItem(imageData: circle(.systemBlue), posX: 0.42, posY: 0.52, scale: 1, rotation: 0, zIndex: 0,
                              edgeStyleRaw: "clean", edgeColorHex: "#FFFFFF", edgeWidth: 0.05)
        let blue = StickerItem(imageData: circle(.systemOrange), posX: 0.66, posY: 0.64, scale: 0.55, rotation: .pi / 8, zIndex: 1)
        ctx.insert(red); ctx.insert(blue)

        let size = CGSize(width: 676, height: 312)
        let mat = MatRenderer.render(size: size, styleID: "grid", colorScheme: MatTheme.defaultGreen.colorScheme)
        let composed = StickerCompositor.composite(matImage: mat, stickers: [red, blue], size: size)
        try composed.pngData()!.write(to: outDir.appendingPathComponent("widget_composited.png"))
    }

    func testPaperEdge() throws {
        let outDir = URL(fileURLWithPath: "/Users/leo/Developer/Magic/_verify", isDirectory: true)
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        // 透明背景上的蓝色圆当主体
        let subject = UIGraphicsImageRenderer(size: CGSize(width: 220, height: 220)).image { c in
            UIColor.systemBlue.setFill()
            c.cgContext.fillEllipse(in: CGRect(x: 30, y: 30, width: 160, height: 160))
        }
        func onDark(_ img: UIImage) -> UIImage {
            UIGraphicsImageRenderer(size: img.size).image { c in
                UIColor(red: 0.024, green: 0.231, blue: 0.192, alpha: 1).setFill()
                c.fill(CGRect(origin: .zero, size: img.size))
                img.draw(at: .zero)
            }
        }
        let clean = PaperEdge.apply(to: subject, style: .clean, color: .white, widthPx: 24)
        let torn = PaperEdge.apply(to: subject, style: .torn, color: .white, widthPx: 24)
        let ripped = PaperEdge.apply(to: subject, style: .ripped, color: .white, widthPx: 24)
        try onDark(clean).pngData()!.write(to: outDir.appendingPathComponent("edge_clean.png"))
        try onDark(torn).pngData()!.write(to: outDir.appendingPathComponent("edge_torn.png"))
        try onDark(ripped).pngData()!.write(to: outDir.appendingPathComponent("edge_ripped.png"))
    }
}

import XCTest
import UIKit
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
}

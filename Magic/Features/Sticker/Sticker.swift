import Foundation
struct Sticker: Identifiable, Codable {
    let id: UUID
    var imageData: Data
    var position: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    var zIndex: Int
    var hasPaperEdge: Bool
}

import SwiftData
import Foundation

/// 收藏抽屉里的 sticker（全局，独立于具体 mat，可跨 mat 复用）。
@Model
final class SavedSticker {
    var id: UUID
    var imageData: Data
    var createdAt: Date

    init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
        self.createdAt = Date()
    }
}

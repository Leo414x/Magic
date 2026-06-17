import SwiftData
import Foundation

/// 杂志海报文档（独立于 cutting mat）。模板文字固定，用户上传人像填入椭圆槽。
@Model
final class PosterDocument {
    @Attribute(.unique) var id: UUID
    var portraitData: Data?   // 抠图后的人像主体（透明 PNG）
    var portraitScale: Double = 1      // 人像缩放倍数
    var portraitOffsetX: Double = 0    // 椭圆槽内平移（归一化相对槽宽/高）
    var portraitOffsetY: Double = 0
    var createdAt: Date
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

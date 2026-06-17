import SwiftData
import Foundation

/// 一张贴在 mat 上的 sticker。位置/缩放/旋转持久化。
/// 位置用归一化坐标（相对 mat 显示区，0~1），与渲染尺寸无关。
@Model
final class StickerItem {
    var id: UUID
    var imageData: Data
    var posX: Double        // 归一化中心 X（0~1，相对 mat）
    var posY: Double        // 归一化中心 Y
    var scale: Double        // 相对基准尺寸的缩放
    var rotation: Double     // 弧度
    var zIndex: Int
    var createdAt: Date

    // 纸边（Paper Edge）参数，默认无边
    var edgeStyleRaw: String = PaperEdgeStyle.none.rawValue
    var edgeColorHex: String = "#FFFFFF"
    var edgeWidth: Double = 0   // 相对 sticker 宽度的比例（0~~0.1）

    var edgeStyle: PaperEdgeStyle { PaperEdgeStyle(rawValue: edgeStyleRaw) ?? .none }

    init(imageData: Data,
         posX: Double = 0.5, posY: Double = 0.5,
         scale: Double = 1.0, rotation: Double = 0, zIndex: Int = 0,
         edgeStyleRaw: String = PaperEdgeStyle.none.rawValue,
         edgeColorHex: String = "#FFFFFF",
         edgeWidth: Double = 0) {
        self.id = UUID()
        self.imageData = imageData
        self.posX = posX
        self.posY = posY
        self.scale = scale
        self.rotation = rotation
        self.zIndex = zIndex
        self.createdAt = Date()
        self.edgeStyleRaw = edgeStyleRaw
        self.edgeColorHex = edgeColorHex
        self.edgeWidth = edgeWidth
    }
}

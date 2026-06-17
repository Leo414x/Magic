import SwiftData
import Foundation

@Model
final class MatDocument {
    @Attribute(.unique) var id: UUID
    var name: String
    /// 背景风格 ID（默认 "grid"，default 值供 SwiftData 轻量迁移使用）
    var styleID: String = "grid"
    var themeID: String
    var createdAt: Date
    var updatedAt: Date

    var theme: MatTheme { MatTheme.preset(id: themeID) }

    init(name: String = "my mat",
         styleID: String = "grid",
         themeID: String = MatTheme.defaultGreen.id) {
        self.id = UUID()
        self.name = name
        self.styleID = styleID
        self.themeID = themeID
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func setTheme(_ theme: MatTheme) {
        styleID = theme.styleID
        themeID = theme.id
        updatedAt = Date()
        MatRenderCache.shared.invalidate(themeID: theme.id)
    }
}

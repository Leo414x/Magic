/// 背景风格注册表。新增风格时在 `all` 中追加即可。
enum MatStyleRegistry {
    static let all: [MatStyle] = [GridMatStyle()]  // 未来追加新风格

    static func style(id: String) -> MatStyle {
        all.first { $0.id == id } ?? GridMatStyle()
    }
}

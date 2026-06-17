import CoreGraphics

/// 预设装饰贴纸（图案固定、不可编辑文字）。新增装饰只需在此加一条 + 打包对应 Asset。
enum DecorSticker: String, CaseIterable, Identifiable {
    case wow
    case hand
    case glasses

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .wow: return "StickerWOW"
        case .hand: return "StickerHand"
        case .glasses: return "StickerGlasses"
        }
    }
}

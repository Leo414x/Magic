import Foundation

enum AppConfig {
    /// 产品名（暂定，后续会更换。UI 文案全部走这里）
    static let productName = "Magic"
    static let appGroupID = "group.com.othric.magic"

    enum Feature {
        static let onboardingEnabled = false
        static let stickerEnabled = false
        static let collaborationEnabled = false
    }
}

import SwiftUI

extension View {
    /// iOS 26 用 Liquid Glass（.glassEffect），旧系统降级到半透明 Material。
    @ViewBuilder
    func liquidGlass(cornerRadius: CGFloat = 28) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

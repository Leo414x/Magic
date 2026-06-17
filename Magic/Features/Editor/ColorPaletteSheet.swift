import SwiftUI

struct ColorPaletteSheet: View {
    let currentThemeID: String
    var onSelect: (MatTheme) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String

    init(currentThemeID: String, onSelect: @escaping (MatTheme) -> Void) {
        self.currentThemeID = currentThemeID
        self.onSelect = onSelect
        _selectedID = State(initialValue: currentThemeID)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(MatTheme.allPresets) { theme in
                        let isSel = selectedID == theme.id
                        Circle()
                            .fill(theme.baseColor)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(.white, lineWidth: isSel ? 2.5 : 0))
                            .scaleEffect(isSel ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isSel)
                            .onTapGesture {
                                selectedID = theme.id
                                onSelect(theme)
                            }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16)
                Spacer()
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Mat Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}

import SwiftUI

/// 文字模板 sticker 编辑面板：输入文字 + 实时预览，确认后落地。
struct TextStickerEditorSheet: View {
    let template: TextStickerTemplate
    var onConfirm: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var previewImage = UIImage()
    @FocusState private var focused: Bool

    private let smallBackground: UIImage?

    init(template: TextStickerTemplate, initialText: String, onConfirm: @escaping (String) -> Void) {
        self.template = template
        self.onConfirm = onConfirm
        _text = State(initialValue: initialText)
        self.smallBackground = UIImage(named: template.backgroundName)?.downscaled(maxDim: 520)
    }

    private func updatePreview() {
        guard let bg = smallBackground else { return }
        let shown = text.isEmpty ? template.defaultText : text
        previewImage = TextStickerRenderer.compose(background: bg, text: shown,
                                                    fontName: TextStickerRenderer.fontName)
    }

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 36, height: 5).padding(.top, 10)

            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(Color(white: 0.45))
                Image(uiImage: previewImage).resizable().scaledToFit().padding(16)
            }
            .frame(height: 190)

            TextField("Enter text", text: $text, axis: .vertical)
                .font(.title3)
                .multilineTextAlignment(.center)
                .focused($focused)
                .lineLimit(1...3)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))

            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Text("Cancel").frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .background(.thinMaterial, in: Capsule())
                .foregroundStyle(.primary)

                Button {
                    let final = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    onConfirm(final.isEmpty ? template.defaultText : final)
                    dismiss()
                } label: {
                    Text("Add").fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .foregroundStyle(.white)
                }
                .background(MatTheme.defaultGreen.baseColor, in: Capsule())
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20).padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .liquidGlass(cornerRadius: 28)
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .onAppear {
            TextStickerRenderer.ensureFontRegistered()
            updatePreview()
        }
        .onChange(of: text) { updatePreview() }
    }
}

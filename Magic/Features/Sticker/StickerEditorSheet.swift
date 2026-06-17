import SwiftUI

/// 选图抠主体后的中间态面板：实时预览 + 选纸边风格 / 颜色 / 厚度，确认后落地。
struct StickerEditorSheet: View {
    private let previewBase: UIImage           // 缩小图，供实时预览
    var onConfirm: (PaperEdgeStyle, String, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var style: PaperEdgeStyle = .clean
    @State private var colorHex: String = "#FFFFFF"
    @State private var width: Double = 0.05

    private let presetColors = ["#FFFFFF", "#000000", "#C4CF5D", "#F2C7D1", "#0F193D", "#40141F"]

    init(image: UIImage, onConfirm: @escaping (PaperEdgeStyle, String, Double) -> Void) {
        self.previewBase = image.downscaled(maxDim: 420)
        self.onConfirm = onConfirm
    }

    private var preview: UIImage {
        let px = CGFloat(width) * previewBase.size.width
        return PaperEdge.apply(to: previewBase, style: style, color: UIColor(hex: colorHex), widthPx: px)
    }

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 36, height: 5).padding(.top, 10)

            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(Color(white: 0.45))
                Image(uiImage: preview).resizable().scaledToFit().padding(20)
            }
            .frame(height: 196)

            Picker("Edge", selection: $style) {
                Text("None").tag(PaperEdgeStyle.none)
                Text("Clean").tag(PaperEdgeStyle.clean)
                Text("Torn").tag(PaperEdgeStyle.torn)
                Text("Ripped").tag(PaperEdgeStyle.ripped)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                ForEach(presetColors, id: \.self) { hex in
                    Circle()
                        .fill(Color(uiColor: UIColor(hex: hex)))
                        .frame(width: 30, height: 30)
                        .overlay(Circle().strokeBorder(.primary.opacity(0.25), lineWidth: 1))
                        .overlay(Circle().strokeBorder(.primary, lineWidth: colorHex == hex ? 2.5 : 0))
                        .onTapGesture { colorHex = hex }
                }
            }
            .opacity(style == .none ? 0.35 : 1)
            .disabled(style == .none)

            HStack {
                Image(systemName: "circle.dashed").foregroundStyle(.secondary)
                Slider(value: $width, in: 0.01...0.12)
                Image(systemName: "circle.dashed.inset.filled").foregroundStyle(.secondary)
            }
            .opacity(style == .none ? 0.35 : 1)
            .disabled(style == .none)

            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Text("Cancel").frame(maxWidth: .infinity).padding(.vertical, 13)
                }
                .background(.thinMaterial, in: Capsule())
                .foregroundStyle(.primary)

                Button {
                    onConfirm(style, colorHex, width)
                    dismiss()
                } label: {
                    Text("Add").fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .foregroundStyle(.white)
                }
                .background(MatTheme.defaultGreen.baseColor, in: Capsule())
            }
            .padding(.top, 2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .liquidGlass(cornerRadius: 28)
        .presentationDetents([.height(540)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }
}

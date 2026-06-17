import SwiftUI

/// 叠在 mat 上的 sticker 层：渲染、选中、拖拽 / 缩放 / 旋转。
struct StickerCanvasView: View {
    let stickers: [StickerItem]
    let matSize: CGSize
    var selectedID: UUID? = nil
    var onSelect: (UUID?) -> Void = { _ in }

    var body: some View {
        ZStack {
            ForEach(stickers.sorted { $0.zIndex < $1.zIndex }) { sticker in
                StickerItemView(sticker: sticker, matSize: matSize,
                                isSelected: selectedID == sticker.id,
                                onSelect: { onSelect(sticker.id) })
            }
        }
        .frame(width: matSize.width, height: matSize.height)
        .clipped()
    }
}

private struct StickerItemView: View {
    @Bindable var sticker: StickerItem
    let matSize: CGSize
    let isSelected: Bool
    var onSelect: () -> Void

    @State private var dragOffset: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1.0
    @GestureState private var twist: Angle = .zero
    @State private var rendered = UIImage()

    private var baseWidth: CGFloat { matSize.width * 0.33 }

    /// 反映 sticker 视觉内容（非 transform）的标识；只有它变时才重新解码/渲染。
    private var renderKey: String {
        "\(sticker.imageData.count)|\(sticker.kind)|\(sticker.edgeStyleRaw)|\(sticker.edgeColorHex)|\(sticker.edgeWidth)"
    }

    var body: some View {
        let drag = DragGesture()
            .onChanged { dragOffset = $0.translation }
            .onEnded { value in
                sticker.posX += Double(value.translation.width / matSize.width)
                sticker.posY += Double(value.translation.height / matSize.height)
                dragOffset = .zero
            }
        let magnify = MagnificationGesture()
            .updating($pinch) { value, state, _ in state = value }
            .onEnded { sticker.scale *= Double($0) }
        let rotate = RotationGesture()
            .updating($twist) { value, state, _ in state = value }
            .onEnded { sticker.rotation += $0.radians }

        Image(uiImage: rendered)
            .resizable()
            .scaledToFit()
            .frame(width: baseWidth)
            .overlay {
                if isSelected {
                    Rectangle()
                        .strokeBorder(MatTheme.defaultGreen.baseColor,
                                      style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                        .padding(-4)
                }
            }
            .scaleEffect(sticker.scale * pinch)
            .rotationEffect(.radians(sticker.rotation) + twist)
            .position(x: sticker.posX * matSize.width + dragOffset.width,
                      y: sticker.posY * matSize.height + dragOffset.height)
            .onTapGesture { onSelect() }
            .gesture(drag.simultaneously(with: magnify).simultaneously(with: rotate))
            .task(id: renderKey) { rendered = StickerRendering.styled(for: sticker) }
    }
}

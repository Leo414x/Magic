import SwiftUI

/// 叠在 mat 上的 sticker 层：渲染所有 sticker，支持拖拽 / 缩放 / 旋转。
struct StickerCanvasView: View {
    let stickers: [StickerItem]
    let matSize: CGSize

    var body: some View {
        ZStack {
            ForEach(stickers.sorted { $0.zIndex < $1.zIndex }) { sticker in
                StickerItemView(sticker: sticker, matSize: matSize)
            }
        }
        .frame(width: matSize.width, height: matSize.height)
        .clipped()
    }
}

/// 单个 sticker 的显示与手势。手势进行中用临时态，结束写回 @Model（自动持久化）。
private struct StickerItemView: View {
    @Bindable var sticker: StickerItem
    let matSize: CGSize

    @State private var dragOffset: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1.0
    @GestureState private var twist: Angle = .zero

    /// sticker 基准宽度 = mat 宽的 1/3（scale=1 时）。
    private var baseWidth: CGFloat { matSize.width * 0.33 }

    var body: some View {
        let ui = StickerRendering.styled(for: sticker)
        if ui.size.width > 0 {
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

            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(width: baseWidth)
                .scaleEffect(sticker.scale * pinch)
                .rotationEffect(.radians(sticker.rotation) + twist)
                .position(x: sticker.posX * matSize.width + dragOffset.width,
                          y: sticker.posY * matSize.height + dragOffset.height)
                .gesture(drag.simultaneously(with: magnify).simultaneously(with: rotate))
        }
    }
}

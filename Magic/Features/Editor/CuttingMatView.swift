import SwiftUI

struct CuttingMatView: View {
    let styleID: String
    let themeID: String
    var stickers: [StickerItem] = []
    var selectedStickerID: UUID? = nil
    var onSelectSticker: (UUID?) -> Void = { _ in }

    var body: some View {
        GeometryReader { geo in
            let size = matSize(in: geo.size)
            ZStack {
                Image(uiImage: MatRenderCache.shared.image(
                    styleID: styleID,
                    themeID: themeID,
                    size: CGSize(width: size.width * 2, height: size.height * 2)
                ))
                .resizable()
                .frame(width: size.width, height: size.height)

                StickerCanvasView(stickers: stickers, matSize: size,
                                  selectedID: selectedStickerID, onSelect: onSelectSticker)
            }
            .frame(width: size.width, height: size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private func matSize(in available: CGSize) -> CGSize {
        let ratio = MatStyleRegistry.style(id: styleID).aspectRatio
        let maxW = available.width - 32
        let maxH = available.height
        var w = maxW; var h = w / ratio
        if h > maxH { h = maxH; w = h * ratio }
        return CGSize(width: w, height: h)
    }
}

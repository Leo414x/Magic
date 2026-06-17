import SwiftUI

struct MatThumbnailCard: View {
    let mat: MatDocument

    private var aspectRatio: CGFloat {
        MatStyleRegistry.style(id: mat.styleID).aspectRatio
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = w / aspectRatio
                Image(uiImage: thumbnail(size: CGSize(width: w * 2, height: h * 2)))
                    .resizable()
                    .frame(width: w, height: h)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .aspectRatio(aspectRatio, contentMode: .fit)

            Text(mat.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }

    /// mat 图 + 合成 sticker。读 styleID/themeID/stickers 以便编辑后自动刷新。
    private func thumbnail(size: CGSize) -> UIImage {
        let matImage = MatRenderCache.shared.image(styleID: mat.styleID, themeID: mat.themeID, size: size)
        guard !mat.stickers.isEmpty else { return matImage }
        return StickerCompositor.composite(matImage: matImage, stickers: mat.stickers, size: size)
    }
}

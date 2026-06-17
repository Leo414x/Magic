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
                Image(uiImage: MatRenderCache.shared.image(
                    styleID: mat.styleID,
                    themeID: mat.themeID,
                    size: CGSize(width: w * 2, height: h * 2)  // @2x 清晰度
                ))
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
}

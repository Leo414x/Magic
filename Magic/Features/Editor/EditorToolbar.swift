import SwiftUI

struct EditorToolbar: View {
    let baseColor: Color
    let gridColor: Color
    var onColorTap: () -> Void
    var onTextTap: () -> Void = {}
    var onAddTap: () -> Void = {}
    var onStarTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            item {
                Circle().fill(baseColor).frame(width: 26, height: 26)
                    .overlay(Circle().strokeBorder(gridColor.opacity(0.6), lineWidth: 1.5))
            } action: { onColorTap() }

            item { Text("Aa").font(.system(size: 18, weight: .medium)).foregroundStyle(.primary) } action: { onTextTap() }

            Button { onAddTap() } label: {
                Image(systemName: "plus").font(.title2.weight(.medium)).foregroundStyle(.white)
                    .frame(width: 52, height: 52).background(baseColor).clipShape(Circle())
            }.padding(.horizontal, 12)

            item { Image(systemName: "wand.and.stars").font(.system(size: 18)).foregroundStyle(.primary) } action: {}
            item { Image(systemName: "star").font(.system(size: 18)).foregroundStyle(.primary) } action: { onStarTap() }
        }
        .padding(.vertical, 12).padding(.bottom, 8)
    }

    @ViewBuilder
    private func item<C: View>(@ViewBuilder content: () -> C, action: @escaping () -> Void) -> some View {
        Button(action: action) { content().frame(width: 44, height: 44) }
            .frame(maxWidth: .infinity)
    }
}

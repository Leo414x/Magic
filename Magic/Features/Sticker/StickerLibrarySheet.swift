import SwiftUI
import SwiftData

/// 贴纸库：装饰预设(WOW…) + 文字模板(good vibes…) + 我的收藏。统一的加贴纸入口。
struct StickerLibrarySheet: View {
    @Query(sort: \SavedSticker.createdAt, order: .reverse) private var saved: [SavedSticker]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var onPickDecor: (DecorSticker) -> Void
    var onPickTextTemplate: (TextStickerTemplate) -> Void
    var onPickSaved: (SavedSticker) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section("Decals") {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(DecorSticker.allCases) { decor in
                                tile { Image(decor.assetName).resizable().scaledToFit().padding(8) }
                                    .onTapGesture { onPickDecor(decor); dismiss() }
                            }
                            ForEach(TextStickerTemplate.allCases) { template in
                                tile {
                                    ZStack {
                                        Image(template.backgroundName).resizable().scaledToFit().padding(8)
                                        Text("Aa").font(.caption2.weight(.bold))
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(.ultraThinMaterial, in: Capsule())
                                    }
                                }
                                .onTapGesture { onPickTextTemplate(template); dismiss() }
                            }
                        }
                    }

                    if !saved.isEmpty {
                        section("Saved") {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(saved) { item in
                                    if let ui = UIImage(data: item.imageData) {
                                        tile { Image(uiImage: ui).resizable().scaledToFit().padding(8) }
                                            .onTapGesture { onPickSaved(item); dismiss() }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    context.delete(item); try? context.save()
                                                } label: { Label("Delete", systemImage: "trash") }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func tile<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        content()
            .frame(height: 84)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func section<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content()
        }
    }
}

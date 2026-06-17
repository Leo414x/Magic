import SwiftUI
import SwiftData

/// 贴纸收藏抽屉：展示所有 SavedSticker，点选复用到当前 mat，长按删除收藏。
struct StickerDrawerSheet: View {
    @Query(sort: \SavedSticker.createdAt, order: .reverse) private var saved: [SavedSticker]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    var onPick: (SavedSticker) -> Void

    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

    var body: some View {
        NavigationStack {
            Group {
                if saved.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 40)).foregroundStyle(.secondary)
                        Text("No saved stickers yet").foregroundStyle(.secondary)
                        Text("Add a photo with + — it'll be saved here.")
                            .font(.footnote).foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(saved) { item in
                                if let ui = UIImage(data: item.imageData) {
                                    Image(uiImage: ui)
                                        .resizable().scaledToFit()
                                        .padding(6)
                                        .frame(width: 84, height: 84)
                                        .background(Color(uiColor: .secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .onTapGesture { onPick(item); dismiss() }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                context.delete(item)
                                                try? context.save()
                                            } label: { Label("Delete", systemImage: "trash") }
                                        }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

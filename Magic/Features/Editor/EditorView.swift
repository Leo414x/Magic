import SwiftUI
import PhotosUI
import UIKit

struct EditorView: View {
    @Bindable var document: MatDocument
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var showColorPicker = false
    @State private var showPhotoPicker = false
    @State private var showDrawer = false
    @State private var showStickerEditor = false
    @State private var editingImage: UIImage?
    @State private var pickedPhoto: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                CuttingMatView(styleID: document.styleID,
                               themeID: document.themeID,
                               stickers: document.stickers)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                EditorToolbar(
                    baseColor: document.theme.baseColor,
                    gridColor: document.theme.gridColor,
                    onColorTap: { showColorPicker = true },
                    onAddTap: { showPhotoPicker = true },
                    onStarTap: { showDrawer = true }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showColorPicker) {
            ColorPaletteSheet(currentThemeID: document.themeID) { theme in
                document.setTheme(theme)
                WidgetBridge.publish(document: document)
            }
        }
        .sheet(isPresented: $showDrawer) {
            StickerDrawerSheet { saved in addFromSaved(saved) }
        }
        .sheet(isPresented: $showStickerEditor) {
            if let img = editingImage {
                StickerEditorSheet(image: img) { style, colorHex, width in
                    commitSticker(image: img, style: style, colorHex: colorHex, width: width)
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $pickedPhoto, matching: .images)
        .onChange(of: pickedPhoto) { _, item in
            guard let item else { return }
            Task { await addSticker(from: item) }
        }
        .onDisappear {
            WidgetBridge.publish(document: document)
        }
    }

    /// 选图 → Vision 抠主体（失败回退整张图）→ 进入纸边编辑中间态。
    @MainActor
    private func addSticker(from item: PhotosPickerItem) async {
        defer { pickedPhoto = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let ui = UIImage(data: data) else { return }
        let subject = (try? await SubjectExtractor.extract(from: ui)) ?? ui
        editingImage = subject
        showStickerEditor = true
    }

    /// 中间态确认 → 用选定的纸边参数落地为 sticker + 收藏 + 刷新 Widget。
    private func commitSticker(image: UIImage, style: PaperEdgeStyle, colorHex: String, width: Double) {
        guard let png = image.pngData() else { return }
        let sticker = StickerItem(imageData: png, zIndex: document.stickers.count,
                                  edgeStyleRaw: style.rawValue, edgeColorHex: colorHex, edgeWidth: width)
        context.insert(sticker)
        document.stickers.append(sticker)
        context.insert(SavedSticker(imageData: png))   // 收藏裸主体图，便于复用
        document.updatedAt = Date()
        try? context.save()
        WidgetBridge.publish(document: document)
    }

    /// 从收藏抽屉复用一张 sticker 到当前 mat。
    private func addFromSaved(_ saved: SavedSticker) {
        let sticker = StickerItem(imageData: saved.imageData, zIndex: document.stickers.count)
        context.insert(sticker)
        document.stickers.append(sticker)
        document.updatedAt = Date()
        try? context.save()
        WidgetBridge.publish(document: document)
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3).foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.06)).clipShape(Circle())
            }
            Spacer()
            HStack(spacing: 4) {
                Text(document.name).font(.body.weight(.medium)).foregroundStyle(.primary)
                Image(systemName: "chevron.down").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "person.2.badge.plus").font(.body).foregroundStyle(.primary)
                Image(systemName: "square.and.arrow.up").font(.body).foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
    }
}

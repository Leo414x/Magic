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
    @State private var showTextEditor = false
    @State private var editingImage: UIImage?
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var selectedStickerID: UUID?
    @State private var editingTextSticker: StickerItem?

    private var selectedSticker: StickerItem? {
        guard let id = selectedStickerID else { return nil }
        return document.stickers.first { $0.id == id }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
                .onTapGesture { selectedStickerID = nil }
            VStack(spacing: 0) {
                navBar
                CuttingMatView(styleID: document.styleID,
                               themeID: document.themeID,
                               stickers: document.stickers,
                               selectedStickerID: selectedStickerID,
                               onSelectSticker: { selectedStickerID = $0 })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                EditorToolbar(
                    baseColor: document.theme.baseColor,
                    gridColor: document.theme.gridColor,
                    onColorTap: { showColorPicker = true },
                    onTextTap: { editingTextSticker = nil; showTextEditor = true },
                    onAddTap: { showPhotoPicker = true },
                    onStarTap: { showDrawer = true }
                )
            }
        }
        .overlay(alignment: .bottom) {
            if let sel = selectedSticker {
                stickerActionBar(sel).padding(.bottom, 92)
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
        .sheet(isPresented: $showTextEditor) {
            TextStickerEditorSheet(template: .goodVibes,
                                   initialText: editingTextSticker?.text ?? TextStickerTemplate.goodVibes.defaultText) { text in
                if let editing = editingTextSticker {
                    updateTextSticker(editing, text: text)
                    editingTextSticker = nil
                } else {
                    commitTextSticker(text)
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

    /// 文字模板 sticker 落地：渲染背景+文字 → 持久化 → 刷新 Widget。
    private func commitTextSticker(_ text: String) {
        let img = TextStickerRenderer.render(template: .goodVibes, text: text).downscaled(maxDim: 1000)
        guard let png = img.pngData() else { return }
        let sticker = StickerItem(imageData: png, zIndex: document.stickers.count,
                                  kind: "text", text: text,
                                  templateId: TextStickerTemplate.goodVibes.rawValue)
        context.insert(sticker)
        document.stickers.append(sticker)
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

    // MARK: - 选中 sticker 的操作

    /// 前移 / 后移一层：与相邻 zIndex 的 sticker 交换。
    private func moveSticker(_ s: StickerItem, forward: Bool) {
        let sorted = document.stickers.sorted { $0.zIndex < $1.zIndex }
        guard let i = sorted.firstIndex(where: { $0.id == s.id }) else { return }
        let j = forward ? i + 1 : i - 1
        guard sorted.indices.contains(j) else { return }
        let other = sorted[j]
        let tmp = s.zIndex; s.zIndex = other.zIndex; other.zIndex = tmp
        persist()
    }

    private func deleteSticker(_ s: StickerItem) {
        if let idx = document.stickers.firstIndex(where: { $0.id == s.id }) {
            document.stickers.remove(at: idx)
        }
        context.delete(s)
        selectedStickerID = nil
        persist()
    }

    /// 文字 sticker 二次编辑：用新文字重渲染并更新 imageData。
    private func updateTextSticker(_ s: StickerItem, text: String) {
        let img = TextStickerRenderer.render(template: .goodVibes, text: text).downscaled(maxDim: 1000)
        guard let png = img.pngData() else { return }
        s.text = text
        s.imageData = png
        persist()
    }

    private func persist() {
        document.updatedAt = Date()
        try? context.save()
        WidgetBridge.publish(document: document)
    }

    @ViewBuilder
    private func stickerActionBar(_ s: StickerItem) -> some View {
        HStack(spacing: 22) {
            actionButton("arrow.down.square", "后移") { moveSticker(s, forward: false) }
            actionButton("arrow.up.square", "前移") { moveSticker(s, forward: true) }
            if s.isText {
                actionButton("pencil", "改字") { editingTextSticker = s; showTextEditor = true }
            }
            actionButton("trash", "删除", tint: .red) { deleteSticker(s) }
        }
        .padding(.horizontal, 22).padding(.vertical, 12)
        .liquidGlass(cornerRadius: 24)
    }

    private func actionButton(_ icon: String, _ label: String, tint: Color = .primary,
                              _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 17))
                Text(label).font(.caption2)
            }
            .foregroundStyle(tint)
            .frame(minWidth: 40)
        }
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

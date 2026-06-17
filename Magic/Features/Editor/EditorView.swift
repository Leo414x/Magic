import SwiftUI
import PhotosUI

struct EditorView: View {
    @Bindable var document: MatDocument
    @Environment(\.dismiss) private var dismiss
    @State private var showColorPicker = false
    @State private var showPhotoPicker = false
    @State private var pickedPhoto: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                CuttingMatView(styleID: document.styleID, themeID: document.themeID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                EditorToolbar(
                    baseColor: document.theme.baseColor,
                    gridColor: document.theme.gridColor,
                    onColorTap: { showColorPicker = true },
                    onAddTap: { showPhotoPicker = true }
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
        .photosPicker(isPresented: $showPhotoPicker, selection: $pickedPhoto, matching: .images)
        .onDisappear {
            WidgetBridge.publish(document: document)
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

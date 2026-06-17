import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// 杂志海报编辑页：固定海报模板 + 用户上传人像(抠主体→椭圆槽，彩色)。
struct PosterEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PosterDocument.updatedAt, order: .reverse) private var posters: [PosterDocument]

    @State private var poster: PosterDocument?
    @State private var showPhoto = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var isProcessing = false
    @GestureState private var pinch: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero

    // 海报 1230×1544；人像椭圆槽 left615 top915 w500 h600（归一化）
    private let posterRatio: CGFloat = 1230.0 / 1544.0
    private let slotCenterX: CGFloat = (615.0 + 250) / 1230.0
    private let slotCenterY: CGFloat = (915.0 + 300) / 1544.0
    private let slotW: CGFloat = 500.0 / 1230.0
    private let slotH: CGFloat = 600.0 / 1544.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                canvas.frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomBar
            }
        }
        .photosPicker(isPresented: $showPhoto, selection: $pickedPhoto, matching: .images)
        .onChange(of: pickedPhoto) { _, item in
            guard let item else { return }
            Task { await setPortrait(from: item) }
        }
        .onAppear(perform: ensurePoster)
    }

    private var canvas: some View {
        GeometryReader { geo in
            let s = fit(in: geo.size)
            ZStack {
                Image("PosterMagazineBG").resizable().frame(width: s.width, height: s.height)
                slotContent(s: s)
            }
            .frame(width: s.width, height: s.height)
            .clipped()
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func slotContent(s: CGSize) -> some View {
        let sw = slotW * s.width
        let sh = slotH * s.height
        let center = CGPoint(x: slotCenterX * s.width, y: slotCenterY * s.height)
        if let poster, let data = poster.portraitData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable().scaledToFill()
                .frame(width: sw, height: sh)
                .scaleEffect(poster.portraitScale * pinch)
                .offset(x: poster.portraitOffsetX * sw + dragOffset.width,
                        y: poster.portraitOffsetY * sh + dragOffset.height)
                .frame(width: sw, height: sh)
                .clipShape(Ellipse())
                .position(center)
                .gesture(portraitGesture(sw: sw, sh: sh))
        } else {
            ZStack {
                Ellipse().strokeBorder(Color.black.opacity(0.28),
                                       style: StrokeStyle(lineWidth: 3, dash: [10, 8]))
                Text("Place cutout\nphoto here")
                    .font(.system(size: max(sw * 0.06, 12), weight: .bold))
                    .foregroundStyle(.black.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            .frame(width: sw, height: sh)
            .position(center)
        }
    }

    private func portraitGesture(sw: CGFloat, sh: CGFloat) -> some Gesture {
        let drag = DragGesture()
            .onChanged { dragOffset = $0.translation }
            .onEnded { value in
                poster?.portraitOffsetX += Double(value.translation.width / sw)
                poster?.portraitOffsetY += Double(value.translation.height / sh)
                dragOffset = .zero
                persist()
            }
        let magnify = MagnificationGesture()
            .updating($pinch) { value, state, _ in state = value }
            .onEnded { poster?.portraitScale *= Double($0); persist() }
        return drag.simultaneously(with: magnify)
    }

    private func persist() {
        poster?.updatedAt = Date()
        try? context.save()
    }

    private func fit(in available: CGSize) -> CGSize {
        var w = available.width
        var h = w / posterRatio
        if h > available.height { h = available.height; w = h * posterRatio }
        return CGSize(width: w, height: h)
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.title3).foregroundStyle(.white)
                    .frame(width: 36, height: 36).background(.white.opacity(0.15)).clipShape(Circle())
            }
            Spacer()
            Text("Magazine Poster").font(.body.weight(.medium)).foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 12)
    }

    private var bottomBar: some View {
        Button { showPhoto = true } label: {
            HStack(spacing: 8) {
                if isProcessing { ProgressView().tint(.white) }
                else { Image(systemName: "person.crop.circle") }
                Text(poster?.portraitData == nil ? "Upload Portrait" : "Replace Portrait").fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(MatTheme.defaultGreen.baseColor, in: Capsule())
        }
        .disabled(isProcessing)
        .padding(.horizontal, 24).padding(.bottom, 16)
    }

    private func ensurePoster() {
        guard poster == nil else { return }
        if let existing = posters.first { poster = existing }
        else {
            let p = PosterDocument()
            context.insert(p)
            try? context.save()
            poster = p
        }
    }

    @MainActor
    private func setPortrait(from item: PhotosPickerItem) async {
        defer { pickedPhoto = nil }
        isProcessing = true
        defer { isProcessing = false }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let ui = UIImage(data: data) else { return }
        let subject = (try? await SubjectExtractor.extract(from: ui)) ?? ui
        poster?.portraitData = subject.downscaled(maxDim: 1200).pngData()
        poster?.updatedAt = Date()
        try? context.save()
    }
}

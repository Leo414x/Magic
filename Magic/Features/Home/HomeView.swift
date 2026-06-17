import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \MatDocument.updatedAt, order: .reverse) private var mats: [MatDocument]
    @State private var path: [MatDocument] = []
    @State private var showPoster = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.white.ignoresSafeArea()

                if mats.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(mats) { mat in
                                MatThumbnailCard(mat: mat)
                                    .onTapGesture { path.append(mat) }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(AppConfig.productName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showPoster = true } label: {
                        Image(systemName: "doc.richtext")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { createAndOpen() } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: MatDocument.self) { mat in
                EditorView(document: mat)
            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $showPoster) {
            PosterEditorView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48)).foregroundStyle(.secondary.opacity(0.6))
            Text("No mats yet").foregroundStyle(.secondary)
            Button { createAndOpen() } label: {
                Text("Create your first mat")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(MatTheme.defaultGreen.baseColor)
                    .clipShape(Capsule())
            }
        }
    }

    private func createAndOpen() {
        let mat = MatStore.createMat(context: context)
        path.append(mat)
    }
}

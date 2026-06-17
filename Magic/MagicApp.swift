import SwiftUI
import SwiftData

@main
struct MagicApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [MatDocument.self, SavedSticker.self, PosterDocument.self])
    }
}

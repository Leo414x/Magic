import WidgetKit
import SwiftUI

struct MagicEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

struct MagicProvider: TimelineProvider {
    func placeholder(in c: Context) -> MagicEntry { MagicEntry(date: .now, image: nil) }
    func getSnapshot(in c: Context, completion: @escaping (MagicEntry) -> Void) {
        completion(MagicEntry(date: .now, image: WidgetBridge.readSnapshot()))
    }
    func getTimeline(in c: Context, completion: @escaping (Timeline<MagicEntry>) -> Void) {
        let entry = MagicEntry(date: .now, image: WidgetBridge.readSnapshot())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct MagicWidgetView: View {
    let entry: MagicEntry

    private var uiImage: UIImage {
        entry.image ?? MatRenderer.render(
            size: CGSize(width: 676, height: 312),
            styleID: "grid",
            colorScheme: MatTheme.defaultGreen.colorScheme)
    }

    var body: some View {
        // mat 图作为 widget 背景铺满整个 widget（含系统默认 content margin 区域），
        // 由 widget 系统圆角裁切，避免 margin 处露出黑边（修复左右黑边）。
        Color.clear
            .containerBackground(for: .widget) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
    }
}

struct MagicWidget: Widget {
    let kind = "MagicWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MagicProvider()) { entry in
            MagicWidgetView(entry: entry)
        }
        .configurationDisplayName(AppConfig.productName)
        .description("Your mat on your home screen")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

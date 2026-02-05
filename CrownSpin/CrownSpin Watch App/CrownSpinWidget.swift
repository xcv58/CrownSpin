import WidgetKit
import SwiftUI

/// Widget configuration for CrownSpin complications
struct CrownSpinWidget: Widget {
    let kind: String = "CrownSpinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CrownSpinTimelineProvider()) { entry in
            CrownSpinWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("CrownSpin")
        .description("Quick launch the fidget app")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

/// Timeline entry for the widget
struct CrownSpinEntry: TimelineEntry {
    let date: Date
}

/// Timeline provider for static widget
struct CrownSpinTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CrownSpinEntry {
        CrownSpinEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CrownSpinEntry) -> Void) {
        completion(CrownSpinEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CrownSpinEntry>) -> Void) {
        let entry = CrownSpinEntry(date: Date())
        // Static widget, no updates needed
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

/// Widget view for different complication families
struct CrownSpinWidgetEntryView: View {
    var entry: CrownSpinEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "crown")
                    .font(.system(size: 20, weight: .medium))
            }

        case .accessoryCorner:
            Image(systemName: "crown")
                .font(.system(size: 20, weight: .medium))
                .widgetLabel {
                    Text("Spin")
                }

        case .accessoryInline:
            Label("CrownSpin", systemImage: "crown")

        case .accessoryRectangular:
            HStack {
                Image(systemName: "crown")
                    .font(.system(size: 24, weight: .medium))
                VStack(alignment: .leading) {
                    Text("CrownSpin")
                        .font(.headline)
                    Text("Tap to fidget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

        @unknown default:
            Image(systemName: "crown")
        }
    }
}

#Preview(as: .accessoryCircular) {
    CrownSpinWidget()
} timeline: {
    CrownSpinEntry(date: Date())
}

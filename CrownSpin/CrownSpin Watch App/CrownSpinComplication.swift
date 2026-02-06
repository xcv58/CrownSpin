import WidgetKit
import SwiftUI

/// Timeline entry for the complication
struct CrownSpinEntry: TimelineEntry {
    let date: Date
    let totalHaptics: Int
    let currentPattern: String
    let patternIcon: String
}

/// Provider for complication timeline
struct CrownSpinProvider: TimelineProvider {
    func placeholder(in context: Context) -> CrownSpinEntry {
        CrownSpinEntry(date: Date(), totalHaptics: 0, currentPattern: "Clicks", patternIcon: "hand.tap")
    }

    func getSnapshot(in context: Context, completion: @escaping (CrownSpinEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CrownSpinEntry>) -> Void) {
        let entry = createEntry()
        // Update every hour or when app updates
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry() -> CrownSpinEntry {
        let totalHaptics = UserDefaults.standard.integer(forKey: "stats.totalHaptics")
        let patternRaw = UserDefaults.standard.string(forKey: "selectedHapticPattern") ?? "clicks"
        let pattern = HapticPattern(rawValue: patternRaw) ?? .clicks

        return CrownSpinEntry(
            date: Date(),
            totalHaptics: totalHaptics,
            currentPattern: pattern.displayName,
            patternIcon: pattern.icon
        )
    }
}

/// Complication views
struct CrownSpinComplicationEntryView: View {
    var entry: CrownSpinEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryCorner:
            cornerView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: entry.patternIcon)
                    .font(.system(size: 16))
                Text(formatNumber(entry.totalHaptics))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
        }
    }

    private var rectangularView: some View {
        HStack {
            Image(systemName: entry.patternIcon)
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text("CrownSpin")
                    .font(.system(size: 12, weight: .semibold))
                Text("\(formatNumber(entry.totalHaptics)) haptics")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    private var cornerView: some View {
        ZStack {
            Image(systemName: entry.patternIcon)
                .font(.system(size: 20))
        }
        .widgetLabel {
            Text(formatNumber(entry.totalHaptics))
        }
    }

    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.patternIcon)
            Text("\(formatNumber(entry.totalHaptics)) haptics")
        }
    }

    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            return String(format: "%.1fM", Double(num) / 1_000_000)
        } else if num >= 1_000 {
            return String(format: "%.1fK", Double(num) / 1_000)
        }
        return "\(num)"
    }
}

/// The complication widget
/// NOTE: To use this, create a Widget Extension target in Xcode and move this file there
struct CrownSpinComplication: Widget {
    let kind: String = "CrownSpinComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CrownSpinProvider()) { entry in
            CrownSpinComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("CrownSpin")
        .description("Quick access to CrownSpin and view your haptic stats.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

#Preview(as: .accessoryCircular) {
    CrownSpinComplication()
} timeline: {
    CrownSpinEntry(date: Date(), totalHaptics: 1234, currentPattern: "Clicks", patternIcon: "hand.tap")
}

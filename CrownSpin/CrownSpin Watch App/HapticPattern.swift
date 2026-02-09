import WatchKit

/// App Group suite name for sharing data with the complication widget extension
let appGroupSuiteName = "group.com.xcv58.crownspin.watchapp"

/// Defines haptic feedback patterns for the Crown Spin fidget experience
enum HapticPattern: String, CaseIterable, Identifiable {
    // Basic patterns
    case clicks
    case soft
    case heavy

    // Texture patterns
    case buzz
    case ping
    case thud
    case drift
    case pulse

    // Rhythm patterns
    case heartbeat
    case doubleTap
    case gallop
    case waltz
    case staccato
    case wave
    case random

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .clicks: return "Clicks"
        case .soft: return "Soft"
        case .heavy: return "Heavy"
        case .buzz: return "Buzz"
        case .ping: return "Ping"
        case .thud: return "Thud"
        case .drift: return "Drift"
        case .pulse: return "Pulse"
        case .heartbeat: return "Heartbeat"
        case .doubleTap: return "Double Tap"
        case .gallop: return "Gallop"
        case .waltz: return "Waltz"
        case .staccato: return "Staccato"
        case .wave: return "Wave"
        case .random: return "Random"
        }
    }

    var icon: String {
        switch self {
        case .clicks: return "hand.tap"
        case .soft: return "cloud"
        case .heavy: return "hammer"
        case .buzz: return "antenna.radiowaves.left.and.right"
        case .ping: return "checkmark.circle"
        case .thud: return "xmark.circle"
        case .drift: return "leaf.arrow.triangle.circlepath"
        case .pulse: return "dot.radiowaves.right"
        case .heartbeat: return "heart"
        case .doubleTap: return "hand.tap.fill"
        case .gallop: return "hare"
        case .waltz: return "figure.dance"
        case .staccato: return "bolt"
        case .wave: return "water.waves"
        case .random: return "dice"
        }
    }

    /// Primary haptic type for basic patterns
    var primaryHaptic: WKHapticType {
        switch self {
        case .clicks: return .click
        case .soft: return .directionUp
        case .heavy: return .notification
        case .buzz: return .retry
        case .ping: return .success
        case .thud: return .failure
        case .drift: return .directionDown
        case .pulse: return .stop
        case .heartbeat: return .start
        case .doubleTap: return .click
        case .gallop: return .click
        case .waltz: return .click
        case .staccato: return .click
        case .wave: return .directionUp
        case .random: return .click
        }
    }

    /// All patterns except random (for random mode selection)
    static var nonRandomPatterns: [HapticPattern] {
        allCases.filter { $0 != .random }
    }
}

/// Formats a haptic count for display (e.g. 1500 → "1.5K", 2000000 → "2.0M")
func formatHapticNumber(_ num: Int) -> String {
    if num >= 1_000_000 {
        return String(format: "%.1fM", Double(num) / 1_000_000)
    } else if num >= 1_000 {
        return String(format: "%.1fK", Double(num) / 1_000)
    }
    return "\(num)"
}

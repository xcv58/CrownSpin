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

/// Formats a large number compactly: 1500 → "1.5K", 2000000 → "2.0M", 1B → "1.0B"
/// Thresholds use rounding-safe boundaries to avoid "1000.0X" display artifacts.
private func formatCompact(_ value: Int) -> String {
    let d = Double(value)
    if value >= 999_950_000_000 {
        return String(format: "%.1fT", d / 1_000_000_000_000)
    } else if value >= 999_950_000 {
        return String(format: "%.1fB", d / 1_000_000_000)
    } else if value >= 999_950 {
        return String(format: "%.1fM", d / 1_000_000)
    } else if value >= 1_000 {
        return String(format: "%.1fK", d / 1_000)
    }
    return "\(value)"
}

/// Formats a haptic count for display (e.g. 1500 → "1.5K", 2000000 → "2.0M")
func formatHapticNumber(_ num: Int) -> String {
    formatCompact(num)
}

/// Formats a duration in seconds for display (e.g. 45 → "45s", 3723 → "1h 2m", 7200 → "2h 0m")
func formatDuration(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    if total < 60 {
        return "\(total)s"
    }
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
}

/// Formats an item number for compact display, handling large/negative values
/// e.g. 42 → "42", 12500 → "12.5K", -1500000 → "-1.5M"
func formatItemNumber(_ num: Int) -> String {
    // Guard against Int.min where abs() would overflow
    guard num != Int.min else { return "-9.2E" }
    let magnitude = abs(num)
    let sign = num < 0 ? "-" : ""
    let formatted = formatCompact(magnitude)
    if magnitude >= 10_000 {
        return sign + formatted
    }
    return "\(num)"
}

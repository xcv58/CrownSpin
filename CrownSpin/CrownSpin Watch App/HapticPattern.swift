import WatchKit

/// Defines haptic feedback patterns for the Crown Spin fidget experience
enum HapticPattern: String, CaseIterable, Identifiable {
    // Basic patterns
    case clicks
    case soft
    case heavy

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

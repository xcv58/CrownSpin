import WatchKit

/// App Group suite name for sharing data with the complication widget extension
let appGroupSuiteName = "group.media.jenny.crownspin.watchapp"

/// Defines haptic feedback patterns for the Crown Spin fidget experience
enum HapticPattern: String, CaseIterable, Identifiable {
    case clicks
    case ping
    case soft
    case drift
    case pulse
    case wave
    case doubleTap
    case gallop
    case heartbeat
    case staccato
    case waltz
    case buzz
    case heavy
    case thud
    case random

    var id: String { rawValue }

    enum Category: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case motion = "Motion"
        case rhythms = "Rhythms"
        case strong = "Strong"
        case special = "Special"

        var id: String { rawValue }

        var patterns: [HapticPattern] {
            switch self {
            case .basic:
                return [.clicks, .ping, .soft]
            case .motion:
                return [.drift, .pulse, .wave]
            case .rhythms:
                return [.doubleTap, .gallop, .heartbeat, .staccato, .waltz]
            case .strong:
                return [.buzz, .heavy, .thud]
            case .special:
                return [.random]
            }
        }
    }

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

    /// Picker and tap-cycle order: grouped by type, alphabetized inside each group.
    static var selectionOrder: [HapticPattern] {
        Category.allCases.flatMap(\.patterns)
    }

    /// All patterns except random (for random mode selection)
    static var nonRandomPatterns: [HapticPattern] {
        selectionOrder.filter { $0 != .random }
    }
}

/// Number systems available for the scrolling item line.
enum NumberSystem: String, CaseIterable, Identifiable {
    case decimal
    case roman
    case binary
    case hexadecimal
    case octal
    case base26

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .decimal: return "Decimal"
        case .roman: return "Roman"
        case .binary: return "Binary"
        case .hexadecimal: return "Hex"
        case .octal: return "Octal"
        case .base26: return "Base-26"
        }
    }

    var icon: String {
        switch self {
        case .decimal: return "number"
        case .roman: return "textformat"
        case .binary: return "01.circle"
        case .hexadecimal: return "x.squareroot"
        case .octal: return "8.circle"
        case .base26: return "a.circle"
        }
    }
}

/// Formats a large number compactly: 1500 → "1.5K", 2000000 → "2.0M", 1B → "1.0B"
/// Thresholds use rounding-safe boundaries to avoid "1000.0X" display artifacts.
private func formatCompact(_ value: Int) -> String {
    let d = Double(value)
    let value64 = Int64(value)
    let trillionThreshold: Int64 = 999_950_000_000
    if value64 >= trillionThreshold {
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

private func signedMagnitude(_ num: Int) -> (sign: String, magnitude: Int)? {
    guard num != Int.min else { return nil }
    return (num < 0 ? "-" : "", abs(num))
}

private func formatRoman(_ value: Int) -> String {
    guard value > 0 else { return "N" }
    guard value <= 3999 else { return formatCompact(value) }

    var remaining = value
    var result = ""
    let numerals: [(value: Int, symbol: String)] = [
        (1000, "M"),
        (900, "CM"),
        (500, "D"),
        (400, "CD"),
        (100, "C"),
        (90, "XC"),
        (50, "L"),
        (40, "XL"),
        (10, "X"),
        (9, "IX"),
        (5, "V"),
        (4, "IV"),
        (1, "I")
    ]

    for numeral in numerals {
        while remaining >= numeral.value {
            result += numeral.symbol
            remaining -= numeral.value
        }
    }
    return result
}

private func formatBase26(_ value: Int) -> String {
    guard value > 0 else { return "0" }

    var remaining = value
    var result = ""
    while remaining > 0 {
        remaining -= 1
        let scalarValue = 65 + (remaining % 26)
        if let scalar = UnicodeScalar(scalarValue) {
            result.insert(Character(scalar), at: result.startIndex)
        }
        remaining /= 26
    }
    return result
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
func formatItemNumber(_ num: Int, system: NumberSystem = .decimal) -> String {
    // Guard against Int.min where abs() would overflow
    guard num != Int.min else { return "-9.2E" }
    guard let parts = signedMagnitude(num) else { return "-9.2E" }

    switch system {
    case .decimal:
        let formatted = formatCompact(parts.magnitude)
        if parts.magnitude >= 10_000 {
            return parts.sign + formatted
        }
        return "\(num)"
    case .roman:
        return parts.sign + formatRoman(parts.magnitude)
    case .binary:
        return parts.sign + String(parts.magnitude, radix: 2)
    case .hexadecimal:
        return parts.sign + String(parts.magnitude, radix: 16).uppercased()
    case .octal:
        return parts.sign + String(parts.magnitude, radix: 8)
    case .base26:
        return parts.sign + formatBase26(parts.magnitude)
    }
}

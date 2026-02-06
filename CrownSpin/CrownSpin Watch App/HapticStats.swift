import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Tracks haptic usage statistics
class HapticStats: ObservableObject {
    static let shared = HapticStats()

    private enum Keys {
        static let totalHaptics = "stats.totalHaptics"
        static let sessionHaptics = "stats.sessionHaptics"
        static let longestSession = "stats.longestSession"
        static let totalSessions = "stats.totalSessions"
        static let lastSessionDate = "stats.lastSessionDate"
    }

    @Published private(set) var totalHaptics: Int {
        didSet { UserDefaults.standard.set(totalHaptics, forKey: Keys.totalHaptics) }
    }

    @Published private(set) var sessionHaptics: Int = 0

    @Published private(set) var longestSession: Int {
        didSet { UserDefaults.standard.set(longestSession, forKey: Keys.longestSession) }
    }

    @Published private(set) var totalSessions: Int {
        didSet { UserDefaults.standard.set(totalSessions, forKey: Keys.totalSessions) }
    }

    private init() {
        self.totalHaptics = UserDefaults.standard.integer(forKey: Keys.totalHaptics)
        self.longestSession = UserDefaults.standard.integer(forKey: Keys.longestSession)
        self.totalSessions = UserDefaults.standard.integer(forKey: Keys.totalSessions)
    }

    func recordHaptic() {
        totalHaptics += 1
        sessionHaptics += 1
    }

    func startSession() {
        sessionHaptics = 0
        totalSessions += 1
    }

    func endSession() {
        if sessionHaptics > longestSession {
            longestSession = sessionHaptics
        }
        // Refresh complications when session ends
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    func resetStats() {
        totalHaptics = 0
        longestSession = 0
        totalSessions = 0
        sessionHaptics = 0
    }

    var formattedTotal: String {
        formatNumber(totalHaptics)
    }

    var formattedSession: String {
        formatNumber(sessionHaptics)
    }

    var formattedLongest: String {
        formatNumber(longestSession)
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

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Tracks haptic usage statistics
class HapticStats: ObservableObject {
    static let shared = HapticStats()
    private static let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)

    private enum Keys {
        static let totalHaptics = "stats.totalHaptics"
        static let sessionHaptics = "stats.sessionHaptics"
        static let longestSession = "stats.longestSession"
        static let totalSessions = "stats.totalSessions"
        static let lastSessionDate = "stats.lastSessionDate"
        static let peakSpeed = "stats.peakSpeed"
        static let currentStreak = "stats.currentStreak"
        static let totalSpinTime = "stats.totalSpinTime"
    }

    @Published private(set) var totalHaptics: Int {
        didSet {
            UserDefaults.standard.set(totalHaptics, forKey: Keys.totalHaptics)
            Self.sharedDefaults?.set(totalHaptics, forKey: Keys.totalHaptics)
        }
    }

    @Published private(set) var sessionHaptics: Int = 0

    @Published private(set) var longestSession: Int {
        didSet {
            UserDefaults.standard.set(longestSession, forKey: Keys.longestSession)
            Self.sharedDefaults?.set(longestSession, forKey: Keys.longestSession)
        }
    }

    @Published private(set) var totalSessions: Int {
        didSet {
            UserDefaults.standard.set(totalSessions, forKey: Keys.totalSessions)
            Self.sharedDefaults?.set(totalSessions, forKey: Keys.totalSessions)
        }
    }

    @Published private(set) var peakSpeed: Double {
        didSet {
            UserDefaults.standard.set(peakSpeed, forKey: Keys.peakSpeed)
        }
    }

    @Published private(set) var currentStreak: Int {
        didSet {
            UserDefaults.standard.set(currentStreak, forKey: Keys.currentStreak)
        }
    }

    @Published private(set) var totalSpinTime: TimeInterval {
        didSet {
            UserDefaults.standard.set(totalSpinTime, forKey: Keys.totalSpinTime)
        }
    }

    // Speed measurement: rolling window of haptic timestamps
    private var recentHapticTimes: [TimeInterval] = []
    private static let speedWindow: TimeInterval = 0.5

    // Spin time tracking
    private var spinStartTime: TimeInterval?

    private init() {
        self.totalHaptics = UserDefaults.standard.integer(forKey: Keys.totalHaptics)
        self.longestSession = UserDefaults.standard.integer(forKey: Keys.longestSession)
        self.totalSessions = UserDefaults.standard.integer(forKey: Keys.totalSessions)
        self.peakSpeed = UserDefaults.standard.double(forKey: Keys.peakSpeed)
        self.currentStreak = UserDefaults.standard.integer(forKey: Keys.currentStreak)
        self.totalSpinTime = UserDefaults.standard.double(forKey: Keys.totalSpinTime)
        // Sync existing stats to shared defaults for the complication
        Self.sharedDefaults?.set(totalHaptics, forKey: Keys.totalHaptics)
        Self.sharedDefaults?.set(longestSession, forKey: Keys.longestSession)
        Self.sharedDefaults?.set(totalSessions, forKey: Keys.totalSessions)
    }

    func recordHaptic() {
        totalHaptics += 1
        sessionHaptics += 1

        // Track peak speed with a rolling window
        let now = ProcessInfo.processInfo.systemUptime
        recentHapticTimes.append(now)
        let cutoff = now - Self.speedWindow
        recentHapticTimes.removeAll { $0 < cutoff }
        if let earliest = recentHapticTimes.first {
            let elapsed = now - earliest
            if elapsed > 0 && recentHapticTimes.count > 1 {
                let speed = Double(recentHapticTimes.count) / elapsed
                if speed > peakSpeed {
                    peakSpeed = speed
                }
            }
        }
    }

    func startSession() {
        sessionHaptics = 0
        totalSessions += 1
        recentHapticTimes.removeAll()

        // Streak tracking
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let lastDateInterval = UserDefaults.standard.object(forKey: Keys.lastSessionDate) as? TimeInterval {
            let lastDate = calendar.startOfDay(for: Date(timeIntervalSince1970: lastDateInterval))
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysBetween == 1 {
                currentStreak += 1
            } else if daysBetween > 1 {
                currentStreak = 1
            }
            // daysBetween == 0 means same day — no change
        } else {
            // First ever session
            currentStreak = 1
        }
        UserDefaults.standard.set(today.timeIntervalSince1970, forKey: Keys.lastSessionDate)
    }

    func endSession() {
        if sessionHaptics > longestSession {
            longestSession = sessionHaptics
        }
        stopSpinning()
        // Refresh complications when session ends
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    func startSpinning() {
        if spinStartTime == nil {
            spinStartTime = ProcessInfo.processInfo.systemUptime
        }
    }

    func stopSpinning() {
        if let start = spinStartTime {
            totalSpinTime += ProcessInfo.processInfo.systemUptime - start
            spinStartTime = nil
        }
    }

    func resetStats() {
        totalHaptics = 0
        longestSession = 0
        totalSessions = 0
        sessionHaptics = 0
        peakSpeed = 0
        currentStreak = 0
        totalSpinTime = 0
        recentHapticTimes.removeAll()
        spinStartTime = nil
        UserDefaults.standard.removeObject(forKey: Keys.lastSessionDate)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    var formattedTotal: String {
        formatHapticNumber(totalHaptics)
    }

    var formattedSession: String {
        formatHapticNumber(sessionHaptics)
    }

    var formattedLongest: String {
        formatHapticNumber(longestSession)
    }

    var formattedPeakSpeed: String {
        if peakSpeed == 0 { return "0" }
        return String(format: "%.1f /sec", peakSpeed)
    }

    var formattedAvgSession: String {
        guard totalSessions > 0 else { return "0" }
        return formatHapticNumber(totalHaptics / totalSessions)
    }

    var formattedStreak: String {
        if currentStreak <= 1 { return "\(currentStreak) day" }
        return "\(currentStreak) days"
    }

    var formattedSpinTime: String {
        formatDuration(totalSpinTime)
    }
}

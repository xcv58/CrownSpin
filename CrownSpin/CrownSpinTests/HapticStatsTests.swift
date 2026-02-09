import XCTest

final class HapticStatsTests: XCTestCase {

    private var stats: HapticStats!

    private let allKeys = [
        "stats.totalHaptics",
        "stats.sessionHaptics",
        "stats.longestSession",
        "stats.totalSessions",
        "stats.lastSessionDate"
    ]

    override func setUp() {
        super.setUp()
        stats = HapticStats.shared
        stats.resetStats()
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    override func tearDown() {
        stats.resetStats()
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        super.tearDown()
    }

    // MARK: - Singleton

    func testSingletonIdentity() {
        XCTAssertTrue(HapticStats.shared === HapticStats.shared)
    }

    // MARK: - Initial State

    func testInitialStateAfterReset() {
        XCTAssertEqual(stats.totalHaptics, 0)
        XCTAssertEqual(stats.sessionHaptics, 0)
        XCTAssertEqual(stats.longestSession, 0)
        XCTAssertEqual(stats.totalSessions, 0)
    }

    // MARK: - recordHaptic

    func testRecordHapticIncrementsTotalHaptics() {
        stats.recordHaptic()
        XCTAssertEqual(stats.totalHaptics, 1)
        stats.recordHaptic()
        XCTAssertEqual(stats.totalHaptics, 2)
    }

    func testRecordHapticIncrementsSessionHaptics() {
        stats.recordHaptic()
        XCTAssertEqual(stats.sessionHaptics, 1)
        stats.recordHaptic()
        stats.recordHaptic()
        XCTAssertEqual(stats.sessionHaptics, 3)
    }

    func testRecordHapticIncrementsBothCounters() {
        stats.recordHaptic()
        XCTAssertEqual(stats.totalHaptics, 1)
        XCTAssertEqual(stats.sessionHaptics, 1)
    }

    // MARK: - startSession

    func testStartSessionResetsSessionHaptics() {
        stats.recordHaptic()
        stats.recordHaptic()
        XCTAssertEqual(stats.sessionHaptics, 2)
        stats.startSession()
        XCTAssertEqual(stats.sessionHaptics, 0)
    }

    func testStartSessionIncrementsTotalSessions() {
        XCTAssertEqual(stats.totalSessions, 0)
        stats.startSession()
        XCTAssertEqual(stats.totalSessions, 1)
        stats.startSession()
        XCTAssertEqual(stats.totalSessions, 2)
    }

    func testStartSessionPreservesTotalHaptics() {
        stats.recordHaptic()
        stats.recordHaptic()
        stats.recordHaptic()
        let total = stats.totalHaptics
        stats.startSession()
        XCTAssertEqual(stats.totalHaptics, total)
    }

    // MARK: - endSession

    func testEndSessionUpdatesLongestSession() {
        stats.recordHaptic()
        stats.recordHaptic()
        stats.recordHaptic()
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 3)
    }

    func testEndSessionDoesNotUpdateLongestWhenShorter() {
        // First session: 5 haptics
        for _ in 0..<5 { stats.recordHaptic() }
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 5)

        // Second session: 2 haptics (shorter)
        stats.startSession()
        stats.recordHaptic()
        stats.recordHaptic()
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 5)
    }

    func testEndSessionWithZeroHapticsDoesNotUpdateLongest() {
        // First set a longest of 3
        for _ in 0..<3 { stats.recordHaptic() }
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 3)

        // End a session with 0 haptics
        stats.startSession()
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 3)
    }

    func testEndSessionUpdatesLongestWhenLonger() {
        // First session: 2 haptics
        stats.recordHaptic()
        stats.recordHaptic()
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 2)

        // Second session: 5 haptics (longer)
        stats.startSession()
        for _ in 0..<5 { stats.recordHaptic() }
        stats.endSession()
        XCTAssertEqual(stats.longestSession, 5)
    }

    // MARK: - resetStats

    func testResetStatsClearsEverything() {
        stats.recordHaptic()
        stats.recordHaptic()
        stats.startSession()
        stats.recordHaptic()
        stats.endSession()

        stats.resetStats()

        XCTAssertEqual(stats.totalHaptics, 0)
        XCTAssertEqual(stats.sessionHaptics, 0)
        XCTAssertEqual(stats.longestSession, 0)
        XCTAssertEqual(stats.totalSessions, 0)
    }

    // MARK: - Full Session Lifecycle

    func testMultiSessionLifecycle() {
        // Session 1: 3 haptics
        stats.startSession()
        for _ in 0..<3 { stats.recordHaptic() }
        stats.endSession()

        XCTAssertEqual(stats.totalHaptics, 3)
        XCTAssertEqual(stats.totalSessions, 1)
        XCTAssertEqual(stats.longestSession, 3)

        // Session 2: 5 haptics
        stats.startSession()
        for _ in 0..<5 { stats.recordHaptic() }
        stats.endSession()

        XCTAssertEqual(stats.totalHaptics, 8)
        XCTAssertEqual(stats.totalSessions, 2)
        XCTAssertEqual(stats.longestSession, 5)

        // Session 3: 1 haptic (doesn't beat longest)
        stats.startSession()
        stats.recordHaptic()
        stats.endSession()

        XCTAssertEqual(stats.totalHaptics, 9)
        XCTAssertEqual(stats.totalSessions, 3)
        XCTAssertEqual(stats.longestSession, 5)
    }

    // MARK: - Formatted Properties

    func testFormattedTotalUsesFormatHapticNumber() {
        XCTAssertEqual(stats.formattedTotal, "0")
        for _ in 0..<1500 { stats.recordHaptic() }
        XCTAssertEqual(stats.formattedTotal, "1.5K")
    }

    func testFormattedSessionUsesFormatHapticNumber() {
        XCTAssertEqual(stats.formattedSession, "0")
        for _ in 0..<2000 { stats.recordHaptic() }
        XCTAssertEqual(stats.formattedSession, "2.0K")
    }

    func testFormattedLongestUsesFormatHapticNumber() {
        XCTAssertEqual(stats.formattedLongest, "0")
        for _ in 0..<1000 { stats.recordHaptic() }
        stats.endSession()
        XCTAssertEqual(stats.formattedLongest, "1.0K")
    }

    // MARK: - UserDefaults Persistence

    func testTotalHapticsPersistsToUserDefaults() {
        stats.recordHaptic()
        stats.recordHaptic()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "stats.totalHaptics"), 2)
    }

    func testLongestSessionPersistsToUserDefaults() {
        for _ in 0..<7 { stats.recordHaptic() }
        stats.endSession()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "stats.longestSession"), 7)
    }

    func testTotalSessionsPersistsToUserDefaults() {
        stats.startSession()
        stats.startSession()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "stats.totalSessions"), 2)
    }

    func testSessionHapticsDoesNotPersistToUserDefaults() {
        stats.recordHaptic()
        stats.recordHaptic()
        // sessionHaptics should not be stored in UserDefaults
        // The key "stats.sessionHaptics" should remain at default (0)
        // since sessionHaptics has no didSet that writes to UserDefaults
        UserDefaults.standard.removeObject(forKey: "stats.sessionHaptics")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "stats.sessionHaptics"), 0)
    }
}

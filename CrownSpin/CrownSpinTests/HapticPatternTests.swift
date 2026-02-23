import XCTest
import WatchKit

final class HapticPatternTests: XCTestCase {

    // MARK: - Enum Cases

    func testAllCasesCount() {
        XCTAssertEqual(HapticPattern.allCases.count, 15)
    }

    func testAllCasesOrdering() {
        let expected: [HapticPattern] = [
            .clicks, .soft, .heavy,
            .buzz, .ping, .thud, .drift, .pulse,
            .heartbeat, .doubleTap, .gallop, .waltz, .staccato, .wave, .random
        ]
        XCTAssertEqual(HapticPattern.allCases, expected)
    }

    func testRawValueRoundTrip() {
        for pattern in HapticPattern.allCases {
            XCTAssertEqual(HapticPattern(rawValue: pattern.rawValue), pattern)
        }
    }

    func testInvalidRawValueReturnsNil() {
        XCTAssertNil(HapticPattern(rawValue: "nonexistent"))
        XCTAssertNil(HapticPattern(rawValue: ""))
        XCTAssertNil(HapticPattern(rawValue: "Clicks"))
    }

    // MARK: - Display Name

    func testDisplayNames() {
        let expectedNames: [HapticPattern: String] = [
            .clicks: "Clicks",
            .soft: "Soft",
            .heavy: "Heavy",
            .buzz: "Buzz",
            .ping: "Ping",
            .thud: "Thud",
            .drift: "Drift",
            .pulse: "Pulse",
            .heartbeat: "Heartbeat",
            .doubleTap: "Double Tap",
            .gallop: "Gallop",
            .waltz: "Waltz",
            .staccato: "Staccato",
            .wave: "Wave",
            .random: "Random"
        ]
        for (pattern, name) in expectedNames {
            XCTAssertEqual(pattern.displayName, name, "displayName mismatch for \(pattern)")
        }
    }

    // MARK: - Icon

    func testIcons() {
        let expectedIcons: [HapticPattern: String] = [
            .clicks: "hand.tap",
            .soft: "cloud",
            .heavy: "hammer",
            .buzz: "antenna.radiowaves.left.and.right",
            .ping: "checkmark.circle",
            .thud: "xmark.circle",
            .drift: "leaf.arrow.triangle.circlepath",
            .pulse: "dot.radiowaves.right",
            .heartbeat: "heart",
            .doubleTap: "hand.tap.fill",
            .gallop: "hare",
            .waltz: "figure.dance",
            .staccato: "bolt",
            .wave: "water.waves",
            .random: "dice"
        ]
        for (pattern, icon) in expectedIcons {
            XCTAssertEqual(pattern.icon, icon, "icon mismatch for \(pattern)")
        }
    }

    // MARK: - Primary Haptic

    func testPrimaryHaptics() {
        let expectedHaptics: [HapticPattern: WKHapticType] = [
            .clicks: .click,
            .soft: .directionUp,
            .heavy: .notification,
            .buzz: .retry,
            .ping: .success,
            .thud: .failure,
            .drift: .directionDown,
            .pulse: .stop,
            .heartbeat: .start,
            .doubleTap: .click,
            .gallop: .click,
            .waltz: .click,
            .staccato: .click,
            .wave: .directionUp,
            .random: .click
        ]
        for (pattern, haptic) in expectedHaptics {
            XCTAssertEqual(pattern.primaryHaptic, haptic, "primaryHaptic mismatch for \(pattern)")
        }
    }

    // MARK: - Non-Random Patterns

    func testNonRandomPatternsExcludesRandom() {
        XCTAssertFalse(HapticPattern.nonRandomPatterns.contains(.random))
    }

    func testNonRandomPatternsCount() {
        XCTAssertEqual(HapticPattern.nonRandomPatterns.count, 14)
    }

    func testNonRandomPatternsPreservesOrder() {
        let expected: [HapticPattern] = [
            .clicks, .soft, .heavy,
            .buzz, .ping, .thud, .drift, .pulse,
            .heartbeat, .doubleTap, .gallop, .waltz, .staccato, .wave
        ]
        XCTAssertEqual(HapticPattern.nonRandomPatterns, expected)
    }

    // MARK: - Identifiable

    func testIdEqualsRawValue() {
        for pattern in HapticPattern.allCases {
            XCTAssertEqual(pattern.id, pattern.rawValue)
        }
    }

    func testAllIdsUnique() {
        let ids = HapticPattern.allCases.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    // MARK: - App Group Suite Name

    func testAppGroupSuiteName() {
        XCTAssertEqual(appGroupSuiteName, "group.com.xcv58.crownspin.watchapp")
    }

    // MARK: - formatHapticNumber

    func testFormatHapticNumberZero() {
        XCTAssertEqual(formatHapticNumber(0), "0")
    }

    func testFormatHapticNumberBelowThousand() {
        XCTAssertEqual(formatHapticNumber(1), "1")
        XCTAssertEqual(formatHapticNumber(999), "999")
    }

    func testFormatHapticNumberAtThousand() {
        XCTAssertEqual(formatHapticNumber(1000), "1.0K")
    }

    func testFormatHapticNumberBelowMillion() {
        XCTAssertEqual(formatHapticNumber(1500), "1.5K")
        XCTAssertEqual(formatHapticNumber(999_949), "999.9K")
        // 999,950+ rounds to 1.0M to avoid displaying "1000.0K"
        XCTAssertEqual(formatHapticNumber(999_950), "1.0M")
        XCTAssertEqual(formatHapticNumber(999_999), "1.0M")
    }

    func testFormatHapticNumberAtMillion() {
        XCTAssertEqual(formatHapticNumber(1_000_000), "1.0M")
    }

    func testFormatHapticNumberAboveMillion() {
        XCTAssertEqual(formatHapticNumber(2_500_000), "2.5M")
    }

    func testFormatHapticNumberBillions() {
        XCTAssertEqual(formatHapticNumber(1_000_000_000), "1.0B")
        XCTAssertEqual(formatHapticNumber(100_000_000_000), "100.0B")
    }

    func testFormatHapticNumberTrillions() {
        XCTAssertEqual(formatHapticNumber(1_000_000_000_000), "1.0T")
    }
}

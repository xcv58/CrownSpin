import XCTest
import WatchKit

final class HapticPatternTests: XCTestCase {

    // MARK: - Enum Cases

    func testAllCasesCount() {
        XCTAssertEqual(HapticPattern.allCases.count, 15)
    }

    func testAllCasesOrdering() {
        let expected: [HapticPattern] = [
            .clicks, .ping, .soft,
            .drift, .pulse, .wave,
            .doubleTap, .gallop, .heartbeat, .staccato, .waltz,
            .buzz, .heavy, .thud,
            .random
        ]
        XCTAssertEqual(HapticPattern.allCases, expected)
    }

    func testCategoriesOrdering() {
        XCTAssertEqual(
            HapticPattern.Category.allCases.map(\.rawValue),
            ["Basic", "Motion", "Rhythms", "Strong", "Special"]
        )
    }

    func testSelectionOrderMatchesGroupedDisplayOrder() {
        let expected: [HapticPattern] = [
            .clicks, .ping, .soft,
            .drift, .pulse, .wave,
            .doubleTap, .gallop, .heartbeat, .staccato, .waltz,
            .buzz, .heavy, .thud,
            .random
        ]
        XCTAssertEqual(HapticPattern.selectionOrder, expected)
    }

    func testCategoryPatternsAreAlphabetizedByDisplayName() {
        for category in HapticPattern.Category.allCases {
            let names = category.patterns.map(\.displayName)
            XCTAssertEqual(names, names.sorted(), "\(category.rawValue) is not alphabetized")
        }
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
            .clicks, .ping, .soft,
            .drift, .pulse, .wave,
            .doubleTap, .gallop, .heartbeat, .staccato, .waltz,
            .buzz, .heavy, .thud
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
        XCTAssertEqual(appGroupSuiteName, "group.media.jenny.crownspin.watchapp")
    }

    // MARK: - NumberSystem

    func testNumberSystemCasesOrdering() {
        XCTAssertEqual(
            NumberSystem.allCases.map(\.rawValue),
            ["decimal", "roman", "binary", "hexadecimal", "octal", "base26"]
        )
    }

    func testNumberSystemDisplayNames() {
        let expectedNames: [NumberSystem: String] = [
            .decimal: "Decimal",
            .roman: "Roman",
            .binary: "Binary",
            .hexadecimal: "Hex",
            .octal: "Octal",
            .base26: "Base-26"
        ]
        for (system, name) in expectedNames {
            XCTAssertEqual(system.displayName, name)
        }
    }

    func testFormatItemNumberRoman() {
        XCTAssertEqual(formatItemNumber(0, system: .roman), "N")
        XCTAssertEqual(formatItemNumber(4, system: .roman), "IV")
        XCTAssertEqual(formatItemNumber(42, system: .roman), "XLII")
        XCTAssertEqual(formatItemNumber(1999, system: .roman), "MCMXCIX")
        XCTAssertEqual(formatItemNumber(-9, system: .roman), "-IX")
        XCTAssertEqual(formatItemNumber(4000, system: .roman), "4.0K")
    }

    func testFormatItemNumberBinary() {
        XCTAssertEqual(formatItemNumber(0, system: .binary), "0")
        XCTAssertEqual(formatItemNumber(5, system: .binary), "101")
        XCTAssertEqual(formatItemNumber(-5, system: .binary), "-101")
    }

    func testFormatItemNumberHexadecimal() {
        XCTAssertEqual(formatItemNumber(0, system: .hexadecimal), "0")
        XCTAssertEqual(formatItemNumber(255, system: .hexadecimal), "FF")
        XCTAssertEqual(formatItemNumber(-255, system: .hexadecimal), "-FF")
    }

    func testFormatItemNumberOctal() {
        XCTAssertEqual(formatItemNumber(0, system: .octal), "0")
        XCTAssertEqual(formatItemNumber(64, system: .octal), "100")
        XCTAssertEqual(formatItemNumber(-64, system: .octal), "-100")
    }

    func testFormatItemNumberBase26() {
        XCTAssertEqual(formatItemNumber(0, system: .base26), "A")
        XCTAssertEqual(formatItemNumber(1, system: .base26), "B")
        XCTAssertEqual(formatItemNumber(25, system: .base26), "Z")
        XCTAssertEqual(formatItemNumber(26, system: .base26), "AA")
        XCTAssertEqual(formatItemNumber(51, system: .base26), "AZ")
        XCTAssertEqual(formatItemNumber(52, system: .base26), "BA")
        XCTAssertEqual(formatItemNumber(-26, system: .base26), "-AA")
    }

    func testFormatResetTarget() {
        XCTAssertEqual(formatResetTarget(system: .decimal), "0")
        XCTAssertEqual(formatResetTarget(system: .binary), "0")
        XCTAssertEqual(formatResetTarget(system: .hexadecimal), "0")
        XCTAssertEqual(formatResetTarget(system: .octal), "0")
        XCTAssertEqual(formatResetTarget(system: .roman), "N (0)")
        XCTAssertEqual(formatResetTarget(system: .base26), "A (0)")
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

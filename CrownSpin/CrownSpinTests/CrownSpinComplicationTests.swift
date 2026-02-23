import XCTest
import WidgetKit

final class CrownSpinComplicationTests: XCTestCase {

    private let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)

    override func setUp() {
        super.setUp()
        sharedDefaults?.removeObject(forKey: "stats.totalHaptics")
        sharedDefaults?.removeObject(forKey: "selectedHapticPattern")
        sharedDefaults?.removeObject(forKey: "currentItemNumber")
    }

    override func tearDown() {
        sharedDefaults?.removeObject(forKey: "stats.totalHaptics")
        sharedDefaults?.removeObject(forKey: "selectedHapticPattern")
        sharedDefaults?.removeObject(forKey: "currentItemNumber")
        super.tearDown()
    }

    // MARK: - CrownSpinEntry

    func testEntryStoresAllProperties() {
        let date = Date()
        let entry = CrownSpinEntry(
            date: date,
            totalHaptics: 42,
            currentPattern: "Heavy",
            patternIcon: "hammer",
            currentItemNumber: 7
        )
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.totalHaptics, 42)
        XCTAssertEqual(entry.currentPattern, "Heavy")
        XCTAssertEqual(entry.patternIcon, "hammer")
        XCTAssertEqual(entry.currentItemNumber, 7)
    }

    func testEntryDefaultValues() {
        let entry = CrownSpinEntry(
            date: Date(),
            totalHaptics: 0,
            currentPattern: "Clicks",
            patternIcon: "hand.tap",
            currentItemNumber: 0
        )
        XCTAssertEqual(entry.totalHaptics, 0)
        XCTAssertEqual(entry.currentPattern, "Clicks")
        XCTAssertEqual(entry.patternIcon, "hand.tap")
        XCTAssertEqual(entry.currentItemNumber, 0)
    }

    // MARK: - CrownSpinProvider.createEntry

    func testCreateEntryWithEmptyDefaultsFallsBack() {
        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.totalHaptics, 0)
        XCTAssertEqual(entry.currentPattern, "Clicks")
        XCTAssertEqual(entry.patternIcon, "hand.tap")
        XCTAssertEqual(entry.currentItemNumber, 0)
    }

    func testCreateEntryReadsFromSharedDefaults() {
        sharedDefaults?.set(123, forKey: "stats.totalHaptics")
        sharedDefaults?.set("heavy", forKey: "selectedHapticPattern")

        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.totalHaptics, 123)
        XCTAssertEqual(entry.currentPattern, "Heavy")
        XCTAssertEqual(entry.patternIcon, "hammer")
    }

    func testCreateEntryWithInvalidPatternFallsBackToClicks() {
        sharedDefaults?.set("invalidPattern", forKey: "selectedHapticPattern")

        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.currentPattern, "Clicks")
        XCTAssertEqual(entry.patternIcon, "hand.tap")
    }

    func testCreateEntryReadsCorrectPatternForEachCase() {
        let provider = CrownSpinProvider()
        for pattern in HapticPattern.allCases {
            sharedDefaults?.set(pattern.rawValue, forKey: "selectedHapticPattern")
            let entry = provider.createEntry()
            XCTAssertEqual(entry.currentPattern, pattern.displayName,
                "Pattern mismatch for \(pattern.rawValue)")
            XCTAssertEqual(entry.patternIcon, pattern.icon,
                "Icon mismatch for \(pattern.rawValue)")
        }
    }

    func testCreateEntryDateIsApproximatelyNow() {
        let before = Date()
        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        let after = Date()
        XCTAssertGreaterThanOrEqual(entry.date, before)
        XCTAssertLessThanOrEqual(entry.date, after)
    }

    func testCreateEntryWithLargeHapticCount() {
        sharedDefaults?.set(1_500_000, forKey: "stats.totalHaptics")

        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.totalHaptics, 1_500_000)
    }

    // MARK: - Widget Kind

    func testComplicationKind() {
        let complication = CrownSpinComplication()
        XCTAssertEqual(complication.kind, "CrownSpinComplication")
    }

    // MARK: - Shared Defaults Key Names

    func testSharedDefaultsUsesCorrectTotalHapticsKey() {
        sharedDefaults?.set(999, forKey: "stats.totalHaptics")
        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.totalHaptics, 999)
    }

    func testSharedDefaultsUsesCorrectPatternKey() {
        sharedDefaults?.set("wave", forKey: "selectedHapticPattern")
        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.currentPattern, "Wave")
        XCTAssertEqual(entry.patternIcon, "water.waves")
    }

    // MARK: - Entry Conforms to TimelineEntry

    func testEntryConformsToTimelineEntry() {
        let entry = CrownSpinEntry(
            date: Date(),
            totalHaptics: 0,
            currentPattern: "Clicks",
            patternIcon: "hand.tap",
            currentItemNumber: 0
        )
        // TimelineEntry requires a `date` property
        let _: Date = entry.date
        XCTAssertNotNil(entry.date)
    }

    // MARK: - Current Item Number

    func testCreateEntryReadsCurrentItemNumberFromSharedDefaults() {
        sharedDefaults?.set(99, forKey: "currentItemNumber")

        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.currentItemNumber, 99)
    }

    func testCreateEntryWithNegativeItemNumber() {
        sharedDefaults?.set(-42, forKey: "currentItemNumber")

        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.currentItemNumber, -42)
    }

    func testCreateEntryItemNumberDefaultsToZeroWhenAbsent() {
        let provider = CrownSpinProvider()
        let entry = provider.createEntry()
        XCTAssertEqual(entry.currentItemNumber, 0)
    }
}

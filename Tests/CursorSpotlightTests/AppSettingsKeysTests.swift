import XCTest
@testable import CursorSpotlight

final class AppSettingsKeysTests: XCTestCase {
    func testKeysHaveStablePrefix() {
        XCTAssertTrue(AppSettings.Keys.radius.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.color.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.opacity.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.patternPath.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.usePattern.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.allScreens.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.launchAtLogin.hasPrefix("cs."))
        XCTAssertTrue(AppSettings.Keys.hotKey.hasPrefix("cs."))
    }

    func testKeysAreUnique() {
        let keys: [String] = [
            AppSettings.Keys.radius,
            AppSettings.Keys.color,
            AppSettings.Keys.opacity,
            AppSettings.Keys.patternPath,
            AppSettings.Keys.usePattern,
            AppSettings.Keys.allScreens,
            AppSettings.Keys.launchAtLogin,
            AppSettings.Keys.hotKey,
        ]
        XCTAssertEqual(Set(keys).count, keys.count)
    }
}

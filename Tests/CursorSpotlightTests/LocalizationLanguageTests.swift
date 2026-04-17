import XCTest
@testable import CursorSpotlight

final class LocalizationLanguageTests: XCTestCase {
    func testSystemLanguageHasNilCode() {
        XCTAssertNil(LocalizationManager.Language.system.code)
    }

    func testExplicitLanguagesMapToISOCodes() {
        XCTAssertEqual(LocalizationManager.Language.en.code, "en")
        XCTAssertEqual(LocalizationManager.Language.ko.code, "ko")
        XCTAssertEqual(LocalizationManager.Language.ja.code, "ja")
    }

    func testRawValueRoundTrip() {
        for language in LocalizationManager.Language.allCases {
            let decoded = LocalizationManager.Language(rawValue: language.rawValue)
            XCTAssertEqual(decoded, language)
        }
    }

    func testAllCasesContainsAllFour() {
        let cases = Set(LocalizationManager.Language.allCases)
        XCTAssertEqual(cases, [.system, .en, .ko, .ja])
    }

    func testIdMatchesRawValue() {
        for language in LocalizationManager.Language.allCases {
            XCTAssertEqual(language.id, language.rawValue)
        }
    }

    func testInvalidRawValueReturnsNil() {
        XCTAssertNil(LocalizationManager.Language(rawValue: "fr"))
        XCTAssertNil(LocalizationManager.Language(rawValue: ""))
    }
}

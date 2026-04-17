import AppKit
import HotKey
import XCTest
@testable import CursorSpotlight

final class HotKeySpecTests: XCTestCase {
    func testDefaultSpecIsCommandOptionF1() {
        let spec = HotKeySpec.defaultSpec
        XCTAssertEqual(spec.key, .f1)
        XCTAssertTrue(spec.modifiers.contains(.command))
        XCTAssertTrue(spec.modifiers.contains(.option))
    }

    func testRawValueRoundTrip() {
        let spec = HotKeySpec(key: .space, modifiers: [.command, .shift])
        let decoded = HotKeySpec(rawValue: spec.rawValue)
        XCTAssertEqual(decoded, spec)
    }

    func testRawValueRoundTripEmptyModifiers() {
        let spec = HotKeySpec(key: .f5, modifiers: [])
        let decoded = HotKeySpec(rawValue: spec.rawValue)
        XCTAssertEqual(decoded, spec)
    }

    func testRawValueRoundTripAllModifiers() {
        let spec = HotKeySpec(key: .a, modifiers: [.command, .option, .shift, .control])
        let decoded = HotKeySpec(rawValue: spec.rawValue)
        XCTAssertEqual(decoded, spec)
    }

    func testInvalidRawValueReturnsNil() {
        XCTAssertNil(HotKeySpec(rawValue: ""))
        XCTAssertNil(HotKeySpec(rawValue: "abc"))
        XCTAssertNil(HotKeySpec(rawValue: "999999"))
        XCTAssertNil(HotKeySpec(rawValue: "1:2:3"))
    }

    func testDisplayStringOrdersModifiersControlOptionShiftCommand() {
        let spec = HotKeySpec(key: .space, modifiers: [.command, .option, .shift, .control])
        XCTAssertTrue(spec.displayString.hasPrefix("⌃⌥⇧⌘"))
    }

    func testDisplayStringIncludesOnlyPresentModifiers() {
        let spec = HotKeySpec(key: .f1, modifiers: [.command, .option])
        XCTAssertTrue(spec.displayString.contains("⌘"))
        XCTAssertTrue(spec.displayString.contains("⌥"))
        XCTAssertFalse(spec.displayString.contains("⇧"))
        XCTAssertFalse(spec.displayString.contains("⌃"))
    }

    func testEqualitySameKeyAndModifiers() {
        let a = HotKeySpec(key: .f1, modifiers: [.command, .option])
        let b = HotKeySpec(key: .f1, modifiers: [.option, .command])
        XCTAssertEqual(a, b)
    }

    func testInequalityDifferentKey() {
        let a = HotKeySpec(key: .f1, modifiers: [.command])
        let b = HotKeySpec(key: .f2, modifiers: [.command])
        XCTAssertNotEqual(a, b)
    }
}

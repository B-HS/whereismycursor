import AppKit
import Carbon.HIToolbox
import HotKey

struct HotKeySpec: Equatable {
    let key: Key
    let modifiers: NSEvent.ModifierFlags

    static let defaultSpec = HotKeySpec(key: .f1, modifiers: [.command, .option])

    var rawValue: String {
        "\(key.carbonKeyCode):\(modifiers.rawValue)"
    }

    init(key: Key, modifiers: NSEvent.ModifierFlags) {
        self.key = key
        self.modifiers = modifiers
    }

    init?(rawValue: String) {
        let parts = rawValue.split(separator: ":")
        guard parts.count == 2,
              let code = UInt32(parts[0]),
              let modRaw = UInt(parts[1]),
              let key = Key(carbonKeyCode: code)
        else { return nil }
        self.key = key
        self.modifiers = NSEvent.ModifierFlags(rawValue: modRaw)
    }

    var displayString: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(key.description)
        return parts.joined()
    }
}

final class HotKeyManager {
    private var hotKey: HotKey?
    private var currentSpec: HotKeySpec?
    private let onKeyDown: () -> Void
    private let onKeyUp: () -> Void

    init(onKeyDown: @escaping () -> Void, onKeyUp: @escaping () -> Void) {
        self.onKeyDown = onKeyDown
        self.onKeyUp = onKeyUp
    }

    func apply(_ spec: HotKeySpec) {
        hotKey = nil
        currentSpec = spec
        let hk = HotKey(key: spec.key, modifiers: spec.modifiers)
        hk.keyDownHandler = { [weak self] in
            self?.onKeyDown()
        }
        hk.keyUpHandler = { [weak self] in
            self?.onKeyUp()
        }
        hotKey = hk
    }

    func pause() {
        hotKey = nil
    }

    func resume() {
        if let spec = currentSpec {
            apply(spec)
        }
    }
}

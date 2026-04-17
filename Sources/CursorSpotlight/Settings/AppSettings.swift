import AppKit
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    @Published var radius: CGFloat {
        didSet { defaults.set(Double(radius), forKey: Keys.radius) }
    }

    @Published var overlayColor: NSColor {
        didSet {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: overlayColor, requiringSecureCoding: true) {
                defaults.set(data, forKey: Keys.color)
            }
        }
    }

    @Published var opacity: CGFloat {
        didSet { defaults.set(Double(opacity), forKey: Keys.opacity) }
    }

    @Published var patternImagePath: String? {
        didSet { defaults.set(patternImagePath, forKey: Keys.patternPath) }
    }

    @Published var usePattern: Bool {
        didSet { defaults.set(usePattern, forKey: Keys.usePattern) }
    }

    @Published var coverAllScreens: Bool {
        didSet { defaults.set(coverAllScreens, forKey: Keys.allScreens) }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            LoginItemManager.sync(enabled: launchAtLogin)
        }
    }

    @Published var hotKey: HotKeySpec {
        didSet { defaults.set(hotKey.rawValue, forKey: Keys.hotKey) }
    }

    private init() {
        let storedRadius = defaults.object(forKey: Keys.radius) as? Double
        self.radius = CGFloat(storedRadius ?? 50)

        let storedOpacity = defaults.object(forKey: Keys.opacity) as? Double
        self.opacity = CGFloat(storedOpacity ?? 0.75)

        if let data = defaults.data(forKey: Keys.color),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            self.overlayColor = color
        } else {
            self.overlayColor = .black
        }

        self.patternImagePath = defaults.string(forKey: Keys.patternPath)
        self.usePattern = defaults.bool(forKey: Keys.usePattern)
        self.coverAllScreens = (defaults.object(forKey: Keys.allScreens) as? Bool) ?? true
        self.launchAtLogin = (defaults.object(forKey: Keys.launchAtLogin) as? Bool) ?? false

        if let raw = defaults.string(forKey: Keys.hotKey),
           let spec = HotKeySpec(rawValue: raw) {
            self.hotKey = spec
        } else {
            self.hotKey = .defaultSpec
        }
    }

    enum Keys {
        static let radius = "cs.radius"
        static let color = "cs.color"
        static let opacity = "cs.opacity"
        static let patternPath = "cs.patternPath"
        static let usePattern = "cs.usePattern"
        static let allScreens = "cs.allScreens"
        static let launchAtLogin = "cs.launchAtLogin"
        static let hotKey = "cs.hotKey"
    }
}

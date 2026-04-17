import Foundation

extension Notification.Name {
    static let cursorSpotlightLanguageChanged = Notification.Name("cursorSpotlight.languageChanged")
}

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    enum Language: String, CaseIterable, Identifiable {
        case system
        case en
        case ko
        case ja

        var id: String { rawValue }

        var code: String? {
            self == .system ? nil : rawValue
        }

        var displayName: String {
            switch self {
            case .system: return NSLocalizedString("settings.language.system", bundle: .main, comment: "")
            case .en: return "English"
            case .ko: return "한국어"
            case .ja: return "日本語"
            }
        }
    }

    @Published private(set) var current: Language
    private var bundle: Bundle

    private static let defaultsKey = "cs.language"

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.defaultsKey) ?? Language.system.rawValue
        let language = Language(rawValue: saved) ?? .system
        self.current = language
        self.bundle = Self.resolveBundle(for: language)
    }

    func set(_ language: Language) {
        guard language != current else { return }
        current = language
        bundle = Self.resolveBundle(for: language)
        UserDefaults.standard.set(language.rawValue, forKey: Self.defaultsKey)
        NotificationCenter.default.post(name: .cursorSpotlightLanguageChanged, object: nil)
    }

    func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    private static func resolveBundle(for language: Language) -> Bundle {
        guard let code = language.code,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return .main }
        return bundle
    }
}

import AppKit

final class StatusItemController: NSObject {
    private var statusItem: NSStatusItem?
    private var languageObserver: NSObjectProtocol?
    private let onOpenSettings: () -> Void
    private let onQuit: () -> Void

    init(
        onOpenSettings: @escaping () -> Void,
        onQuit: @escaping () -> Void,
    ) {
        self.onOpenSettings = onOpenSettings
        self.onQuit = onQuit
        super.init()
        languageObserver = NotificationCenter.default.addObserver(
            forName: .cursorSpotlightLanguageChanged,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            self?.rebuildMenu()
        }
    }

    deinit {
        if let languageObserver {
            NotificationCenter.default.removeObserver(languageObserver)
        }
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "scope", accessibilityDescription: "Cursor Spotlight")
            image?.isTemplate = true
            button.image = image
        }
        self.statusItem = item
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.addItem(makeItem(title: L("menu.settings"), action: #selector(settingsAction), key: ","))
        menu.addItem(.separator())
        menu.addItem(makeItem(title: L("menu.quit"), action: #selector(quitAction), key: "q"))
        statusItem?.menu = menu
    }

    private func makeItem(title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    private func L(_ key: String) -> String {
        LocalizationManager.shared.localized(key)
    }

    @objc private func settingsAction() { onOpenSettings() }
    @objc private func quitAction() { onQuit() }
}

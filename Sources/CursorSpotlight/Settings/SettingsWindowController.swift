import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private var languageObserver: NSObjectProtocol?

    init(
        onAppearanceChange: @escaping () -> Void,
        onBeginRecording: @escaping () -> Void,
        onHotKeyChange: @escaping (HotKeySpec) -> Void
    ) {
        let view = SettingsView(
            settings: AppSettings.shared,
            onAppearanceChange: onAppearanceChange,
            onBeginRecording: onBeginRecording,
            onHotKeyChange: onHotKeyChange
        )
        let hosting = NSHostingController(rootView: view)
        hosting.sizingOptions = [.preferredContentSize]
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hosting
        window.title = LocalizationManager.shared.localized("settings.title")
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 500, height: 600))
        window.center()
        super.init(window: window)
        window.delegate = self

        languageObserver = NotificationCenter.default.addObserver(
            forName: .cursorSpotlightLanguageChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.window?.title = LocalizationManager.shared.localized("settings.title")
        }
    }

    deinit {
        if let languageObserver {
            NotificationCenter.default.removeObserver(languageObserver)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
    }
}

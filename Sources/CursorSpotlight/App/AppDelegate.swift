import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let overlayController = OverlayController()
    private lazy var statusItemController = StatusItemController(
        onOpenSettings: { [weak self] in self?.openSettings() },
        onQuit: { NSApp.terminate(nil) },
    )
    private lazy var hotKeyManager = HotKeyManager(
        onKeyDown: { [weak self] in self?.overlayController.show() },
        onKeyUp: { [weak self] in self?.overlayController.hide() },
    )
    private var settingsWindow: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItemController.install()
        hotKeyManager.apply(AppSettings.shared.hotKey)
        LoginItemManager.sync(enabled: AppSettings.shared.launchAtLogin)
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayController.hide()
    }

    private func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController(
                onAppearanceChange: { [weak self] in self?.overlayController.refreshAppearance() },
                onBeginRecording: { [weak self] in self?.hotKeyManager.pause() },
                onHotKeyChange: { [weak self] spec in self?.hotKeyManager.apply(spec) },
            )
        }
        settingsWindow?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

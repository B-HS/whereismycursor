import AppKit

final class OverlayController {
    private struct PanelPair {
        let panel: OverlayPanel
        let view: OverlayView
    }

    private var panels: [ObjectIdentifier: (NSScreen, PanelPair)] = [:]
    private var mouseMonitor: Any?
    private var localMonitor: Any?
    private var isVisible = false
    private var screenObserver: ScreenObserver?
    private let settings = AppSettings.shared

    func toggle() {
        isVisible ? hide() : show()
    }

    func show() {
        guard !isVisible else { return }
        isVisible = true
        rebuildPanels()
        installMouseTracking()
        screenObserver = ScreenObserver { [weak self] in
            self?.rebuildPanels()
        }
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        for (_, pair) in panels.values {
            pair.panel.orderOut(nil)
        }
        panels.removeAll()
        removeMouseTracking()
        screenObserver = nil
    }

    func refreshAppearance() {
        guard isVisible else { return }
        let image = loadPatternImage()
        for (_, pair) in panels.values {
            pair.view.apply(
                color: settings.overlayColor,
                opacity: settings.opacity,
                image: image,
                useImage: settings.usePattern,
            )
        }
        updateCursorPosition()
    }

    private func rebuildPanels() {
        let targetScreens: [NSScreen] = settings.coverAllScreens
            ? NSScreen.screens
            : (currentCursorScreen().map { [$0] } ?? [])

        let currentIds = Set(targetScreens.map { ObjectIdentifier($0) })

        for (id, entry) in panels where !currentIds.contains(id) {
            entry.1.panel.orderOut(nil)
            panels.removeValue(forKey: id)
        }

        let image = loadPatternImage()
        for screen in targetScreens {
            let id = ObjectIdentifier(screen)
            let frame = screen.frame
            if let existing = panels[id] {
                existing.1.panel.setFrame(frame, display: true)
                existing.1.view.apply(
                    color: settings.overlayColor,
                    opacity: settings.opacity,
                    image: image,
                    useImage: settings.usePattern,
                )
            } else {
                let panel = OverlayPanel(contentRect: frame)
                let view = OverlayView(frame: NSRect(origin: .zero, size: frame.size))
                view.apply(
                    color: settings.overlayColor,
                    opacity: settings.opacity,
                    image: image,
                    useImage: settings.usePattern,
                )
                panel.contentView = view
                panel.setFrame(frame, display: false)
                panel.orderFrontRegardless()
                panels[id] = (screen, PanelPair(panel: panel, view: view))
            }
        }
        updateCursorPosition()
    }

    private func currentCursorScreen() -> NSScreen? {
        let point = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(point, $0.frame, false) }
    }

    private func loadPatternImage() -> NSImage? {
        guard settings.usePattern, let path = settings.patternImagePath else { return nil }
        return NSImage(contentsOfFile: path)
    }

    private func installMouseTracking() {
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) { [weak self] _ in
            self?.updateCursorPosition()
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]) { [weak self] event in
            self?.updateCursorPosition()
            return event
        }
        updateCursorPosition()
    }

    private func removeMouseTracking() {
        if let token = mouseMonitor { NSEvent.removeMonitor(token) }
        if let token = localMonitor { NSEvent.removeMonitor(token) }
        mouseMonitor = nil
        localMonitor = nil
    }

    private func updateCursorPosition() {
        let globalPoint = NSEvent.mouseLocation

        if !settings.coverAllScreens {
            if let cursorScreen = currentCursorScreen(),
               panels[ObjectIdentifier(cursorScreen)] == nil {
                rebuildPanels()
                return
            }
        }

        for (_, pair) in panels.values {
            let origin = pair.panel.frame.origin
            let local = CGPoint(
                x: globalPoint.x - origin.x,
                y: globalPoint.y - origin.y,
            )
            pair.view.update(cursorPoint: local, radius: settings.radius)
        }
    }
}

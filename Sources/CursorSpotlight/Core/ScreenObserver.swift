import AppKit

final class ScreenObserver {
    private var token: NSObjectProtocol?

    init(onChange: @escaping () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in onChange() }
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

import Foundation
import ServiceManagement

enum LoginItemManager {
    static func sync(enabled: Bool) {
        guard #available(macOS 13.0, *) else { return }
        let service = SMAppService.mainApp
        do {
            switch (enabled, service.status) {
            case (true, .notRegistered), (true, .notFound):
                try service.register()
            case (false, .enabled):
                try service.unregister()
            default:
                break
            }
        } catch {
            NSLog("[CursorSpotlight] LoginItem sync failed: \(error)")
        }
    }

    static var isEnabled: Bool {
        guard #available(macOS 13.0, *) else { return false }
        return SMAppService.mainApp.status == .enabled
    }
}

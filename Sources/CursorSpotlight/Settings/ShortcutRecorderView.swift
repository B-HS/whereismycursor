import AppKit
import Carbon.HIToolbox
import HotKey
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var spec: HotKeySpec
    let onBeginRecording: () -> Void
    let onEndRecording: (HotKeySpec) -> Void

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 8) {
            Button(action: toggleRecording) {
                Text(buttonLabel)
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 140)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.bordered)
            .tint(isRecording ? .accentColor : nil)

            if isRecording {
                Text(LocalizationManager.shared.localized("settings.shortcut.hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onDisappear { cancelRecording() }
    }

    private var buttonLabel: String {
        if isRecording {
            return LocalizationManager.shared.localized("settings.shortcut.recording")
        }
        return spec.displayString
    }

    private func toggleRecording() {
        if isRecording {
            cancelRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        onBeginRecording()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            handle(event: event)
            return nil
        }
    }

    private func handle(event: NSEvent) {
        if Int(event.keyCode) == kVK_Escape {
            cancelRecording()
            return
        }

        let mods = event.modifierFlags.intersection([.command, .option, .shift, .control])
        guard let key = Key(carbonKeyCode: UInt32(event.keyCode)) else {
            cancelRecording()
            return
        }

        let newSpec = HotKeySpec(key: key, modifiers: mods)
        finishRecording(with: newSpec)
    }

    private func finishRecording(with newSpec: HotKeySpec) {
        removeMonitor()
        isRecording = false
        spec = newSpec
        onEndRecording(newSpec)
    }

    private func cancelRecording() {
        guard isRecording || monitor != nil else { return }
        removeMonitor()
        isRecording = false
        onEndRecording(spec)
    }

    private func removeMonitor() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }
}

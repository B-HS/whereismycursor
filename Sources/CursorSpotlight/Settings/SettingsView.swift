import AppKit
import HotKey
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var localization: LocalizationManager = .shared
    let onAppearanceChange: () -> Void
    let onBeginRecording: () -> Void
    let onHotKeyChange: (HotKeySpec) -> Void

    var body: some View {
        Form {
            Section(header: Text(L("settings.section.appearance"))) {
                HStack {
                    Text(L("settings.radius"))
                    Slider(value: $settings.radius, in: 20 ... 400, step: 1)
                        .onChange(of: settings.radius) { _ in onAppearanceChange() }
                    Text("\(Int(settings.radius)) px")
                        .monospacedDigit()
                        .frame(width: 60, alignment: .trailing)
                }

                ColorPicker(
                    L("settings.color"),
                    selection: Binding(
                        get: { Color(nsColor: settings.overlayColor) },
                        set: { newValue in
                            settings.overlayColor = NSColor(newValue)
                            onAppearanceChange()
                        }
                    ),
                    supportsOpacity: true
                )

                HStack {
                    Text(L("settings.opacity"))
                    Slider(value: $settings.opacity, in: 0.1 ... 1.0)
                        .onChange(of: settings.opacity) { _ in onAppearanceChange() }
                    Text(String(format: "%.0f%%", settings.opacity * 100))
                        .monospacedDigit()
                        .frame(width: 60, alignment: .trailing)
                }

                Toggle(L("settings.pattern"), isOn: $settings.usePattern)
                    .onChange(of: settings.usePattern) { _ in onAppearanceChange() }

                if settings.usePattern {
                    HStack {
                        Text(settings.patternImagePath.map { ($0 as NSString).lastPathComponent } ?? L("settings.pattern.none"))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(L("settings.pattern.choose"), action: choosePattern)
                    }
                }
            }

            Section(header: Text(L("settings.section.behavior"))) {
                Toggle(L("settings.allScreens"), isOn: $settings.coverAllScreens)
                    .onChange(of: settings.coverAllScreens) { _ in onAppearanceChange() }
                Toggle(L("settings.launchAtLogin"), isOn: $settings.launchAtLogin)
            }

            Section(header: Text(L("settings.section.shortcut"))) {
                HStack {
                    Text(L("settings.hotkey"))
                    Spacer()
                    ShortcutRecorderView(
                        spec: $settings.hotKey,
                        onBeginRecording: onBeginRecording,
                        onEndRecording: onHotKeyChange
                    )
                }
            }

            Section(header: Text(L("settings.section.language"))) {
                Picker(L("settings.language"), selection: Binding(
                    get: { localization.current },
                    set: { localization.set($0) }
                )) {
                    ForEach(LocalizationManager.Language.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, idealWidth: 500, minHeight: 520, idealHeight: 560)
    }

    private func L(_ key: String) -> String {
        localization.localized(key)
    }

    private func choosePattern() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            settings.patternImagePath = panel.url?.path
            onAppearanceChange()
        }
    }
}

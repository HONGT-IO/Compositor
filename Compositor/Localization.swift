import AppKit

extension String {
    /// This English source string, in the language macOS is running the app in.
    /// A string with no entry in `Localizable.xcstrings` is left as it is.
    var localized: String {
        Bundle.main.localizedString(forKey: self, value: self, table: nil)
    }
}

/// The language the app runs in. With no choice here, macOS uses the list in System Settings.
enum AppLanguage: String {
    case system
    case english = "en"
    case simplified = "zh-Hans"
    case traditional = "zh-Hant"

    private static let choiceKey = "Compositor.language"

    /// What the Language menu shows as chosen.
    static var selected: AppLanguage {
        guard let raw = UserDefaults.standard.string(forKey: choiceKey),
              let language = AppLanguage(rawValue: raw) else { return .system }
        return language
    }

    /// Remembers the choice and opens the app again, so every window picks it up. Cancel leaves the current language.
    static func choose(_ language: AppLanguage) {
        guard language != selected else { return }
        let alert = NSAlert()
        alert.messageText = "Reopen Compositor to change the language.".localized
        alert.informativeText = "The windows you have open will close.".localized
        alert.addButton(withTitle: "Reopen".localized)
        alert.addButton(withTitle: "Cancel".localized)
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            UserDefaults.standard.removeObject(forKey: choiceKey)
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.set(language.rawValue, forKey: choiceKey)
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, error in
            if error == nil { NSApp.terminate(nil) }
        }
    }
}

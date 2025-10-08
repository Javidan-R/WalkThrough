import SwiftUI
import Combine

final class SettingsManager: ObservableObject {
    // Görünüş
    @AppStorage("themeMode") var themeMode: String = AppTheme.system.rawValue
    @AppStorage("fontSize") var fontSize: Double = 17.0
    @AppStorage("lineSpacing") var lineSpacing: Double = 1.4
    @AppStorage("textAlignment") var textAlignment: String = "Trailing"

    // Funksiyalar
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("hapticFeedback") var hapticFeedback: Bool = true
    @AppStorage("soundEffects") var soundEffects: Bool = true
    @AppStorage("autoSaveProgress") var autoSaveProgress: Bool = true
    @AppStorage("offlineMode") var offlineMode: Bool = false
    @AppStorage("cloudSync") var cloudSync: Bool = true
    @AppStorage("duaOfTheDay") var duaOfTheDay: Bool = false

    // Dil & Hədəf
    @AppStorage("appLanguage") var appLanguage: String = "AZ"
    @AppStorage("readingGoal") var readingGoal: Int = 10

    // İstifadəçi
    @AppStorage("username") var username: String = ""
    
    // Onboarding bayrağı
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false

    // Helper-lər
    var theme: AppTheme {
        get { AppTheme(rawValue: themeMode) ?? .system }
        set { themeMode = newValue.rawValue }
    }

    var alignment: TextAlignment {
        switch textAlignment {
        case "Leading": return .leading
        case "Center": return .center
        case "Justified": return .leading
        default: return .trailing
        }
    }
    
    func resetAll() {
        theme = .system
        fontSize = 17
        lineSpacing = 1.4
        textAlignment = "Trailing"
        notificationsEnabled = true
        hapticFeedback = true
        soundEffects = true
        autoSaveProgress = true
        offlineMode = false
        cloudSync = true
        duaOfTheDay = false
        appLanguage = "AZ"
        readingGoal = 10
        username = ""
        hasSeenIntro = false
    }
}

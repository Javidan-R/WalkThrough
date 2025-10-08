import SwiftUI

// Əsas tətbiq görünüşü.
@main
struct WalkthroughApp: App {
    @StateObject private var settings = SettingsManager()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(appState)
                .preferredColorScheme(settings.theme.colorScheme)
        }
    }
}

// MARK: - RootView (Intro / Main Flow)
struct RootView: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Group {
            if settings.hasSeenIntro {
                MainAppView()
            } else {
                IntroView()
            }
        }
    }
}

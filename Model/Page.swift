import SwiftUI

enum Page: String, CaseIterable {
    case page1 = "playstation.logo"
    case page2 = "gamecontroller.fill"
    case page3 = "link.icloud.fill"
    case page4 = "text.bubble.fill"

    var title: String {
        switch self {
        case .page1: return "Welcome to Playstation"
        case .page2: return "Game Controller"
        case .page3: return "Cloud Storage"
        case .page4: return "Connection with People"
        }
    }

    var subtitle: String {
        switch self {
        case .page1: return "Playstation is a video game console developed by Sony Computer Entertainment."
        case .page2: return "A game controller lets you experience the game at your fingertips."
        case .page3: return "Store and access your games on Playstation Cloud anywhere, anytime."
        case .page4: return "Connect with friends and family to play online."
        }
    }

    var gradient: [Color] {
        switch self {
        case .page1: return [.blue, .purple]
        case .page2: return [.orange, .pink]
        case .page3: return [.teal, .blue]
        case .page4: return [.green, .mint]
        }
    }

    var index: Int {
        Page.allCases.firstIndex(of: self) ?? 0
    }

    var next: Page {
        let idx = index + 1
        return idx < Page.allCases.count ? Page.allCases[idx] : self
    }

    var prev: Page {
        let idx = index - 1
        return idx >= 0 ? Page.allCases[idx] : self
    }
}

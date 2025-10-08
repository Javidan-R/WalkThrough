import SwiftUI

enum Page: String, CaseIterable {

        case page1 = "moon.stars.circle.fill"
        case page2 = "book.pages.fill"
        case page3 = "text.bubble.fill"
        case page4 = "lightbulb.fill"

    var title: String {
        switch self {
        case .page1: return "Bismillahir Rahmənir Rahim"
        case .page2: return "Qur'ani-Kərim"
        case .page3: return "Hədisi-Şəriflər"
        case .page4: return "İlmin Yolu"
        }
    }

    var subtitle: String {
        switch self {
        case .page1: return "Mərhəmətli və Rəhmli Allahın adı ilə. Qur'an və Hədisləri öyrənməyə xoş gəlmisiniz."
        case .page2: return "Allahın Kəlamı olan Qur'ani-Kərimi oxuyun, mənalarını dərk edin və hidayət yolunu tapın."
        case .page3: return "Peyğəmbərimizin (s.ə.s) sünnəsini öyrənin və hədislərdən həyatınıza işıq tutun."
        case .page4: return "İlm axtaran hər kəsə cənnət yolu açılır. Dərin biliklərlə İslam yolunda irəliləyin."
        }
    }

    var gradient: [Color] {
        switch self {
        case .page1: return [Color(hex: "0F4C3A"), Color(hex: "1B5E4B"), Color(hex: "267259")]  // İslam yaşılı
        case .page2: return [Color(hex: "1E3A5F"), Color(hex: "2C5282"), Color(hex: "3A6BA5")]  // Dərin göy
        case .page3: return [Color(hex: "6B4423"), Color(hex: "8B5E34"), Color(hex: "A67C52")]  // Qədim qızıl
        case .page4: return [Color(hex: "2D5A4A"), Color(hex: "3E7563"), Color(hex: "4F8F7C")]  // Təbii yaşıl
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

// Hex rəng dəstəyi üçün extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

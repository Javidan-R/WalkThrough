//
//  AppState.swift
//  Walkthrough
//
//  Created by Abdullah on 13.08.25.
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark  = "Dark"
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}


// Qlobal AppState – lazım olan yüngül router bayraqları üçün
final class AppState: ObservableObject {
    @Published var showSettingsSheet: Bool = false
        @Published var favoriteBooks: [Book] = []
}

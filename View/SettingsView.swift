<<<<<<< HEAD
//
//  SettingsView.swift
//  Walkthrough
//
//  Created by Abdullah on 12.08.25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SettingsView()
}
=======
import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {
    enum Mode { case onboarding, modal }
    let mode: Mode
    var onDone: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsManager
    
    @State private var previewText: String = "Bismillahir-Rahmənir-Rahim — Nümunə mətn"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("İstifadəçi")) {
                    TextField("İstifadəçi adı", text: $settings.username)
                        .foregroundStyle(Color(.label))
                        .animation(.easeInOut, value: settings.username)
                    Picker("Dil", selection: $settings.appLanguage) {
                        Text("AZ").tag("AZ")
                        Text("EN").tag("EN")
                        Text("TR").tag("TR")
                    }
                }
                
                Section(header: Text("Mövzu")) {
                    Picker("Tema", selection: Binding(
                        get: { settings.theme },
                        set: { settings.theme = $0 }
                    )) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                   
                }
                
                Section(header: Text("Mətn & Oxu")) {
                    Stepper("Font ölçüsü: \(Int(settings.fontSize))", value: $settings.fontSize, in: 14...30)
                    Slider(value: $settings.lineSpacing, in: 1.0...2.0, step: 0.1) {
                        Text("Sətir aralığı")
                    } minimumValueLabel: { Text("1.0") } maximumValueLabel: { Text("2.0") }
                    
                    Picker("Hizalama", selection: $settings.textAlignment) {
                        Text("Sola").tag("Leading")
                        Text("Ortaya").tag("Center")
                        Text("Sağa").tag("Trailing")
                    }
                    .pickerStyle(.segmented)
                    
                }
                
                Section(header: Text("İslami Funksiyalar")) {
                    Toggle("Günlük Du'a", isOn: $settings.duaOfTheDay)
                    Stepper("Günlük oxu hədəfi: \(settings.readingGoal) dəq", value: $settings.readingGoal, in: 5...120, step: 5)
                }
                
                Section {
                    Button(role: .destructive) {
                        settings.resetAll()
                    } label: {
                        Text("Ayarları sıfırla")
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if mode == .modal {
                        Button("Bağla") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .onboarding ? "Başla" : "Bitdi") {
                        if mode == .onboarding {
                            onDone?()
                        } else {
                            dismiss()
                        }
                    }
                    .bold()
                }
            }
        }
    }
}
>>>>>>> 3c54132 (first commit)

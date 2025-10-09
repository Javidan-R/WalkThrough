import SwiftUI

struct SettingsView: View {
    enum Mode { case onboarding, modal }
    let mode: Mode
    var onDone: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var appLanguage = "AZ"
    @State private var theme: AppTheme = .light
    @State private var fontSize: Double = 18
    @State private var lineSpacing: Double = 1.5
    @State private var textAlignment = "Leading"
    @State private var duaOfTheDay = true
    @State private var readingGoal = 30

    // Yeni Qur’an app funksiyaları
    @State private var prayerNotifications = false
    @State private var qiblaCalibrated = false
    @State private var nightModeEnabled = false
    @State private var zikrReminders = true
    @State private var showWeeklyReport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - User Section
                    SectionHeader(title: "İstifadəçi")
                    VStack(spacing: 16) {
                        SettingsOptionCard(
                            icon: "person.crop.circle.fill",
                            title: "İstifadəçi Adı",
                            subtitle: username.isEmpty ? "Ad daxil edilməyib" : username
                        ) {
                            // profil redaktəsi
                        }

                        SettingsOptionCard(
                            icon: "globe",
                            title: "Dil Seçimi",
                            subtitle: languageLabel
                        ) {
                            // dil seçimi üçün action sheet
                        }
                    }

                    // MARK: - Theme Section
                    SectionHeader(title: "Görünüş")
                    VStack(spacing: 16) {
                        SettingsOptionCard(
                            icon: "sun.max.fill",
                            title: "Tema",
                            subtitle: themeLabel
                        ) {
                            // tema dəyişmə
                        }

                        SettingsOptionCard(
                            icon: "moon.stars.fill",
                            title: "Gecə Rejimi (Qur’an)",
                            subtitle: nightModeEnabled ? "Aktiv" : "Passiv"
                        ) {
                            nightModeEnabled.toggle()
                        }
                    }

                    // MARK: - Reading Preferences
                    SectionHeader(title: "Oxu Parametrləri")
                    VStack(spacing: 16) {
                        SettingsOptionCard(
                            icon: "textformat.size",
                            title: "Font Ölçüsü",
                            subtitle: "\(Int(fontSize)) pt"
                        ) {
                            fontSize += 1
                            if fontSize > 30 { fontSize = 14 }
                        }

                        SettingsOptionCard(
                            icon: "text.alignleft",
                            title: "Hizalama",
                            subtitle: alignmentLabel
                        ) {
                            cycleAlignment()
                        }

                        SettingsOptionCard(
                            icon: "book.fill",
                            title: "Günlük Oxu Hədəfi",
                            subtitle: "\(readingGoal) dəq"
                        ) {
                            readingGoal = (readingGoal + 10) > 120 ? 10 : readingGoal + 10
                        }
                    }

                    // MARK: - Islamic Functionalities
                    SectionHeader(title: "İslami Funksiyalar")
                    VStack(spacing: 16) {
                        SettingsOptionCard(
                            icon: "bell.fill",
                            title: "Namaz Vaxtı Bildirişi",
                            subtitle: prayerNotifications ? "Aktiv" : "Passiv"
                        ) {
                            prayerNotifications.toggle()
                        }

                        SettingsOptionCard(
                            icon: "location.north.fill",
                            title: "Qiblə Kalibrasiyası",
                            subtitle: qiblaCalibrated ? "Kalibr olunub" : "Kalibr edilməyib"
                        ) {
                            qiblaCalibrated.toggle()
                        }

                        SettingsOptionCard(
                            icon: "sparkles",
                            title: "Zikr Xatırlatıcısı",
                            subtitle: zikrReminders ? "Aktiv" : "Passiv"
                        ) {
                            zikrReminders.toggle()
                        }

                        SettingsOptionCard(
                            icon: "chart.bar.fill",
                            title: "Həftəlik Oxu Hesabatı",
                            subtitle: "Statistikanı göstər"
                        ) {
                            showWeeklyReport.toggle()
                        }
                        .sheet(isPresented: $showWeeklyReport) {
                            WeeklyReportView()
                                .presentationDetents([.medium])
                        }

                        SettingsOptionCard(
                            icon: "heart.text.square.fill",
                            title: "Günlük Du'a",
                            subtitle: duaOfTheDay ? "Aktiv" : "Passiv"
                        ) {
                            duaOfTheDay.toggle()
                        }
                    }

                    // MARK: - Reset Button
                    Button(role: .destructive) {
                        resetSettings()
                    } label: {
                        Text("Ayarları Sıfırla")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.05), .green.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Tənzimləmələr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if mode == .modal {
                        Button("Bağla") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .onboarding ? "Başla" : "Bitdi") {
                        if mode == .onboarding { onDone?() }
                        else { dismiss() }
                    }
                    .bold()
                }
            }
        }
    }

    // MARK: - Helpers
    private var languageLabel: String {
        switch appLanguage {
        case "AZ": return "Azərbaycan"
        case "EN": return "English"
        case "TR": return "Türkçe"
        default: return "Azərbaycan"
        }
    }

    private var themeLabel: String {
        switch theme {
        case .light: return "İşıq"
        case .dark: return "Tünd"
        case .system: return "Avtomatik"
        }
    }

    private var alignmentLabel: String {
        switch textAlignment {
        case "Leading": return "Sola"
        case "Center": return "Ortaya"
        case "Trailing": return "Sağa"
        default: return "Sola"
        }
    }

    private func cycleAlignment() {
        if textAlignment == "Leading" { textAlignment = "Center" }
        else if textAlignment == "Center" { textAlignment = "Trailing" }
        else { textAlignment = "Leading" }
    }

    private func resetSettings() {
        username = ""
        fontSize = 18
        lineSpacing = 1.5
        duaOfTheDay = true
        readingGoal = 30
        prayerNotifications = false
        qiblaCalibrated = false
        nightModeEnabled = false
        zikrReminders = true
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 5)
    }
}

struct WeeklyReportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("📖 Həftəlik Qur’an Oxu Hesabatı")
                .font(.title2.bold())
            Text("Bu həftə: 3 surə, 48 ayə oxundu")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }
}


// MARK: - Settings Option Card
struct SettingsOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

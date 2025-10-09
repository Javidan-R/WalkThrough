import SwiftUI
import AVKit
import AVFoundation

struct ReaderView: View {
    @Environment(\.dismiss) private var dismiss

    // Reading parameters
    @State private var fontSize: CGFloat = 20
    @State private var fontName: String = "Helvetica"
    @State private var fontWeight: Font.Weight = .regular
    @State private var lineSpacing: CGFloat = 8
    @State private var textAlignment: TextAlignment = .trailing
    @State private var readingDirection: LayoutDirection = .rightToLeft
    @State private var showHadithDetails = true
    @State private var theme: Theme = .normal
    @State private var customColor: Color = .green
    @State private var selectedHadithID: String?

    // Bookmarks
    @State private var hadithBookmarks: Set<String> = []
    @State private var ayahBookmarks: Set<String> = []
    @State private var bookBookmarks: Set<String> = []

    // Settings
    @State private var hapticFeedbackEnabled = true
    @State private var keepScreenAwake = true
    @State private var speakerRate: Float = 0.5
    @State private var showHadithNumber = true
    @State private var showProgressBar = true
    @State private var showNarratorAndSource = true

    // NEW: Advanced features
    @State private var autoScrollEnabled = false
    @State private var autoScrollSpeed: Double = 2.0
    @State private var dictionaryEnabled = false
    @State private var notesEnabled = false
    @State private var readingSessionTime: Int = 0
    @State private var showReadingTimer = false
    @State private var timerInterval: Timer?

    // Audio
    @State private var player: AVSpeechSynthesizer?
    @State private var isPlayingAudioForHadithID: String?

    // Sheets
    @State private var showSettingsSheet = false
    @State private var showBookmarksSheet = false
    @State private var showSessionStats = false

    private var progress: Double {
        guard let index = hadiths.firstIndex(where: { $0.id == selectedHadithID }) else { return 0 }
        return Double(index + 1) / Double(hadiths.count)
    }

    private func generateHapticFeedback() {
        if hapticFeedbackEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    enum Theme: String, CaseIterable, Identifiable {
        case normal = "Normal"
        case dark = "Tünd"
        case sepia = "Sepia"
        case custom = "Fərdi"

        var id: String { rawValue }

        var backgroundColor: Color {
            switch self {
            case .normal: return Color.white
            case .dark: return Color.black
            case .sepia: return Color(red: 0.96, green: 0.91, blue: 0.76)
            case .custom: return Color(uiColor: .systemBackground)
            }
        }

        var textColor: Color {
            switch self {
            case .normal: return Color.black
            case .dark: return Color.white
            case .sepia: return Color(red: 0.3, green: 0.2, blue: 0.1)
            case .custom: return Color(uiColor: .label)
            }
        }

        func accentColor(_ customColor: Color) -> Color {
            switch self {
            case .dark: return .yellow
            case .custom: return customColor
            default: return .green
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.backgroundColor.edgesIgnoringSafeArea(.all)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: alignmentForReadingDirection, spacing: lineSpacing + 1) {
                        ForEach(hadiths) { hadith in
                            hadithRow(hadith)
                                .onTapGesture {
                                    generateHapticFeedback()
                                    withAnimation {
                                        selectedHadithID = hadith.id
                                        proxy.scrollTo(hadith.id, anchor: .center)
                                        showProgressBar = true
                                    }
                                }
                        }
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 80)
                    .padding(.horizontal)
                    .environment(\.layoutDirection, readingDirection)
                    .onChange(of: selectedHadithID) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showProgressBar = false
                            }
                        }
                    }
                }
            }

            // NEW: Top blur overlay (2-3%)
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        theme.backgroundColor.opacity(0.95),
                        theme.backgroundColor.opacity(0.8),
                        theme.backgroundColor.opacity(0.5),
                        theme.backgroundColor.opacity(0.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)

                Spacer()
            }
            .allowsHitTesting(false)

            // Top header with glass effect
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(theme.accentColor(customColor))
                                .padding(8)
                                .background(theme.accentColor(customColor).opacity(0.15))
                                .clipShape(Circle())
                        }
                        .frame(width: 44, height: 44)

                        // NEW: Reading timer
                        if showReadingTimer {
                            HStack(spacing: 6) {
                                Image(systemName: "timer")
                                    .font(.caption2)
                                Text(formatTime(readingSessionTime))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(theme.accentColor(customColor))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(theme.accentColor(customColor).opacity(0.1))
                            .cornerRadius(10)
                        }

                        Spacer()

                        // Quick action buttons
                        HStack(spacing: 8) {
                            Button(action: { showReadingTimer.toggle() }) {
                                Image(systemName: showReadingTimer ? "timer.circle.fill" : "timer.circle")
                                    .font(.title3)
                                    .foregroundColor(theme.accentColor(customColor))
                                    .padding(8)
                                    .background(theme.accentColor(customColor).opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .frame(width: 44, height: 44)

                            Button(action: { showBookmarksSheet = true }) {
                                Image(systemName: "bookmark.fill")
                                    .font(.title3)
                                    .foregroundColor(theme.accentColor(customColor))
                                    .padding(8)
                                    .background(theme.accentColor(customColor).opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .frame(width: 44, height: 44)

                            Button(action: { showSettingsSheet = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(theme.accentColor(customColor))
                                    .padding(8)
                                    .background(theme.accentColor(customColor).opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .opacity(0.95)
                        .edgesIgnoringSafeArea(.top)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .frame(maxHeight: .infinity, alignment: .top)

            // Progress bar with percentage
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Spacer()
                    if let index = hadiths.firstIndex(where: { $0.id == selectedHadithID }) {
                        Text("\(index + 1)/\(hadiths.count)")
                            .font(.caption2)
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
                .padding(.horizontal)

                ProgressView(value: progress, total: 1)
                    .tint(theme.accentColor(customColor))
                    .scaleEffect(y: 2)
            }
            .opacity(showProgressBar ? 1 : 0)
            .padding(.bottom, 80)
            .animation(.easeInOut, value: showProgressBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }

        .sheet(isPresented: $showSettingsSheet) {
            OptimizedSettingsSheet(
                fontSize: $fontSize,
                fontName: $fontName,
                fontWeight: $fontWeight,
                lineSpacing: $lineSpacing,
                textAlignment: $textAlignment,
                theme: $theme,
                customColor: $customColor,
                readingDirection: $readingDirection,
                showHadithDetails: $showHadithDetails,
                hapticFeedbackEnabled: $hapticFeedbackEnabled,
                keepScreenAwake: $keepScreenAwake,
                speakerRate: $speakerRate,
                showHadithNumber: $showHadithNumber,
                showNarratorAndSource: $showNarratorAndSource,
                autoScrollEnabled: $autoScrollEnabled,
                autoScrollSpeed: $autoScrollSpeed,
                dictionaryEnabled: $dictionaryEnabled,
                notesEnabled: $notesEnabled
            )
        }

        .sheet(isPresented: $showBookmarksSheet) {
            BookmarksView(
                hadithBookmarks: $hadithBookmarks,
                ayahBookmarks: $ayahBookmarks,
                bookBookmarks: $bookBookmarks,
                hadiths: hadiths,
                ayahs: ayahs,
                books: books
            )
        }

        .sheet(isPresented: $showSessionStats) {
            SessionStatsSheet(readingTime: readingSessionTime, hadithsRead: hadiths.count)
        }

        .onAppear {
            player = AVSpeechSynthesizer()
            UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
            if showReadingTimer {
                startReadingTimer()
            }
        }
        .onDisappear {
            player?.stopSpeaking(at: .immediate)
            player = nil
            UIApplication.shared.isIdleTimerDisabled = false
            timerInterval?.invalidate()
        }
        .onChange(of: keepScreenAwake) { value in
            UIApplication.shared.isIdleTimerDisabled = value
        }
        .onChange(of: showReadingTimer) { value in
            if value {
                startReadingTimer()
            } else {
                timerInterval?.invalidate()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Hadith Row
    private func hadithRow(_ hadith: Hadith) -> some View {
        VStack(alignment: alignmentForReadingDirection, spacing: 10) {
            Text(showHadithNumber ?
                "Hədis \(hadiths.firstIndex(where: { $0.id == hadith.id })! + 1). \(hadith.text)" :
                hadith.text)
                .font(.custom(fontName, size: fontSize))
                .fontWeight(fontWeight)
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(textAlignment)

            if showNarratorAndSource {
                Text("Nəql edən: \(hadith.narrator) | Mənbə: \(hadith.source)")
                    .font(.footnote)
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(textAlignment)
            }

            if showHadithDetails {
                HStack(spacing: 12) {
                    Spacer()

                    Button(action: {
                        generateHapticFeedback()
                        if hadithBookmarks.contains(hadith.id) {
                            hadithBookmarks.remove(hadith.id)
                        } else {
                            hadithBookmarks.insert(hadith.id)
                        }
                    }) {
                        Image(systemName: hadithBookmarks.contains(hadith.id) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(hadithBookmarks.contains(hadith.id) ? .yellow : theme.accentColor(customColor))
                    }

                    Button(action: {
                        generateHapticFeedback()
                        toggleAudio(for: hadith)
                    }) {
                        Image(systemName: isPlayingAudioForHadithID == hadith.id ? "pause.circle.fill" : "play.circle.fill")
                            .foregroundColor(theme.accentColor(customColor))
                    }

                    // NEW: Dictionary button
                    if dictionaryEnabled {
                        Button(action: {}) {
                            Image(systemName: "book.circle")
                                .foregroundColor(theme.accentColor(customColor))
                        }
                    }

                    // NEW: Notes button
                    if notesEnabled {
                        Button(action: {}) {
                            Image(systemName: "note.text")
                                .foregroundColor(theme.accentColor(customColor))
                        }
                    }

                    Button(action: {
                        generateHapticFeedback()
                        UIPasteboard.general.string = hadith.text
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(theme.accentColor(customColor))
                    }

                    Button(action: {
                        generateHapticFeedback()
                        share(text: hadith.text)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(theme.accentColor(customColor))
                    }
                }
                .font(.title2)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(selectedHadithID == hadith.id ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(selectedHadithID == hadith.id ? theme.accentColor(customColor).opacity(0.2) : Color.clear)
        .cornerRadius(15)
        .id(hadith.id)
    }

    // MARK: - Functions
    private func toggleAudio(for hadith: Hadith) {
        guard let player = player else { return }

        if isPlayingAudioForHadithID == hadith.id {
            player.stopSpeaking(at: .immediate)
            isPlayingAudioForHadithID = nil
        } else {
            if player.isSpeaking {
                player.stopSpeaking(at: .immediate)
            }

            let utterance = AVSpeechUtterance(string: hadith.text)
            utterance.voice = AVSpeechSynthesisVoice(language: "az-AZ")
            utterance.rate = speakerRate
            player.speak(utterance)
            isPlayingAudioForHadithID = hadith.id
        }
    }

    private func share(text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

    private var alignmentForReadingDirection: HorizontalAlignment {
        return readingDirection == .rightToLeft ? .trailing : .leading
    }

    // NEW: Timer functions
    private func startReadingTimer() {
        timerInterval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            readingSessionTime += 1
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Optimized Settings Sheet
struct OptimizedSettingsSheet: View {
    @Binding var fontSize: CGFloat
    @Binding var fontName: String
    @Binding var fontWeight: Font.Weight
    @Binding var lineSpacing: CGFloat
    @Binding var textAlignment: TextAlignment
    @Binding var theme: ReaderView.Theme
    @Binding var customColor: Color
    @Binding var readingDirection: LayoutDirection
    @Binding var showHadithDetails: Bool
    @Binding var hapticFeedbackEnabled: Bool
    @Binding var keepScreenAwake: Bool
    @Binding var speakerRate: Float
    @Binding var showHadithNumber: Bool
    @Binding var showNarratorAndSource: Bool
    @Binding var autoScrollEnabled: Bool
    @Binding var autoScrollSpeed: Double
    @Binding var dictionaryEnabled: Bool
    @Binding var notesEnabled: Bool

    @Environment(\.dismiss) private var dismiss

    private let availableFonts = ["Helvetica", "Times New Roman", "Cochin", "Georgia", "Arial"]

    private var accentColorForTheme: Color {
        return theme == .custom ? customColor : theme.accentColor(customColor)
    }

    private func resetToDefaults() {
        fontSize = 20
        fontName = "Helvetica"
        fontWeight = .regular
        lineSpacing = 8
        textAlignment = .trailing
        theme = .normal
        customColor = .green
        readingDirection = .rightToLeft
        showHadithDetails = true
        hapticFeedbackEnabled = true
        keepScreenAwake = true
        speakerRate = 0.5
        showHadithNumber = true
        showNarratorAndSource = true
        autoScrollEnabled = false
        autoScrollSpeed = 2.0
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Mətn Ayarları") {
                    Picker("Font Tipi", selection: $fontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }

                    HStack {
                        Text("Ölçü")
                        Spacer()
                        Text(String(format: "%.0f", fontSize))
                            .fontWeight(.semibold)
                    }
                    Slider(value: $fontSize, in: 14...32, step: 1)
                        .tint(accentColorForTheme)

                    HStack {
                        Text("Sətir aralığı")
                        Spacer()
                        Text(String(format: "%.0f", lineSpacing))
                            .fontWeight(.semibold)
                    }
                    Slider(value: $lineSpacing, in: 4...20, step: 1)
                        .tint(accentColorForTheme)
                }

                Section("Görünüş") {
                    Picker("Tema", selection: $theme) {
                        ForEach(ReaderView.Theme.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }

                    if theme == .custom {
                        ColorPicker("Rəng", selection: $customColor)
                    }
                }

                Section("Oxuma Seçenekləri") {
                    Toggle("Sağdan-sola", isOn: Binding(
                        get: { readingDirection == .rightToLeft },
                        set: { readingDirection = $0 ? .rightToLeft : .leftToRight }
                    ))
                    .tint(accentColorForTheme)

                    Toggle("Hədis nömrəsi", isOn: $showHadithNumber)
                        .tint(accentColorForTheme)

                    Toggle("Nəql edən/Mənbə", isOn: $showNarratorAndSource)
                        .tint(accentColorForTheme)
                }

                Section("Səs İşlətmə") {
                    HStack {
                        Text("Sürət")
                        Spacer()
                        Text(String(format: "%.1f", speakerRate))
                            .fontWeight(.semibold)
                    }
                    Slider(value: $speakerRate, in: 0.1...1.0, step: 0.1)
                        .tint(accentColorForTheme)
                }

                Section("Əlavə Xüsusiyyətlər") {
                    Toggle("Avtomatik sürüşdürmə", isOn: $autoScrollEnabled)
                        .tint(accentColorForTheme)

                    if autoScrollEnabled {
                        HStack {
                            Text("Sürət")
                            Spacer()
                            Text(String(format: "%.1f", autoScrollSpeed))
                                .fontWeight(.semibold)
                        }
                        Slider(value: $autoScrollSpeed, in: 0.5...5.0, step: 0.5)
                            .tint(accentColorForTheme)
                    }

                    Toggle("Lüğət", isOn: $dictionaryEnabled)
                        .tint(accentColorForTheme)

                    Toggle("Qeydlər", isOn: $notesEnabled)
                        .tint(accentColorForTheme)
                }

                Section("Sistem") {
                    Toggle("Haptik umpuluz", isOn: $hapticFeedbackEnabled)
                        .tint(accentColorForTheme)

                    Toggle("Ekran fəal qalacaq", isOn: $keepScreenAwake)
                        .tint(accentColorForTheme)
                }

                Section {
                    Button("Sıfırla", action: resetToDefaults)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Tənzimləmələr")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitdi") { dismiss() }
                        .bold()
                        .foregroundColor(accentColorForTheme)
                }
            }
        }
    }
}

// MARK: - Session Stats Sheet
struct SessionStatsSheet: View {
    let readingTime: Int
    let hadithsRead: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(String(format: "%02d:%02d", (readingTime % 3600) / 60, readingTime % 60))
                            .font(.system(size: 40, weight: .bold))
                        Text("Oxuma müddəti")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    VStack(spacing: 8) {
                        Text("\(hadithsRead)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Hədislər")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                Spacer()
            }
            .padding()
            .navigationTitle("Oxuma Statistikası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitdi") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Helpers
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

struct BookmarksView: View {
    @Binding var hadithBookmarks: Set<String>
    @Binding var ayahBookmarks: Set<String>
    @Binding var bookBookmarks: Set<String>

    let hadiths: [Hadith]
    let ayahs: [Ayah]
    let books: [Book]

    @Environment(\.dismiss) private var dismiss

    var bookmarkedHadiths: [Hadith] {
        hadiths.filter { hadithBookmarks.contains($0.id) }
    }

    var bookmarkedBooks: [Book] {
        books.filter { bookBookmarks.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            List {
                if !bookmarkedHadiths.isEmpty {
                    Section("Yadda Saxlanılan Hədislər") {
                        ForEach(bookmarkedHadiths) { hadith in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(hadith.text)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("Nəql edən: \(hadith.narrator)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                if !bookmarkedBooks.isEmpty {
                    Section("Yadda Saxlanılan Kitablar") {
                        ForEach(bookmarkedBooks) { book in
                            HStack {
                                Image(book.thumbnail)
                                    .resizable()
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(8)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                if bookmarkedHadiths.isEmpty && bookmarkedBooks.isEmpty {
                    Text("Yadda saxlanılan element yoxdur")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Yadda Saxlanılanlar")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitdi") { dismiss() }
                }
            }
        }
    }
}

struct ReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ReaderView()
    }
}

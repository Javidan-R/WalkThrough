import SwiftUI
<<<<<<< HEAD
import AVKit

struct ReaderView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var fontSize: CGFloat = 18
    @State private var isDarkTheme = false
    @State private var searchText = ""
    @State private var bookmarks: [Int] = [] // Page numbers
    @State private var notes: [Int: String] = [:] // Page: Note
    @State private var highlights: [Int: Bool] = [:] // Page: Highlighted
    @State private var currentPage = 1
    @State private var showNotes = false
    @State private var noteText = ""
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showTOC = false

    private let bookContent = Array(repeating: "This is a sample page of text for \(books.first?.title ?? "the book"). ", count: 100).joined(separator: "\n\n")

    var filteredContent: String {
        if searchText.isEmpty {
            return bookContent
        } else {
            return bookContent.components(separatedBy: "\n\n")
                .filter { $0.lowercased().contains(searchText.lowercased()) }
                .joined(separator: "\n\n")
=======
import AVFoundation

// MARK: - ReaderView

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
    
    // Unified Bookmarks - Store IDs for Hadith, Ayah, and Book
    @State private var hadithBookmarks: Set<String> = []
    @State private var ayahBookmarks: Set<String> = []
    @State private var bookBookmarks: Set<String> = []

    // Additional settings
    @State private var hapticFeedbackEnabled = true
    @State private var keepScreenAwake = true
    @State private var speakerRate: Float = 0.5
    @State private var showHadithNumber = true
    @State private var showProgressBar = true
    @State private var showNarratorAndSource = true

    // Audio for AVSpeechSynthesizer
    @State private var player: AVSpeechSynthesizer?
    @State private var isPlayingAudioForHadithID: String?

    // Settings sheet state
    @State private var showSettingsSheet = false
    @State private var showBookmarksSheet = false

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
>>>>>>> 3c54132 (first commit)
        }
    }

    var body: some View {
<<<<<<< HEAD
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(book.title)
                        .serifText(.title, weight: .bold)
                        .padding(.horizontal)
                    Text("Page \(currentPage)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Text(filteredContent)
                        .serifText(.body, weight: .regular)
                        .font(.system(size: fontSize))
                        .lineSpacing(8)
                        .foregroundColor(isDarkTheme ? .white : .black)
                        .padding(.horizontal)
                        .background(highlights[currentPage] == true ? Color.yellow.opacity(0.3) : Color.clear)
                        .onTapGesture {
                            highlights[currentPage]?.toggle()
                        }
                    if showNotes {
                        TextField("Add note for page \(currentPage)", text: $noteText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        Button("Save Note") {
                            notes[currentPage] = noteText
                            noteText = ""
                            showNotes = false
                        }
                        .padding(.horizontal)
                    }
                    if let note = notes[currentPage] {
                        Text("Note: \(note)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(isDarkTheme ? Color.gray.opacity(0.9) : Color.white)
            .navigationTitle(book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .accessibilityLabel("Close")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        bookmarks.append(currentPage)
                    }) {
                        Image(systemName: "bookmark.fill")
                            .accessibilityLabel("Bookmark Page")
                    }
                    Button(action: {
                        showNotes.toggle()
                    }) {
                        Image(systemName: "note.text")
                            .accessibilityLabel("Add Note")
                    }
                    Button(action: {
                        highlights[currentPage]?.toggle()
                    }) {
                        Image(systemName: "highlighter")
                            .accessibilityLabel("Highlight Text")
                    }
                    Menu {
                        Button(action: { fontSize += 2 }) { Text("Increase Font Size") }
                        Button(action: { fontSize = max(12, fontSize - 2) }) { Text("Decrease Font Size") }
                    } label: {
                        Image(systemName: "textformat.size")
                            .accessibilityLabel("Adjust Font Size")
                    }
                    Button(action: {
                        isDarkTheme.toggle()
                    }) {
                        Image(systemName: isDarkTheme ? "sun.max" : "moon")
                            .accessibilityLabel("Toggle Theme")
                    }
                    Button(action: {
                        showTOC.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .accessibilityLabel("Table of Contents")
                    }
                    Button(action: {
                        if isPlaying {
                            player?.pause()
                        } else {
                            if let url = URL(string: "https://example.com/quran-audio.mp3") {
                                player = AVPlayer(url: url)
                                player?.play()
                            }
                        }
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                            .accessibilityLabel(isPlaying ? "Pause Audio" : "Play Audio")
                    }
                    Button(action: {
                        let textToShare = bookContent.components(separatedBy: "\n\n")[currentPage - 1]
                        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel("Share Passage")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search in Book")
            .sheet(isPresented: $showTOC) {
                List {
                    ForEach(1...10, id: \.self) { chapter in
                        Button("Chapter \(chapter)") {
                            currentPage = chapter * 10
                            showTOC = false
                        }
                    }
                }
                .navigationTitle("Table of Contents")
            }
            .onChange(of: currentPage) { _, _ in
                print("Reading progress: \(currentPage / 100 * 100)%")
=======
        ZStack(alignment: .bottom) {
            // Background color
            theme.backgroundColor.edgesIgnoringSafeArea(.all)

            // Main reading area
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
                    .padding(.top, 60) // Increased padding for the glass effect header
                    .padding(.bottom, 60)
                    .padding(.horizontal)
                    .environment(\.layoutDirection, readingDirection)
                    .onChange(of: selectedHadithID) { _ in
                        // Hides progress bar after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showProgressBar = false
                            }
                        }
                    }
                }
            }

            // Top bar with glass effect
            VStack(spacing: 0) {
                // Glass effect layer
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor(theme.accentColor(customColor))
                                .padding(8)
                                .background(theme.accentColor(customColor).opacity(0.10))
                                .clipShape(Circle())
                        }
                        .frame(width: 44, height: 44)

                        Spacer()
                        
                        Button(action: {
                            generateHapticFeedback()
                            showBookmarksSheet = true
                        }) {
                            Image(systemName: "bookmark.fill")
                                .font(.title2)
                                .foregroundColor(theme.accentColor(customColor))
                                .padding(8)
                                .background(theme.accentColor(customColor).opacity(0.10))
                                .clipShape(Circle())
                        }
                        .frame(width: 44, height: 44)
                        
                        Button(action: {
                            generateHapticFeedback()
                            showSettingsSheet = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(theme.accentColor(customColor))
                                .padding(8)
                                .background(theme.accentColor(customColor).opacity(0.10))
                                .clipShape(Circle())
                        }
                        .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                        .opacity(0.9)
                        .edgesIgnoringSafeArea(.all)
                )
            }
            
            .frame(maxHeight: .infinity, alignment: .bottom)

            // Bottom progress bar
            VStack {
                ProgressView(value: progress, total: 1)
                    .tint(theme.accentColor(customColor))
            }
            .opacity(showProgressBar ? 1 : 0)
            .padding(.bottom, 60)
            .animation(.easeInOut, value: showProgressBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheet(
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
                showNarratorAndSource: $showNarratorAndSource
            )
        }
        
        // New sheet for bookmarks
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
        
        .onAppear {
            player = AVSpeechSynthesizer()
            UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
        }
        .onDisappear {
            player?.stopSpeaking(at: .immediate)
            player = nil
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: keepScreenAwake) { value in
            UIApplication.shared.isIdleTimerDisabled = value
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helper Views

    private func hadithRow(_ hadith: Hadith) -> some View {
        VStack(alignment: alignmentForReadingDirection, spacing: 10) {
            Text(showHadithNumber ? "Hədis \(hadiths.firstIndex(where: { $0.id == hadith.id })! + 1). \(hadith.text)" : hadith.text)
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
                HStack(spacing: 15) {
                    Spacer()
                    // Bookmark button
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

                    // Play/Pause button
                    Button(action: {
                        generateHapticFeedback()
                        toggleAudio(for: hadith)
                    }) {
                        Image(systemName: isPlayingAudioForHadithID == hadith.id ? "pause.circle.fill" : "play.circle.fill")
                            .foregroundColor(theme.accentColor(customColor))
                    }

                    // Copy button
                    Button(action: {
                        generateHapticFeedback()
                        UIPasteboard.general.string = hadith.text
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(theme.accentColor(customColor))
                    }

                    // Share button
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
            utterance.voice = AVSpeechSynthesisVoice(language: "az-AZ") // Using Azerbaijani voice if available
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
}

// MARK: - Glass effect helper view
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
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

    @Environment(\.dismiss) private var dismiss
    
    private let availableFonts = ["Helvetica", "Times New Roman", "Cochin", "Georgia"]
    
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
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Font və Mətn Ayarları")) {
                    Picker("Font Qalınlığı", selection: $fontWeight) {
                        Text("Normal").tag(Font.Weight.regular)
                        Text("Yarımqalın").tag(Font.Weight.semibold)
                    }
                    
                    Picker("Mətn Hizalanması", selection: $textAlignment) {
                        Text("Sola").tag(TextAlignment.leading)
                        Text("Ortaya").tag(TextAlignment.center)
                        Text("Sağa").tag(TextAlignment.trailing)
                    }
                    
                    VStack(spacing: 15) {
                        Text("Font Ölçüsü").font(.subheadline)
                        HStack {
                            Text("A").font(.system(size: 14))
                            Slider(value: $fontSize, in: 14...28, step: 2)
                                .tint(accentColorForTheme)
                            Text("A").font(.system(size: 28))
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text("Sətir Aralığı").font(.subheadline)
                        Slider(value: $lineSpacing, in: 4...14, step: 2)
                            .tint(accentColorForTheme)
                    }
                    
                    Picker("Font Tipi", selection: $fontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                }
                
                Section(header: Text("Oxu Ayarları")) {
                    Picker("Tema", selection: $theme) {
                        ForEach(ReaderView.Theme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    if theme == .custom {
                        ColorPicker("Fərdi Rəng Seç", selection: $customColor)
                    }
                    
                    Toggle("Sağdan sola oxu", isOn: Binding(
                        get: { readingDirection == .rightToLeft },
                        set: { readingDirection = $0 ? .rightToLeft : .leftToRight }
                    ))
                    .tint(accentColorForTheme)
                    
                    Toggle("Hədis detallarını göstər", isOn: $showHadithDetails)
                        .tint(accentColorForTheme)
                    
                    Toggle("Hədis nömrəsini göstər", isOn: $showHadithNumber)
                        .tint(accentColorForTheme)
                    
                    Toggle("Nəql edən və mənbəni göstər", isOn: $showNarratorAndSource)
                        .tint(accentColorForTheme)
                }
                
                Section(header: Text("Əlavə Ayarlar")) {
                    Toggle("Haptik geridönüşü aktiv et", isOn: $hapticFeedbackEnabled)
                        .tint(accentColorForTheme)
                    
                    Toggle("Oxuyarkən ekran sönməsin", isOn: $keepScreenAwake)
                        .tint(accentColorForTheme)
                    
                    VStack(spacing: 15) {
                        Text("Səsli oxu sürəti (\(String(format: "%.1f", speakerRate * 2.0)))")
                            .font(.subheadline)
                        Slider(value: $speakerRate, in: 0.1...1.0)
                            .tint(accentColorForTheme)
                    }
                }
                
                Section {
                    Button(action: {
                        resetToDefaults()
                    }) {
                        Text("Ayarları Sıfırla")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
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
>>>>>>> 3c54132 (first commit)
            }
        }
    }
}
<<<<<<< HEAD
=======

// MARK: - New: Bookmarks View

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
    
//    var bookmarkedAyahs: [Ayah] {
//        ayahs.filter { ayahBookmarks.contains($0.id) }
//    }
    
    var bookmarkedBooks: [Book] {
        books.filter { bookBookmarks.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            List {
                if !bookmarkedHadiths.isEmpty {
                    Section(header: Text("Yadda saxlanılan Hədislər")) {
                        ForEach(bookmarkedHadiths) { hadith in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(hadith.text)
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("Nəql edən: \(hadith.narrator) | Mənbə: \(hadith.source)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

//                if !bookmarkedAyahs.isEmpty {
//                    Section(header: Text("Yadda saxlanılan Ayələr")) {
//                        ForEach(bookmarkedAyahs) { ayah in
//                            VStack(alignment: .leading, spacing: 5) {
//                                Text(ayah.text)
//                                    .font(.body)
//                                    .fontWeight(.medium)
//                                Text("Surə: \(ayah.surah), Ayə: \(ayah.verse)")
//                                    .font(.footnote)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }

                if !bookmarkedBooks.isEmpty {
                    Section(header: Text("Yadda saxlanılan Kitablar")) {
                        ForEach(bookmarkedBooks) { book in
                            HStack {
                                Image(book.thumbnail)
                                    .resizable()
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
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
                    Text("Hələ yadda saxlanılan heç bir element yoxdur.")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Yadda saxlanılanlar")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitdi") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - Preview Provider

struct ReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ReaderView()
    }
}
>>>>>>> 3c54132 (first commit)

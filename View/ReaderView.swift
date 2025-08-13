import SwiftUI
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
        }
    }

    var body: some View {
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
            }
        }
    }
}

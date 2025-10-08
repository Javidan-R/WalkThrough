<<<<<<< HEAD
//
//  FavoritesView.swift
//  Walkthrough
//
//  Created by Abdullah on 13.08.25.
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    FavoritesView()
=======
import SwiftUI

struct FavoritesView: View {
    @State private var favoriteBooks: [Book] = books
    @State private var quotes: [String] = [
        "Elm axtarmaq hər bir müsəlmana vacibdir.",
        "Oxumaq düşüncəni genişləndirir.",
        "Bilgi gücdür."
    ]
    @State private var favoriteAyahs: [Ayah] = ayahs
    @State private var favoriteHadiths: [Hadith] = hadiths
    let book: Book
    let size: CGSize
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // MARK: - Books Slider
                    if !favoriteBooks.isEmpty {
                        SectionHeaderView(title: "Seçilmiş Kitablar")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(favoriteBooks) { book in
                                    NavigationLink(destination: BookCardView(
                                        book: book,
                                        isScrolled: { _ in },
                                        size: size
                                    )) {
                                        BookSliderCardView(book: book)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 290)
                    }
                    
                    // MARK: - Quotes Accordion
                    if !quotes.isEmpty {
                        SectionHeaderView(title: "Sitatlar")
                        
                        VStack(spacing: 12) {
                            ForEach(quotes.indices, id: \.self) { index in
                                QuoteAccordionView(quote: quotes[index])
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Ayahs
                    if !favoriteAyahs.isEmpty {
                        SectionHeaderView(title: "Ayələr")
                        
                        LazyVStack(spacing: 15) {
                            ForEach(favoriteAyahs) { ayah in
                                NavigationLink(destination: AyahDetailView(ayah: ayah)) {
                                    AyahCardView(ayah: ayah)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        if let index = favoriteAyahs.firstIndex(where: { $0.id == ayah.id }) {
                                            favoriteAyahs.remove(at: index)
                                        }
                                    } label: { Label("Sil", systemImage: "trash") }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Hadiths
                    if !favoriteHadiths.isEmpty {
                        SectionHeaderView(title: "Hədislər")
                        
                        LazyVStack(spacing: 15) {
                            ForEach(favoriteHadiths) { hadith in
                                NavigationLink(destination: HadithDetailView(hadith: hadith)) {
                                    HadithCardView(hadith: hadith)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        if let index = favoriteHadiths.firstIndex(where: { $0.id == hadith.id }) {
                                            favoriteHadiths.remove(at: index)
                                        }
                                    } label: { Label("Sil", systemImage: "trash") }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Favoritlər")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Detail Views


struct AyahDetailView: View {
    var ayah: Ayah
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(ayah.text)
                .font(.title2)
                .lineSpacing(6)
            
            Text("Surah: \(ayah.surah) - Ayah: \(ayah.verse)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Ayah")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HadithDetailView: View {
    var hadith: Hadith
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(hadith.text)
                .font(.title3)
                .lineSpacing(6)
            
            HStack {
                Text("Narrator: \(hadith.narrator)")
                Spacer()
                Text("Source: \(hadith.source)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Hədis")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .padding(.top, 5)
    }
}

// MARK: - Book Slider Card
struct BookSliderCardView: View {
    var book: Book
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 220)
                    .clipped()
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                
                Text(book.rating)
                    .font(.caption)
                    .bold()
                    .padding(6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding(8)
            }
            
            Text(book.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(.primary)
            
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0..<5) { star in
                    Image(systemName: star < Int(book.rating) ?? 0 ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                }
            }
        }
        .frame(width: 160)
    }
}

// MARK: - Quote Accordion
struct QuoteAccordionView: View {
    var quote: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sitat")
                    .bold()
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .onTapGesture { withAnimation(.spring()) { isExpanded.toggle() } }
            
            if isExpanded {
                Text(quote)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Ayah Card
struct AyahCardView: View {
    var ayah: Ayah
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ayah.text)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
            
            Text("\(ayah.surah) - \(ayah.verse)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Hadith Card
struct HadithCardView: View {
    var hadith: Hadith
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hadith.text)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.primary)
            
            HStack {
                Text("— \(hadith.narrator)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(hadith.source)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(book: books.first!, size: CGSize(width: 160, height: 220))

            .preferredColorScheme(.dark)
    }
>>>>>>> 3c54132 (first commit)
}

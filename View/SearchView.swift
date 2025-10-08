<<<<<<< HEAD
//
//  SearchView.swift
//  Walkthrough
//
//  Created by Abdullah on 11.08.25.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SearchView()
=======
import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var selectedBook: Book?
    
    private let categories: [String: [Book]] = [
        "Hədis Kitabları": books,
        "Quran Təfsir Kitabları": [
            Book(title: "Tafsir Ibn Kathir", author: "Ibn Kathir", rating: "4.9", thumbnail: "tafsir", color: .teal, description: "A comprehensive Quran exegesis...")
        ],
        "İslam Alimləri Kitabları": [
            Book(title: "The Sealed Nectar", author: "Safiur Rahman Mubarakpuri", rating: "4.7", thumbnail: "sealednectar", color: .blue, description: "Biography of the Prophet (PBUH)...")
        ]
    ]
    
    var filteredBooks: [Book] {
        if searchText.isEmpty { books }
        else {
            books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    if searchText.isEmpty {
                        CategoriesListView(categories: categories, geometry: geometry)
                    } else {
                        SearchResultsView(filteredBooks: filteredBooks, geometry: geometry)
                    }
                }
                .navigationTitle("📚 Kitablar")
                .searchable(text: $searchText, prompt: "Kitab və ya müəllif axtar")
                .background(Color.yellow.opacity(0.05))
            }
            
        }
    }
}
struct CategoriesListView: View {
    let categories: [String: [Book]]
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(categories.keys.sorted(), id: \.self) { category in
            if let books = categories[category], !books.isEmpty {
                CategorySectionView(category: category, books: books, geometry: geometry)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct CategorySectionView: View {
    let category: String
    let books: [Book]
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(category)
                    .serifText(font: .title3, weight: .bold)
                    .foregroundColor(.black.opacity(0.9))
                
                Spacer()
                NavigationLink(destination: CategoryView(category: category, books: books)) {
                    Text("Hamısı")
                        .serifText(font: .caption2, weight: .bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(180))], spacing: 15) {
                    ForEach(books) { book in
                        BookGridItem(book: book, size: geometry.size)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 180)
        }
    }
}

struct SearchResultsView: View {
    let filteredBooks: [Book]
    let geometry: GeometryProxy

    var body: some View {
        if filteredBooks.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(.black.opacity(0.5))
                Text("Nəticə tapılmadı")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
                ForEach(filteredBooks) { book in
                    BookGridItem(book: book, size: geometry.size)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

struct BookGridItem: View {
    let book: Book
    let size: CGSize

    var body: some View {
        NavigationLink(
            destination: BookCardView(
                book: book,
                isScrolled: { _ in },
                size: size
            )
            .navigationBarBackButtonHidden(true)
        ) {
            VStack {
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(book.title)
                    .serifText(font: .caption, weight: .semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [book.color, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
    }
>>>>>>> 3c54132 (first commit)
}

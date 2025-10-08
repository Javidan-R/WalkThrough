//
//  CategoryView.swift
//  Walkthrough
//
//  Created by Abdullah on 12.08.25.
//

import SwiftUI
<<<<<<< HEAD

struct CategoryView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CategoryView()
=======
struct CategoryView: View {
let category: String
let books: [Book]

var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 15)],
                spacing: 15
            ) {
                ForEach(books) { book in
                    BookGridItem(book: book, size: CGSize(width: 300, height: 400))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .navigationTitle(category)
        .background(Color.yellow.opacity(0.05))
    
}

@ViewBuilder
private func BookGridItem(book: Book, size: CGSize) -> some View {
    NavigationLink(
        destination: BookCardView(
            book: book,
            isScrolled: { isScrolled in
                print("Scroll state for \(book.title): \(isScrolled)")
            },
            size: CGSize(width: size.width, height: size.height)
        )
        .navigationBarBackButtonHidden(true) // Əlavə back düyməsi yoxdur

        
    ) {
        VStack {
            Image(book.thumbnail)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.7), radius: 5)
            Text(book.title)
                .serifText(font: .caption, weight: .semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(.horizontal, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [book.color, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
        )
        .accessibilityLabel("Open \(book.title)")
    }
}
>>>>>>> 3c54132 (first commit)
}

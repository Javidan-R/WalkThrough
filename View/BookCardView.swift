<<<<<<< HEAD
//
//  BookCardView.swift
//  Walkthrough
//
//  Created by Abdullah on 13.08.25.
//

import SwiftUI

struct BookCardView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BookCardView()
=======
import SwiftUI

struct BookCardView: View {
    var book: Book
    var parentHorizontalPadding: CGFloat = 15
    var isScrolled: (Bool) -> ()
    var size: CGSize
    @Environment(\.dismiss) private var dismiss

    @State private var scrollProperties: ScrollGeometry = .init(
        contentOffset: .zero,
        contentSize: .zero,
        contentInsets: .init(),
        containerSize: .zero
    )
    @State private var scrollPosation: ScrollPosition = .init()
    @State private var isPageScrolled: Bool = false
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                TopCardView()
                OtherTextContents(book: book)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 50)
                    .frame(minWidth: size.width - (parentHorizontalPadding * 2))
            }
            .padding(.horizontal, -parentHorizontalPadding * scrollProperties.topInsetProgress)
        }
        .scrollPosition($scrollPosation)
        .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }, action: { oldValue, newValue in
            scrollProperties = newValue
            isPageScrolled = newValue.offsetY > 0
        })
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .onChange(of: isPageScrolled) { newValue in
            isScrolled(newValue)
        }
        .scrollTargetBehavior(BooksScrollEnd(topInset: scrollProperties.contentInsets.top))
        .background {
            GeometryReader { geo in
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .offset(y: scrollProperties.offsetY * 0.3)
                    .blur(radius: 10)
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: parentHorizontalPadding,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 15,
                            style: .circular
                        )
                        .fill(.background)
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: parentHorizontalPadding,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 15,
                            style: .circular
                        )
                    )
                    .offset(y: scrollProperties.offsetY > 0 ? 0 : -scrollProperties.offsetY)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: Top Card View
    func TopCardView() -> some View {
        NavigationLink(destination: ReaderView()
            .navigationBarBackButtonHidden(true) // Əlavə back düyməsi yoxdur
        ) {
            VStack(alignment: .leading, spacing: 15) {
                FixedHeaderView()
                
                Image(book.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 20)
                    .offset(y: scrollProperties.offsetY * 0.2)
                    .animation(.easeOut(duration: 0.3), value: scrollProperties.offsetY)
                
                Text(book.title)
                    .serifText(font: .title, weight: .bold)
                
                Button {
                    print("More button tapped")
                } label: {
                    HStack(spacing: 6) {
                        Text(book.author)
                            .foregroundStyle(.black)
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    }
                }
                .padding(.top, -5)
                
                VStack(alignment: .center, spacing: 10) {
                    HStack(spacing: 4) {
                        Text("Book")
                            .fontWeight(.black)
                        Image(systemName: "info.circle")
                            .font(.caption)
                    }
                    
                    Text("1001 Pages")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Button {
                        // Navigation artıq ReaderView-a keçir
                    } label: {
                        Label("Read", systemImage: "book.closed")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .foregroundStyle(.black)
                    .tint(.white)
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    .padding(10)
                }
                .padding(10)
                .background(.white.opacity(0.3), in: .rect(cornerRadius: 30))
            }
            .foregroundStyle(.white)
            .padding()
            .frame(minWidth: size.width - (parentHorizontalPadding * 2))
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(book.color.gradient)
            )
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 15, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 15, style: .circular))
        }
    }
    
    // MARK: Other Text Contents
    func OtherTextContents(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("From Publisher")
                .serifText(font: .title3, weight: .semibold)
            
            Text(book.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Apple Books")
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
    
    // MARK: Fixed Header View
    func FixedHeaderView() -> some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 1)) {
                    scrollPosation.scrollTo(edge: .top)
                   
                }
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            
            Spacer()
            
            // Aktiv Favorite düyməsi
            Button {
                isFavorite.toggle()
                print(isFavorite ? "Kitab favoritlərə əlavə edildi" : "Kitab favoritlərdən çıxarıldı")
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .white)
            }
            
            // Settings Dropdown Menu
            Menu {
                Button("Kitaba aid ayarlar", systemImage: "gear") {
                    print("Kitab ayarları açıldı")
                }
                Button("Rəy göndər", systemImage: "bubble.left") {
                    print("Feedback formu açıldı")
                }
                Button("Paylaş", systemImage: "square.and.arrow.up") {
                    print("Paylaşma seçildi")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .background(
            GeometryReader { geometry in
                TransparentBlurView()
                    .frame(height: scrollProperties.contentInsets.top + 50)
                    .frame(height: geometry.size.height, alignment: .bottom)
                    .opacity(min(scrollProperties.offsetY / 100, 1))
                    .blur(radius: min(scrollProperties.offsetY / 20, 10))
                    .animation(.easeInOut(duration: 0.25), value: scrollProperties.offsetY)
            }
            .opacity(scrollProperties.topInsetProgress)
        )
        .font(.title)
        .padding(.horizontal, -3 * scrollProperties.topInsetProgress)
        .offset(y: scrollProperties.offsetY < 20 ? 0 : scrollProperties.offsetY - 20)
        .zIndex(1000)
    }
    
    // MARK: ScrollTargetBehavior helper
    struct BooksScrollEnd: ScrollTargetBehavior {
        var topInset: CGFloat
        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            if target.rect.minY < topInset {
                target.rect.origin = .zero
            }
        }
    }
}

extension ScrollGeometry {
    var offsetY: CGFloat {
        contentOffset.y + contentInsets.top
    }
    var topInsetProgress: CGFloat {
        guard contentInsets.top > 0 else { return 0 }
        return max(min(offsetY / contentInsets.top, 1), 0)
    }
}

extension View {
    func serifText(font: Font, weight: Font.Weight) -> some View {
        self
            .font(font)
            .fontWeight(weight)
            .fontDesign(.serif)
    }
>>>>>>> 3c54132 (first commit)
}

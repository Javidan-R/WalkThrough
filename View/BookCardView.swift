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
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isPageScrolled: Bool = false
    @State private var isFavorite = false
    @State private var bookProgress: Double = 0.35
    @State private var showBookInfo = false
    @State private var showChapters = false
    @State private var userRating: Int = 0
    @State private var showRatingSheet = false
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloaded = false
    @State private var showDownloadSheet = false
    @State private var showShareSheet = false
    @State private var selectedChapter: Int? = nil

    // ScrollGeometry hesablamaları
    private var imageScale: CGFloat {
        let scale = 1 + max(scrollProperties.offsetY / 400, 0)
        return min(scale, 1.5)
    }

    private var imageOffset: CGFloat {
        return scrollProperties.offsetY * 0.4
    }

    private var headerOpacity: Double {
        return min(max(scrollProperties.offsetY / 150, 0), 1)
    }

    private var bookImageParallax: CGFloat {
        return scrollProperties.offsetY * 0.15
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                TopCardView()
                    .transition(.scale.combined(with: .opacity))

                BookContentTabs()
                    .padding(.horizontal, 10)

                OtherTextContents(book: book)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 50)
                    .frame(minWidth: size.width - (parentHorizontalPadding * 2))
            }
            .padding(.horizontal, -parentHorizontalPadding * scrollProperties.topInsetProgress)
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }, action: { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.1)) {
                scrollProperties = newValue
                isPageScrolled = newValue.offsetY > 0
            }
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
                    .scaleEffect(imageScale)
                    .offset(y: imageOffset)
                    .blur(radius: 15)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.7),
                                Color.black.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: parentHorizontalPadding,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 15,
                            style: .circular
                        )
                        .fill(.background.opacity(0.95))
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
        .sheet(isPresented: $showRatingSheet) {
            RatingSheet(userRating: $userRating, bookTitle: book.title)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showDownloadSheet) {
            DownloadSheet(
                downloadProgress: $downloadProgress,
                isDownloaded: $isDownloaded,
                bookTitle: book.title
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(bookTitle: book.title, author: book.author)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Top Card View
    func TopCardView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            FixedHeaderView()

            HStack(alignment: .top, spacing: 20) {
                // Kitab şəkli - Parallax effekti
                Image(book.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 110, height: 160)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .offset(y: bookImageParallax)
                    .scaleEffect(1 - (scrollProperties.offsetY > 0 ? 0 : scrollProperties.offsetY / 1000))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: scrollProperties.offsetY)

                VStack(alignment: .leading, spacing: 14) {
                    Text(book.title)
                        .serifText(font: .title3, weight: .bold)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)

                    Button(action: {
                        // Müəllif səhifəsinə keçid
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .font(.caption)
                                .foregroundColor(book.color)
                            Text(book.author)
                                .serifText(font: .callout, weight: .semibold)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(book.rating) ?? 0 ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                        Text(book.rating)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        Divider()
                            .frame(height: 12)

                        Text("128 rəy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
            )

            // Progress və Action Card
            VStack(spacing: 16) {
                if bookProgress > 0 {
                    VStack(spacing: 10) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "book.pages")
                                    .font(.subheadline)
                                    .foregroundColor(book.color)
                                Text("Oxuma tərəqqisi")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            Text("\(Int(bookProgress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(book.color)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [book.color, book.color.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * bookProgress, height: 8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bookProgress)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(book.color.opacity(0.08))
                    )
                }

                // Action Buttons
                HStack(spacing: 12) {
                    NavigationLink(destination: ReaderView().navigationBarBackButtonHidden(true)) {
                        HStack(spacing: 8) {
                            Image(systemName: bookProgress > 0 ? "book.pages.fill" : "book.closed.fill")
                                .font(.body)
                            Text(bookProgress > 0 ? "Davam et" : "Oxumağa başla")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [book.color, book.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                        .shadow(color: book.color.opacity(0.5), radius: 12, x: 0, y: 6)
                    }

                    Button(action: {
                        withAnimation(.spring()) {
                            showDownloadSheet = true
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                                .frame(width: 56, height: 56)

                            Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundStyle(isDownloaded ? .green : book.color)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            )
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(minWidth: size.width - (parentHorizontalPadding * 2))
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [book.color.opacity(0.12), book.color.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 15, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 15, style: .circular))
    }

    // MARK: - Book Content Tabs
    func BookContentTabs() -> some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    BookTabButton(
                        icon: "info.circle.fill",
                        title: "Məlumat",
                        isSelected: showBookInfo,
                        colors: [.blue, .purple]
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showBookInfo.toggle()
                            if showBookInfo { showChapters = false }
                        }
                    }

                    BookTabButton(
                        icon: "list.bullet",
                        title: "Fəsillər",
                        isSelected: showChapters,
                        colors: [.green, .teal]
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showChapters.toggle()
                            if showChapters { showBookInfo = false }
                        }
                    }

                    BookTabButton(
                        icon: "star.circle.fill",
                        title: "Rəy yaz",
                        isSelected: false,
                        colors: [.orange, .red]
                    ) {
                        showRatingSheet = true
                    }
                }
                .padding(.horizontal)
            }

            if showBookInfo {
                BookInfoPanel(book: book)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }

            if showChapters {
                ChaptersPanel(selectedChapter: $selectedChapter)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
    }

    // MARK: - Book Info Panel
    func BookInfoPanel(book: Book) -> some View {
        VStack(spacing: 12) {
            InfoRow(icon: "book.fill", label: "Səhifə sayı", value: "324", color: .blue)
            InfoRow(icon: "globe", label: "Dil", value: "Azərbaycan", color: .green)
            InfoRow(icon: "calendar", label: "Nəşr ili", value: "2023", color: .orange)
            InfoRow(icon: "building.2", label: "Nəşriyyat", value: "İslam Nəşriyyatı", color: .purple)
            InfoRow(icon: "barcode", label: "ISBN", value: "978-9952-123-45-6", color: .red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    // MARK: - Chapters Panel
    func ChaptersPanel(selectedChapter: Binding<Int?>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fəsillər")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1...10, id: \.self) { chapter in
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedChapter.wrappedValue = chapter
                            }
                        }) {
                            VStack(spacing: 6) {
                                Text("\(chapter)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Fəsil")
                                    .font(.caption2)
                            }
                            .foregroundColor(selectedChapter.wrappedValue == chapter ? .white : .primary)
                            .frame(width: 70, height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedChapter.wrappedValue == chapter ?
                                          LinearGradient(colors: [book.color, book.color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                          LinearGradient(colors: [Color(.systemGray6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            )
                            .shadow(
                                color: selectedChapter.wrappedValue == chapter ? book.color.opacity(0.4) : .clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    // MARK: - Other Text Contents
    func OtherTextContents(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Nəşriyyatdan")
                    .serifText(font: .title3, weight: .bold)

                Text(book.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )

            VStack(alignment: .leading, spacing: 14) {
                Text("Kateqoriyalar")
                    .font(.headline)
                    .fontWeight(.bold)

                FlowLayout(spacing: 8) {
                    ForEach(["İslam", "Hədis", "Dini Tədqiqat", "Ərəb", "Tarix"], id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(book.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(book.color.opacity(0.12))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Oxucu Rəyləri")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showRatingSheet = true }) {
                        Text("Hamısına bax")
                            .font(.caption)
                            .foregroundColor(book.color)
                    }
                }

                HStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text(book.rating)
                            .font(.system(size: 36, weight: .bold))
                        HStack(spacing: 3) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                        Text("128 rəy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 100)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray6))
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        RatingBar(rating: 5, count: 89, total: 128, color: book.color)
                        RatingBar(rating: 4, count: 25, total: 128, color: book.color)
                        RatingBar(rating: 3, count: 10, total: 128, color: book.color)
                        RatingBar(rating: 2, count: 3, total: 128, color: book.color)
                        RatingBar(rating: 1, count: 1, total: 128, color: book.color)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
    }

    // MARK: - Fixed Header View
    func FixedHeaderView() -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollPosition.scrollTo(edge: .top)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, book.color.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            Spacer()

            // Title göstərilməsi scroll edərkən
            if headerOpacity > 0.5 {
                Text(book.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .opacity(headerOpacity)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? .red : .white, isFavorite ? Color.red.opacity(0.3) : Color.clear)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }

                Menu {
                    Button(action: {}) {
                        Label("Oxuma ayarları", systemImage: "gearshape")
                    }
                    Button(action: { showChapters = true }) {
                        Label("Mündəricat", systemImage: "list.bullet")
                    }
                    Divider()
                    Button(action: { showRatingSheet = true }) {
                        Label("Rəy göndər", systemImage: "bubble.left")
                    }
                    Button(action: { showShareSheet = true }) {
                        Label("Paylaş", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, book.color.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            GeometryReader { geometry in
                ZStack {
                    TransparentBlurView()
                        .opacity(headerOpacity)

                    LinearGradient(
                        colors: [
                            book.color.opacity(headerOpacity * 0.8),
                            book.color.opacity(headerOpacity * 0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .frame(height: geometry.size.height + scrollProperties.contentInsets.top)
                .frame(height: geometry.size.height, alignment: .bottom)
                .animation(.easeOut(duration: 0.2), value: headerOpacity)
            }
        )
        .offset(y: scrollProperties.offsetY < 20 ? 0 : scrollProperties.offsetY - 20)
        .zIndex(1000)
    }

    // MARK: - ScrollTargetBehavior helper
    struct BooksScrollEnd: ScrollTargetBehavior {
        var topInset: CGFloat
        func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
            if target.rect.minY < topInset {
                target.rect.origin = .zero
            }
        }
    }
}

// MARK: - Helper Views

struct BookTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.callout)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color(.systemGray6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(12)
            .shadow(
                color: isSelected ? colors.first!.opacity(0.4) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct RatingBar: View {
    let rating: Int
    let count: Int
    let total: Int
    let color: Color

    var percentage: CGFloat {
        CGFloat(count) / CGFloat(total)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(rating)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 12)

            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(.yellow)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Rating Sheet
struct RatingSheet: View {
    @Binding var userRating: Int
    let bookTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var reviewText = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Rəyinizi Paylaşın")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(bookTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Star Rating
                    VStack(spacing: 16) {
                        Text("Reytinq")
                            .font(.headline)

                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        userRating = star
                                    }
                                }) {
                                    Image(systemName: star <= userRating ? "star.fill" : "star")
                                        .font(.system(size: 40))
                                        .foregroundColor(star <= userRating ? .yellow : .gray)
                                        .scaleEffect(star == userRating ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: userRating)
                                }
                            }
                        }

                        if userRating > 0 {
                            Text(getRatingText())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .transition(.opacity)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )

                    // Review Text
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Şərh (İstəyə görə)")
                            .font(.headline)

                        ZStack(alignment: .topLeading) {
                            if reviewText.isEmpty {
                                Text("Kitab haqqında fikirlərinizi yazın...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                            }

                            TextEditor(text: $reviewText)
                                .frame(height: 140)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )

                        Text("\(reviewText.count)/500")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // Submit Button
                    Button(action: {
                        isSubmitting = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isSubmitting = false
                            dismiss()
                        }
                    }) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Rəy Göndər")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: userRating > 0 ? [.blue, .purple] : [.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: userRating > 0 ? .blue.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(userRating == 0 || isSubmitting)
                    .opacity(userRating > 0 ? 1 : 0.6)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") { dismiss() }
                }
            }
        }
    }

    private func getRatingText() -> String {
        switch userRating {
        case 5: return "Əla! 🌟"
        case 4: return "Çox yaxşı! 👍"
        case 3: return "Yaxşı 👌"
        case 2: return "Orta 😐"
        case 1: return "Zəif 👎"
        default: return ""
        }
    }
}

// MARK: - Download Sheet
struct DownloadSheet: View {
    @Binding var downloadProgress: Double
    @Binding var isDownloaded: Bool
    let bookTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var isDownloading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()

                if !isDownloaded {
                    VStack(spacing: 24) {
                        // Download Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 8) {
                            Text("Kitabı Yüklə")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(bookTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        if isDownloading {
                            VStack(spacing: 12) {
                                ProgressView(value: downloadProgress)
                                    .tint(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .scaleEffect(y: 2)

                                HStack {
                                    Text("\(Int(downloadProgress * 100))%")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)

                                    Spacer()

                                    Text("\(String(format: "%.1f", downloadProgress * 45.2)) MB / 45.2 MB")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 8)
                        } else {
                            VStack(spacing: 12) {
                                Text("Ölçü: 45.2 MB")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Button(action: startDownload) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text("Yüklə")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.2), .teal.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }

                        VStack(spacing: 8) {
                            Text("Uğurla Yükləndi!")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Kitab offline oxumaq üçün hazırdır")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        HStack(spacing: 12) {
                            Button(action: {
                                // Kitabı sil
                                withAnimation {
                                    isDownloaded = false
                                    downloadProgress = 0
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Sil")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .foregroundColor(.red)
                                .cornerRadius(14)
                            }

                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("Oxu")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bağla") { dismiss() }
                }
            }
        }
    }

    private func startDownload() {
        isDownloading = true
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            downloadProgress += 0.02
            if downloadProgress >= 1.0 {
                timer.invalidate()
                withAnimation(.spring()) {
                    isDownloaded = true
                    isDownloading = false
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: View {
    let bookTitle: String
    let author: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Paylaş")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)

                // Share Options
                VStack(spacing: 12) {
                    ShareButton(icon: "message.fill", title: "Mesaj", color: .green) {
                        // Share via message
                    }

                    ShareButton(icon: "mail.fill", title: "Email", color: .blue) {
                        // Share via email
                    }

                    ShareButton(icon: "link", title: "Linki Kopyala", color: .orange) {
                        withAnimation(.spring()) {
                            copied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    }

                    ShareButton(icon: "ellipsis", title: "Digər", color: .purple) {
                        // More options
                    }
                }

                if copied {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Link köçürüldü!")
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bağla") { dismiss() }
                }
            }
        }
    }
}

struct ShareButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40)

                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Extensions

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
}

// MARK: - Preview
struct BookCardView_Previews: PreviewProvider {
    static var previews: some View {
        BookCardView(
            book: books.first!,
            isScrolled: { _ in },
            size: CGSize(width: 393, height: 852)
        )
        .preferredColorScheme(.dark)
    }
}

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
    @State private var selectedTab: FavoriteTab = .books
    @State private var scrollOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0

    let book: Book
    let size: CGSize

    enum FavoriteTab: String, CaseIterable {
        case books = "Kitablar"
//        case quotes = "Sitatlar"
        case ayahs = "Ayələr"
        case hadiths = "Hədislər"

        var icon: String {
            switch self {
            case .books: return "book.fill"
//            case .quotes: return "quote.bubble.fill"
            case .ayahs: return "moon.stars.fill"
            case .hadiths: return "text.book.closed.fill"
            }
        }

        var color: Color {
            switch self {
            case .books: return .blue
//            case .quotes: return .purple
            case .ayahs: return .green
            case .hadiths: return .orange
            }
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Animated Header
                        AnimatedHeaderView(
                            scrollOffset: scrollOffset,
                            selectedTab: selectedTab,
                            geometry: geometry
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: HeaderHeightKey.self,
                                    value: geo.size.height
                                )
                            }
                        )

                        // Tab Bar
                        CustomTabBar(
                            selectedTab: $selectedTab,
                            scrollOffset: scrollOffset,
                            headerHeight: headerHeight
                        )
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .zIndex(100)

                        // Content
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case .books:
                                BooksSection(books: $favoriteBooks, size: size)
//                            case .quotes:
//                                QuotesSection(quotes: $quotes)
                            case .ayahs:
                                AyahsSection(ayahs: $favoriteAyahs)
                            case .hadiths:
                                HadithsSection(hadiths: $favoriteHadiths)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
                .onPreferenceChange(HeaderHeightKey.self) { value in
                    headerHeight = value
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preference Keys
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Animated Header
struct AnimatedHeaderView: View {
    let scrollOffset: CGFloat
    let selectedTab: FavoritesView.FavoriteTab
    let geometry: GeometryProxy

    private var headerProgress: CGFloat {
        let progress = min(max(-scrollOffset / 150, 0), 1)
        return progress
    }

    private var scale: CGFloat {
        let scale = 1 + min(max(scrollOffset / 500, 0), 0.3)
        return scale
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    selectedTab.color.opacity(0.6),
                    selectedTab.color.opacity(0.3),
                    selectedTab.color.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 20)

            // Decorative Circles
            GeometryReader { geo in
                Circle()
                    .fill(selectedTab.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .offset(x: -50, y: -50 + scrollOffset * 0.3)
                    .blur(radius: 30)
                    .scaleEffect(scale)

                Circle()
                    .fill(selectedTab.color.opacity(0.15))
                    .frame(width: 150, height: 150)
                    .offset(x: geo.size.width - 100, y: 50 + scrollOffset * 0.2)
                    .blur(radius: 25)
                    .scaleEffect(scale)
            }

            // Content
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Favoritlər")
                            .font(.system(size: 36 - (headerProgress * 16), weight: .bold))
                            .foregroundStyle(.primary)

                        if headerProgress < 0.5 {
                            Text("Seçilmiş kolleksiyalarınız")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
//                                .opacity(1 - (headerProgress * 2))
                        }
                    }

                    Spacer()

                    // Stats Badge
                    if headerProgress < 0.7 {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab.icon)
                                .font(.title2)
                                .foregroundStyle(selectedTab.color)

                            Text(getItemCount())
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .opacity(1 - (headerProgress * 1.5))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)
            .padding(.bottom, 20)
        }
        .frame(height: max(180 - (headerProgress * 80), 100))
        .animation(.easeOut(duration: 0.2), value: headerProgress)
    }

    private func getItemCount() -> String {
        switch selectedTab {
        case .books: return "\(books.count)"
//        case .quotes: return "\(3)"
        case .ayahs: return "\(ayahs.count)"
        case .hadiths: return "\(hadiths.count)"
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: FavoritesView.FavoriteTab
    let scrollOffset: CGFloat
    let headerHeight: CGFloat

    private var isSticky: Bool {
        scrollOffset < -headerHeight + 100
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FavoritesView.FavoriteTab.allCases, id: \.self) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(
            isSticky ? Color(.systemBackground).opacity(0.95) : Color.clear
        )
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: FavoritesView.FavoriteTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : tab.color)

                Text(tab.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [tab.color, tab.color.opacity(0.7)],
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
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? tab.color.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                Capsule()
                    .stroke(tab.color.opacity(0.2), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Books Section
struct BooksSection: View {
    @Binding var books: [Book]
    let size: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if books.isEmpty {
                EmptyStateView(
                    icon: "book.fill",
                    title: "Heç bir kitab yoxdur",
                    subtitle: "Bəyəndiyiniz kitabları buraya əlavə edin",
                    color: .blue
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 20) {
                    ForEach(books.indices, id: \.self) { index in
                        NavigationLink(destination: BookCardView(
                            book: books[index],
                            isScrolled: { _ in },
                            size: size
                        )) {
                            EnhancedBookCard(book: books[index], index: index)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Enhanced Book Card
struct EnhancedBookCard: View {
    var book: Book
    var index: Int
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Book Image
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)

                // Rating Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(book.rating)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(12)
            }

            // Book Info
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(book.color)
                            .frame(width: geo.size.width * 0.35, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
            // On tap
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Quotes Section
//struct QuotesSection: View {
//    @Binding var quotes: [String]
//    @State private var expandedIndex: Int? = nil
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if quotes.isEmpty {
//                EmptyStateView(
//                    icon: "quote.bubble.fill",
//                    title: "Heç bir sitat yoxdur",
//                    subtitle: "İlhamlanan sitatları buraya əlavə edin",
//                    color: .purple
//                )
//            } else {
//                ForEach(quotes.indices, id: \.self) { index in
//                    EnhancedQuoteCard(
//                        quote: quotes[index],
//                        index: index,
//                        isExpanded: expandedIndex == index
//                    ) {
//                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
//                            expandedIndex = expandedIndex == index ? nil : index
//                        }
//                    } onDelete: {
//                        withAnimation {
//                            quotes.remove(at: index)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//        }
//    }
//}

// MARK: - Enhanced Quote Card
struct EnhancedQuoteCard: View {
    var quote: String
    var index: Int
    var isExpanded: Bool
    var onTap: () -> Void
    var onDelete: () -> Void

    let gradients: [LinearGradient] = [
        LinearGradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color.orange.opacity(0.7), Color.pink.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color.green.opacity(0.7), Color.teal.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    ]

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.title2)
                        .foregroundStyle(gradients[index % gradients.count])

                    VStack(alignment: .leading, spacing: 8) {
                        Text(quote)
                            .font(.system(size: isExpanded ? 17 : 15, weight: isExpanded ? .medium : .regular))
                            .lineSpacing(6)
                            .foregroundStyle(.primary)
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)

                        if isExpanded {
                            HStack {
                                Button(action: {}) {
                                    Label("Paylaş", systemImage: "square.and.arrow.up")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }

                                Spacer()

                                Button(action: onDelete) {
                                    Label("Sil", systemImage: "trash")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(gradients[index % gradients.count])
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(gradients[index % gradients.count], lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(isExpanded ? 0.1 : 0.05), radius: isExpanded ? 15 : 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ayahs Section
struct AyahsSection: View {
    @Binding var ayahs: [Ayah]

    var body: some View {
        VStack(spacing: 16) {
            if ayahs.isEmpty {
                EmptyStateView(
                    icon: "moon.stars.fill",
                    title: "Heç bir ayə yoxdur",
                    subtitle: "Seçilmiş ayələri buraya əlavə edin",
                    color: .green
                )
            } else {
                ForEach(ayahs) { ayah in
                    NavigationLink(destination: AyahDetailView(ayah: ayah)) {
                        EnhancedAyahCard(ayah: ayah)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = ayahs.firstIndex(where: { $0.id == ayah.id }) {
                                withAnimation(.spring()) {
                                    ayahs.remove(at: index)
                                }
                            }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            // Share action
                        } label: {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Enhanced Ayah Card
struct EnhancedAyahCard: View {
    var ayah: Ayah
    @State private var isPressed = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .teal.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "moon.stars.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(ayah.text)
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .foregroundStyle(.primary)

                HStack(spacing: 16) {
                    Label(ayah.surah, systemImage: "book.closed.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Ayə: \(ayah.verse)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Hadiths Section
struct HadithsSection: View {
    @Binding var hadiths: [Hadith]

    var body: some View {
        VStack(spacing: 16) {
            if hadiths.isEmpty {
                EmptyStateView(
                    icon: "text.book.closed.fill",
                    title: "Heç bir hədis yoxdur",
                    subtitle: "Seçilmiş hədisləri buraya əlavə edin",
                    color: .orange
                )
            } else {
                ForEach(hadiths) { hadith in
                    NavigationLink(destination: HadithDetailView(hadith: hadith)) {
                        EnhancedHadithCard(hadith: hadith)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = hadiths.firstIndex(where: { $0.id == hadith.id }) {
                                withAnimation(.spring()) {
                                    hadiths.remove(at: index)
                                }
                            }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            // Share action
                        } label: {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Enhanced Hadith Card
struct EnhancedHadithCard: View {
    var hadith: Hadith
    @State private var isPressed = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .yellow.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "text.book.closed.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(hadith.text)
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .foregroundStyle(.primary)

                HStack(spacing: 16) {
                    Label(hadith.narrator, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(hadith.source)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(color)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Detail Views
struct AyahDetailView: View {
    var ayah: Ayah
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Arabic Text
                Text(ayah.text)
                    .font(.system(size: 24))
                    .lineSpacing(12)
                    .foregroundStyle(.primary)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                // Info Cards
                VStack(spacing: 12) {
                    InfoCard(icon: "book.closed.fill", label: "Surə", value: ayah.surah, color: .green)
                    InfoCard(icon: "number", label: "Ayə", value: ayah.surah, color: .teal)
                }

                // Actions
                HStack(spacing: 12) {
                    ActionButton(icon: "square.and.arrow.up", label: "Paylaş", color: .blue)
                    ActionButton(icon: "doc.on.doc", label: "Kopyala", color: .purple)
                    ActionButton(icon: "bookmark", label: "Yadda saxla", color: .orange)
                }

                Spacer()
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // Action
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

struct HadithDetailView: View {
    var hadith: Hadith
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Hadith Text
                Text(hadith.text)
                    .font(.system(size: 20))
                    .lineSpacing(10)
                    .foregroundStyle(.primary)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Info Cards
                VStack(spacing: 12) {
                    InfoCard(icon: "person.fill", label: "Ravi", value: hadith.narrator, color: .orange)
                    InfoCard(icon: "books.vertical.fill", label: "Mənbə", value: hadith.source, color: .red)
                }
                
                // Actions
            }
        }
    }
}

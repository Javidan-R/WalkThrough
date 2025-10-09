import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var selectedBook: Book?
    @State private var recentSearches: [String] = ["Quran", "Hədis", "İslam"]
    @State private var showAdvancedFilter = false
    @State private var selectedLanguage: String = "Az"
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCategory: String? = nil
    @State private var showingBookDetail = false
    @State private var selectedSortOption: SortOption = .popular
    @State private var showSortOptions = false
    @State private var favoriteBooks: Set<String> = []
    @State private var viewMode: ViewMode = .grid

    enum SortOption: String, CaseIterable {
        case popular = "Populyar"
        case newest = "Ən yeni"
        case alphabetical = "Əlifba sırası"
        case topRated = "Yüksək reytinq"
    }

    enum ViewMode {
        case grid, list
    }

    private let categories: [String: [Book]] = [
        "Hədis Kitabları": books,
        "Quran Təfsir Kitabları": books,
        "İslam Alimləri Kitabları": books
    ]

    var filteredBooks: [Book] {
        var result = books

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let category = selectedCategory {
            result = categories[category] ?? result
        }

        // Sorting
        switch selectedSortOption {
        case .popular:
            result = result.sorted { Double($0.rating) ?? 0 > Double($1.rating) ?? 0 }
        case .newest:
            result = result.reversed()
        case .alphabetical:
            result = result.sorted { $0.title < $1.title }
        case .topRated:
            result = result.sorted { Double($0.rating) ?? 0 > Double($1.rating) ?? 0 }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        if searchText.isEmpty {
                            // İslami Header
                            IslamicHeaderSection()
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 16)

                            // Axtarış Bar
                            IslamicSearchBar(searchText: $searchText, selectedLanguage: $selectedLanguage)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)

                            // Stats Card - İslami dizayn
                            IslamicStatsCard(
                                totalBooks: books.count,
                                categories: categories.count,
                                favoriteCount: favoriteBooks.count
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                            // Quick Actions
                            QuickActionsSection(
                                selectedCategory: $selectedCategory,
                                recentSearches: $recentSearches,
                                searchText: $searchText
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                            // Son Axtarışlar
                            if !recentSearches.isEmpty {
                                RecentSearchesSection(
                                    recentSearches: $recentSearches,
                                    searchText: $searchText
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            }

                            // Kateqoriyalar
                            CategoriesListView(
                                categories: categories,
                                favoriteBooks: $favoriteBooks
                            )

                            Spacer()
                                .frame(height: 40)
                        } else {
                            // Axtarış Nəticələri
//                            SearchResultsSection(
//                                filteredBooks: filteredBooks,
//                                searchText: searchText,
//                                selectedSortOption: $selectedSortOption,
//                                showSortOptions: $showSortOptions,
//                                viewMode: $viewMode,
//                                favoriteBooks: $favoriteBooks
//                            )
                        }
                    }

                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        IslamicNavTitle()
                    }

                }
            }
        }
//        .sheet(isPresented: $showAdvancedFilter) {
//            AdvancedFilterView(
//                selectedSortOption: $selectedSortOption,
//                selectedCategory: $selectedCategory,
//                categories: Array(categories.keys)
//            )
//            .presentationDetents([.medium, .large])
//        }
    }
}

// MARK: - İslami Header
struct IslamicHeaderSection: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Text("İslami Kitabxana")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Elm axtarmaq hər bir müsəlmana vacibdir")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }

                Spacer()

                // İslami icon animasiya
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .teal.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(animate ? 1.1 : 1.0)

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(animate ? 10 : -10))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .green.opacity(0.1), radius: 15, x: 0, y: 5)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - İslami Nav Title
struct IslamicNavTitle: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.caption)
                .foregroundColor(.green)
            Text("Kitabxana")
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - İslami Search Bar
struct IslamicSearchBar: View {
    @Binding var searchText: String
    @Binding var selectedLanguage: String
    @FocusState private var isFocused: Bool
    @State private var pulseAnimation = false

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(
                        LinearGradient(
                            colors: isFocused ? [.green, .teal] : [.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.body)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                TextField("Kitab, müəllif, kateqoriya...", text: $searchText)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring()) {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: isFocused ? [.green.opacity(0.5), .teal.opacity(0.3)] : [.gray.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .shadow(color: isFocused ? .green.opacity(0.2) : .clear, radius: 8, x: 0, y: 4)

            Button(action: {
                // Səsli axtarış
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "mic.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .animation(.spring(response: 0.3), value: isFocused)
        .onChange(of: isFocused) { focused in
            if focused {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

// MARK: - İslami Stats Card
struct IslamicStatsCard: View {
    let totalBooks: Int
    let categories: Int
    let favoriteCount: Int
    @State private var animateStats = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                IslamicStatItem(
                    icon: "book.closed.fill",
                    value: "\(totalBooks)+",
                    label: "Kitab",
                    color: .green,
                    animate: animateStats
                )

                Divider()
                    .frame(height: 50)

                IslamicStatItem(
                    icon: "square.grid.2x2.fill",
                    value: "\(categories)",
                    label: "Kateqoriya",
                    color: .teal,
                    animate: animateStats
                )

                Divider()
                    .frame(height: 50)

                IslamicStatItem(
                    icon: "heart.fill",
                    value: "\(favoriteCount)",
                    label: "Favorit",
                    color: .red,
                    animate: animateStats
                )
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))

                // İslami pattern overlay
                GeometryReader { geo in
                    Path { path in
                        let size = geo.size
                        for i in stride(from: 0, to: size.width, by: 20) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i, y: size.height))
                        }
                    }
                    .stroke(Color.green.opacity(0.05), lineWidth: 1)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.green.opacity(0.3), .teal.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .green.opacity(0.15), radius: 12, x: 0, y: 6)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateStats = true
            }
        }
    }
}

struct IslamicStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let animate: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .scaleEffect(animate ? 1.0 : 0.8)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .opacity(animate ? 1 : 0)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
    }
}

// MARK: - Quick Actions
struct QuickActionsSection: View {
    @Binding var selectedCategory: String?
    @Binding var recentSearches: [String]
    @Binding var searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sürətli Keçidlər")
                .font(.headline)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "moon.stars.fill",
                        title: "Quran",
                        gradient: [.purple, .blue]
                    ) {
                        searchText = "Quran"
                    }

                    QuickActionButton(
                        icon: "text.book.closed.fill",
                        title: "Hədislər",
                        gradient: [.orange, .red]
                    ) {
                        searchText = "Hədis"
                    }

                    QuickActionButton(
                        icon: "person.2.fill",
                        title: "Alimlər",
                        gradient: [.blue, .cyan]
                    ) {
                        searchText = "Alim"
                    }

                    QuickActionButton(
                        icon: "building.2.fill",
                        title: "Fiqh",
                        gradient: [.green, .teal]
                    ) {
                        searchText = "Fiqh"
                    }

                    QuickActionButton(
                        icon: "heart.text.square.fill",
                        title: "Əxlaq",
                        gradient: [.pink, .purple]
                    ) {
                        searchText = "Əxlaq"
                    }
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                action()
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(width: 80)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Recent Searches
struct RecentSearchesSection: View {
    @Binding var recentSearches: [String]
    @Binding var searchText: String
    @State private var animateChips = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text("Son Axtarışlar")
                        .font(.headline)
                        .fontWeight(.bold)
                }

                Spacer()

                Button(action: {
                    withAnimation(.spring()) {
                        recentSearches.removeAll()
                    }
                }) {
                    Text("Təmizlə")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }

            FlowLayout(spacing: 10) {
                ForEach(Array(recentSearches.enumerated()), id: \.offset) { index, search in
                    Button(action: {
                        withAnimation {
                            searchText = search
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption)
                            Text(search)
                                .font(.subheadline)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .scaleEffect(animateChips ? 1.0 : 0.8)
                    .opacity(animateChips ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.1), value: animateChips)
                }
            }
        }
        .onAppear {
            animateChips = true
        }
    }
}

// MARK: - Categories List
struct CategoriesListView: View {
    let categories: [String: [Book]]
    @Binding var favoriteBooks: Set<String>

    var body: some View {
        ForEach(categories.keys.sorted(), id: \.self) { category in
            if let books = categories[category], !books.isEmpty {
                IslamicCategorySection(
                    category: category,
                    books: books,
                    favoriteBooks: $favoriteBooks
                )
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - İslami Category Section
struct IslamicCategorySection: View {
    let category: String
    let books: [Book]
    @Binding var favoriteBooks: Set<String>
    @State private var animateHeader = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(categoryColor(category).opacity(0.2))
                            .frame(width: 50, height: 50)

                        Image(systemName: categoryIcon(category))
                            .font(.title3)
                            .foregroundColor(categoryColor(category))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(category)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("\(books.count) kitab")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .offset(x: animateHeader ? 0 : -20)
                .opacity(animateHeader ? 1 : 0)

                Spacer()

                NavigationLink(destination: CategoryView(category: category, books: books)) {
                    HStack(spacing: 6) {
                        Text("Hamısı")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.body)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [categoryColor(category), categoryColor(category).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: categoryColor(category).opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(animateHeader ? 1 : 0.8)
                .opacity(animateHeader ? 1 : 0)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(books.prefix(10).enumerated()), id: \.element.id) { index, book in
                        NavigationLink(destination: BookCardView(
                            book: book,
                            isScrolled: { _ in },
                            size: CGSize(width: 393, height: 852)
                        )) {
                            IslamicBookCard(
                                book: book,
                                isFavorite: favoriteBooks.contains(book.id),
                                categoryColor: categoryColor(category)
                            ) {
                                withAnimation(.spring()) {
                                    if favoriteBooks.contains(book.id) {
                                        favoriteBooks.remove(book.id)
                                    } else {
                                        favoriteBooks.insert(book.id)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateHeader = true
            }
        }
    }

    func categoryIcon(_ category: String) -> String {
        if category.contains("Hədis") { return "text.book.closed.fill" }
        if category.contains("Quran") { return "moon.stars.fill" }
        if category.contains("Alim") { return "person.2.fill" }
        return "books.vertical.fill"
    }

    func categoryColor(_ category: String) -> Color {
        if category.contains("Hədis") { return .orange }
        if category.contains("Quran") { return .purple }
        if category.contains("Alim") { return .blue }
        return .green
    }
}

// MARK: - İslami Book Card
struct IslamicBookCard: View {
    let book: Book
    let isFavorite: Bool
    let categoryColor: Color
    let onFavoriteToggle: () -> Void
    @State private var isPressed = false
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Book Image
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 220)
                    .cornerRadius(18)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.3)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .cornerRadius(18)
                    )
                    .shadow(color: categoryColor.opacity(0.3), radius: 12, x: 0, y: 6)

                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(10)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // İslami ornament divider
                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Circle()
                            .fill(categoryColor.opacity(0.5))
                            .frame(width: 3, height: 3)
                    }
                }
                .padding(.vertical, 2)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 160)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}
// MARK: - Recent Searches Section


// MARK: - Search Results Header
struct SearchResultsHeader: View {
    let resultsCount: Int
    let searchText: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(resultsCount) nəticə")
                    .font(.headline)
                Text("'\(searchText)' üçün")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

// MARK: - Categories List View

// MARK: - Premium Category Section
struct PremiumCategorySection: View {
    let category: String
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: categorySystemIcon(category))
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [categoryColor(category), categoryColor(category).opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("\(books.count) kitab")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                NavigationLink(destination: CategoryView(category: category, books: books)) {
                    HStack(spacing: 4) {
                        Text("Hamısı")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [categoryColor(category), categoryColor(category).opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(220))], spacing: 16) {
                    ForEach(books) { book in
                        PremiumBookCard(book: book)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    func categorySystemIcon(_ category: String) -> String {
        if category.contains("Hədis") { return "text.book.closed.fill" }
        if category.contains("Quran") { return "moon.stars.fill" }
        if category.contains("Alim") { return "person.circle.fill" }
        return "books.vertical.fill"
    }

    func categoryColor(_ category: String) -> Color {
        if category.contains("Hədis") { return .orange }
        if category.contains("Quran") { return .purple }
        if category.contains("Alim") { return .blue }
        return .teal
    }
}

// MARK: - Premium Book Card
struct PremiumBookCard: View {
    let book: Book
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .cornerRadius(15)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(15)
                    )
                    .shadow(color: book.color.opacity(0.3), radius: 12, x: 0, y: 6)

                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.yellow)
                    Text(book.rating)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Search Results View
struct SearchResultsView: View {
    let filteredBooks: [Book]

    var body: some View {
        if filteredBooks.isEmpty {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }

                Text("Nəticə tapılmadı")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Zəhmət olmasa axtarış şərtlərini dəyişin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
        } else {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                spacing: 20
            ) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookCardView(book: book, isScrolled: { _ in }, size: CGSize(width: 300, height: 400))) {
                        PremiumBookCard(book: book)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
//
//// MARK: - Advanced Filter Sheet
//struct AdvancedFilterSheet: View {
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section("Sıralama") {
//                    Picker("Sıralama seçimi", selection: .constant("popular")) {
//                        Text("Populyar").tag("popular")
//                        Text("Ən yeni").tag("newest")
//                        Text("Reytinq").tag("rating")
//                        Text("Əlifba").tag("alphabetical")
//                    }
//                }
//
//                Section("Kateqoriya") {
//                    Toggle("Hədis Kitabları", isOn: .constant(true))
//                    Toggle("Quran Təfsir", isOn: .constant(true))
//                    Toggle("İslam Alimləri", isOn: .constant(true))
//                }
//            }
//            .navigationTitle("Filter")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Bitdi") { dismiss() }
//                }
//            }
//        }
//    }
//}


struct IslamicLibraryView: View {
    @State private var searchText: String = ""
    @State private var selectedBook: Book? = nil
    @State private var showBookDetail = false
    @State private var favoriteBooks: Set<String> = []
    @State private var isNightMode = false
    @State private var showZikrCounter = false
    @State private var zikrCount = 0
    @Namespace private var animation

    var body: some View {
        NavigationStack {
            ZStack {
                // İslami fon
                LinearGradient(
                    colors: isNightMode ? [.black, .green.opacity(0.3)] : [.white, .green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(
                    Image("islamic_pattern")
                        .resizable()
                        .scaledToFill()
                        .opacity(isNightMode ? 0.04 : 0.08)
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {

                        // Salam banner
                        IslamicWelcomeHeader(isNightMode: $isNightMode)
                            .padding(.top, 20)

                        // Axtarış bar

                        // Əsas kateqoriyalar
                        IslamicCategoryGrid(
                            selectedBook: $selectedBook,
                            showBookDetail: $showBookDetail,
                            favoriteBooks: $favoriteBooks,
                            animation: animation
                        )

                        // Quran oxumağa başla
//                        Button(action: {
//                            HapticManager.shared.trigger()
//                            showBookDetail = true
//                        }) {
//                            HStack {
//                                Image(systemName: "book.closed.fill")
//                                Text("Qurani-Kərim oxumağa başla")
//                            }
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(
//                                LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
//                            )
//                            .cornerRadius(16)
//                            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
//                            .padding(.horizontal, 20)
//                        }

                        // Zikr sayğacı
                        if showZikrCounter {
                            ZikrCounterView(zikrCount: $zikrCount)
                        }
                    }
                    .padding(.bottom, 80)
                }

                // Floating action buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        // Zikr aç/bağla
                        FloatingButton(icon: "hands.sparkles.fill", color: .green) {
                            withAnimation(.spring()) {
                                showZikrCounter.toggle()
                            }
                        }

                        // Dark mode toggle
                        FloatingButton(icon: isNightMode ? "sun.max.fill" : "moon.stars.fill", color: .teal) {
                            withAnimation(.easeInOut) {
                                isNightMode.toggle()
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationDestination(isPresented: $showBookDetail) {
                if let book = selectedBook {
                    IslamicBookDetailView(book: book)
                } else {
                    QuranReaderView()
                }
            }
        }
    }
}

// MARK: - Header
struct IslamicWelcomeHeader: View {
    @Binding var isNightMode: Bool
    @State private var animateGlow = false

    var body: some View {
        VStack(spacing: 8) {
            Text("بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيمِ")
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: .green.opacity(0.5), radius: animateGlow ? 10 : 2)

            Text("İslami Kitabxanaya Xoş Gəldiniz")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(isNightMode ? .white : .black)

            Text("Elm axtarmaq hər bir müsəlmana vacibdir.")
                .font(.subheadline).italic()
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateGlow.toggle()
            }
        }
    }
}

// MARK: - Search Bar

// MARK: - Categories Grid
struct IslamicCategoryGrid: View {
    @Binding var selectedBook: Book?
    @Binding var showBookDetail: Bool
    @Binding var favoriteBooks: Set<String>
    var animation: Namespace.ID

    let sampleBooks = books.prefix(8)

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)]) {
            ForEach(sampleBooks) { book in
                VStack(spacing: 10) {
                    Image(book.thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 220)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                        .matchedGeometryEffect(id: book.id, in: animation)
                        .shadow(color: .green.opacity(0.2), radius: 8)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedBook = book
                                showBookDetail = true
                            }
                        }

                    Text(book.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(book.author)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button {
                        withAnimation(.spring()) {
                            toggleFavorite(book)
                        }
                    } label: {
                        Image(systemName: favoriteBooks.contains(book.id) ? "heart.fill" : "heart")
                            .foregroundColor(favoriteBooks.contains(book.id) ? .red : .green)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func toggleFavorite(_ book: Book) {
        if favoriteBooks.contains(book.id) {
            favoriteBooks.remove(book.id)
        } else {
            favoriteBooks.insert(book.id)
        }
    }
}

// MARK: - Book Detail
struct IslamicBookDetailView: View {
    let book: Book
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(book.thumbnail)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding()

                Text(book.title)
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)

                Text("Müəllif: \(book.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Text(book.description ?? "Bu kitab haqqında məlumat əlavə ediləcək.")
                    .font(.body)
                    .padding()

                Button("Oxumağa Başla") {
                    // Açıq oxuma rejiminə keçid
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle(book.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Zikr Counter
struct ZikrCounterView: View {
    @Binding var zikrCount: Int

    var body: some View {
        VStack(spacing: 10) {
            Text("Zikr Sayğacı")
                .font(.headline)
            Text("\(zikrCount)")
                .font(.largeTitle)
                .bold()
            HStack(spacing: 20) {
                Button(action: { if zikrCount > 0 { zikrCount -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                }
                Button(action: { zikrCount += 1 }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .font(.title)
            .foregroundColor(.green)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .green.opacity(0.2), radius: 8)
        .transition(.scale)
    }
}

// MARK: - Floating Button
struct FloatingButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(color.gradient)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quran Reader
struct QuranReaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("📖 Qurani-Kərim")
                .font(.title)
                .fontWeight(.bold)
            Text("Oxumağa başla, səbir və hüzurla.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(colors: [.green.opacity(0.2), .white], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(20)
        .navigationTitle("Qurani-Kərim")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchText: .constant(""))
    }
}

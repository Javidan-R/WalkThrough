import SwiftUI

struct MainAppView: View {
    @State private var searchText = ""
    @State private var showSettings = false
    @EnvironmentObject var appState: AppState

    enum Tab: Hashable {
        case books, favorites, settings
    }

    @State private var selectedTab: Tab = .books

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Books Tab
            NavigationStack {
                SearchView(searchText: $searchText)
                    .navigationTitle("📚 Kitabxana")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Kitablar", systemImage: "book.pages.fill")
            }
            .tag(Tab.books)

            // MARK: - Favorites Tab
            NavigationStack {
                FavoritesView(book: books.first ?? Book(
                    title: "Sample",
                    author: "Author",
                    rating: "4.5",
                    thumbnail: "sample",
                    color: .blue,
                    description: "Description",
                        ), size: CGSize(width: 160, height: 220))
                    .navigationTitle("❤️ Favoritlər")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Yaddaş", systemImage: "bookmark.fill")
            }
            .tag(Tab.favorites)

            // MARK: - Settings Tab
            NavigationStack {
                SettingsTabView(showSettings: $showSettings)
                    .navigationTitle("⚙️ Ayarlar")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .tint(.green)
        .onAppear {
            configureTabBar()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(mode: .modal)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled(false)
        }
    }

    private func configureTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
    }
}

// MARK: - Settings Tab View (Fixed)
struct SettingsTabView: View {
    @Binding var showSettings: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green.opacity(0.2), .blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    Text("Tənzimləmələr")
                        .font(.title2.bold())

                    Text("Profilinizi xüsusiləşdirin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)

                // Settings Options
                VStack(spacing: 12) {
                    // General Settings
                    SettingsOptionCard(
                        icon: "slider.horizontal.3",
                        title: "Ümumi Ayarlar",
                        subtitle: "Font, tema, dil",
                        action: { showSettings = true }
                    )

                    // Account
                    SettingsOptionCard(
                        icon: "person.crop.circle.fill",
                        title: "Hesab Məlumatları",
                        subtitle: "Profil və təhlükəsizlik",
                        action: {}
                    )

                    // Reading Stats
                    SettingsOptionCard(
                        icon: "chart.bar.fill",
                        title: "Oxuma Statistikası",
                        subtitle: "Fəaliyyət və məqsədlər",
                        action: {}
                    )

                    // Notifications
                    SettingsOptionCard(
                        icon: "bell.circle.fill",
                        title: "Bildirişlər",
                        subtitle: "Du'a və günlük xatırlatmalar",
                        action: {}
                    )

                    // About
                    SettingsOptionCard(
                        icon: "info.circle.fill",
                        title: "Haqqında",
                        subtitle: "Versiya və məlumat",
                        action: {}
                    )
                }
                .padding(.horizontal)

                // Info Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tətbiq Məlumatı")
                        .font(.headline)
                        .fontWeight(.semibold)


                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
                    .frame(height: 20)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}


// MARK: - Info Row


#Preview {
    MainAppView()
        .environmentObject(AppState())
}

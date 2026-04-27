import SwiftUI

struct RootView: View {
    @StateObject private var favoritesViewModel: FavoritesViewModel
    private let apiClient: APIClient

    init(
        apiClient: APIClient = LiveAPIClient(),
        favoritesStore: FavoritesStore = UserDefaultsFavoritesStore()
    ) {
        self.apiClient = apiClient
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(store: favoritesStore))
    }

    var body: some View {
        TabView {
            NavigationStack {
                SearchView(
                    viewModel: SearchViewModel(apiClient: apiClient),
                    favoritesViewModel: favoritesViewModel,
                    apiClient: apiClient
                )
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                FavoritesView(
                    viewModel: favoritesViewModel,
                    apiClient: apiClient
                )
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }
        }
    }
}

#Preview {
    RootView(
        apiClient: PreviewAPIClient(),
        favoritesStore: PreviewFavoritesStore(favorites: ["octocat"])
    )
}

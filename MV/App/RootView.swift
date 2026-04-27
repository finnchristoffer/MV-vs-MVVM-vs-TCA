import SwiftUI

struct RootView: View {
    @State private var favoritesModel: FavoritesModel
    private let apiClient: APIClient

    init(
        apiClient: APIClient = LiveAPIClient(),
        favoritesStore: FavoritesStore = UserDefaultsFavoritesStore()
    ) {
        self.apiClient = apiClient
        _favoritesModel = State(initialValue: FavoritesModel(store: favoritesStore))
    }

    var body: some View {
        TabView {
            NavigationStack {
                SearchView(
                    model: SearchModel(apiClient: apiClient),
                    favoritesModel: favoritesModel,
                    apiClient: apiClient
                )
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                FavoritesView(
                    model: favoritesModel,
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

import SwiftUI

struct FavoritesView: View {
    private let model: FavoritesModel
    private let apiClient: APIClient

    init(model: FavoritesModel, apiClient: APIClient) {
        self.model = model
        self.apiClient = apiClient
    }

    var body: some View {
        Group {
            if model.sortedFavoriteLogins.isEmpty {
                ContentUnavailableView("No Favorites", systemImage: "star")
            } else {
                List(model.sortedFavoriteLogins, id: \.self) { login in
                    NavigationLink(value: login) {
                        Label(login, systemImage: "person.crop.circle")
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .navigationDestination(for: String.self) { login in
            DetailView(
                model: DetailModel(apiClient: apiClient, login: login),
                favoritesModel: model
            )
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(
            model: FavoritesModel(store: PreviewFavoritesStore(favorites: ["octocat"])),
            apiClient: PreviewAPIClient()
        )
    }
}

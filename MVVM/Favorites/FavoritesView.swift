import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var viewModel: FavoritesViewModel
    private let apiClient: APIClient

    init(viewModel: FavoritesViewModel, apiClient: APIClient) {
        self.viewModel = viewModel
        self.apiClient = apiClient
    }

    var body: some View {
        Group {
            if viewModel.sortedFavoriteLogins.isEmpty {
                ContentUnavailableView("No Favorites", systemImage: "star")
            } else {
                List(viewModel.sortedFavoriteLogins, id: \.self) { login in
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
                viewModel: DetailViewModel(apiClient: apiClient, login: login),
                favoritesViewModel: viewModel
            )
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(
            viewModel: FavoritesViewModel(store: PreviewFavoritesStore(favorites: ["octocat"])),
            apiClient: PreviewAPIClient()
        )
    }
}

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @ObservedObject private var favoritesViewModel: FavoritesViewModel
    private let apiClient: APIClient

    init(
        viewModel: SearchViewModel,
        favoritesViewModel: FavoritesViewModel,
        apiClient: APIClient
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesViewModel = favoritesViewModel
        self.apiClient = apiClient
    }

    var body: some View {
        content
            .navigationTitle("Search")
            .searchable(
                text: Binding(
                    get: { viewModel.query },
                    set: { viewModel.searchQueryChanged($0) }
                ),
                prompt: "GitHub username"
            )
            .navigationDestination(for: User.self) { user in
                DetailView(
                    viewModel: DetailViewModel(apiClient: apiClient, login: user.login),
                    favoritesViewModel: favoritesViewModel
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView("Search GitHub", systemImage: "magnifyingglass")
        case .loading:
            LoadingStateView(title: "Searching")
        case .empty:
            ContentUnavailableView("No Users", systemImage: "person.crop.circle.badge.questionmark")
        case let .loaded(users):
            List(users) { user in
                HStack(spacing: Spacing.medium) {
                    NavigationLink(value: user) {
                        UserRow(
                            user: user,
                            isFavorite: favoritesViewModel.isFavorite(login: user.login)
                        )
                    }

                    Button {
                        favoritesViewModel.toggle(login: user.login)
                    } label: {
                        Image(systemName: favoritesViewModel.isFavorite(login: user.login) ? "star.fill" : "star")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.yellow)
                    .accessibilityLabel(favoritesViewModel.isFavorite(login: user.login) ? "Remove favorite" : "Add favorite")
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        favoritesViewModel.toggle(login: user.login)
                    } label: {
                        Label(
                            favoritesViewModel.isFavorite(login: user.login) ? "Unfavorite" : "Favorite",
                            systemImage: favoritesViewModel.isFavorite(login: user.login) ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
            .listStyle(.plain)
        case let .error(message):
            ErrorStateView(message: message) {
                viewModel.retry()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(apiClient: PreviewAPIClient()),
            favoritesViewModel: FavoritesViewModel(store: PreviewFavoritesStore()),
            apiClient: PreviewAPIClient()
        )
    }
}

import SwiftUI

struct SearchView: View {
    @State private var model: SearchModel
    private let favoritesModel: FavoritesModel
    private let apiClient: APIClient

    init(
        model: SearchModel,
        favoritesModel: FavoritesModel,
        apiClient: APIClient
    ) {
        _model = State(initialValue: model)
        self.favoritesModel = favoritesModel
        self.apiClient = apiClient
    }

    var body: some View {
        content
            .navigationTitle("Search")
            .searchable(
                text: Binding(
                    get: { model.query },
                    set: { model.searchQueryChanged($0) }
                ),
                prompt: "GitHub username"
            )
            .navigationDestination(for: User.self) { user in
                DetailView(
                    model: DetailModel(apiClient: apiClient, login: user.login),
                    favoritesModel: favoritesModel
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
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
                            isFavorite: favoritesModel.isFavorite(login: user.login)
                        )
                    }

                    Button {
                        favoritesModel.toggle(login: user.login)
                    } label: {
                        Image(systemName: favoritesModel.isFavorite(login: user.login) ? "star.fill" : "star")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.yellow)
                    .accessibilityLabel(favoritesModel.isFavorite(login: user.login) ? "Remove favorite" : "Add favorite")
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        favoritesModel.toggle(login: user.login)
                    } label: {
                        Label(
                            favoritesModel.isFavorite(login: user.login) ? "Unfavorite" : "Favorite",
                            systemImage: favoritesModel.isFavorite(login: user.login) ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
            .listStyle(.plain)
        case let .error(message):
            ErrorStateView(message: message) {
                model.retry()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(
            model: SearchModel(apiClient: PreviewAPIClient()),
            favoritesModel: FavoritesModel(store: PreviewFavoritesStore()),
            apiClient: PreviewAPIClient()
        )
    }
}

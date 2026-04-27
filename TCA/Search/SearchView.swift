import ComposableArchitecture
import SwiftUI

struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    let favoritesStore: StoreOf<FavoritesFeature>

    var body: some View {
        content
            .navigationTitle("Search")
            .searchable(
                text: Binding(
                    get: { store.query },
                    set: { store.send(.searchQueryChanged($0)) }
                ),
                prompt: "GitHub username"
            )
            .navigationDestination(for: User.self) { user in
                DetailView(
                    store: Store(initialState: DetailFeature.State(login: user.login)) {
                        DetailFeature()
                    },
                    favoritesStore: favoritesStore
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch store.searchState {
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
                            isFavorite: favoritesStore.favoriteLogins.contains(user.login)
                        )
                    }

                    Button {
                        favoritesStore.send(.toggleFavorite(login: user.login))
                    } label: {
                        Image(systemName: favoritesStore.favoriteLogins.contains(user.login) ? "star.fill" : "star")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.yellow)
                    .accessibilityLabel(favoritesStore.favoriteLogins.contains(user.login) ? "Remove favorite" : "Add favorite")
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        favoritesStore.send(.toggleFavorite(login: user.login))
                    } label: {
                        Label(
                            favoritesStore.favoriteLogins.contains(user.login) ? "Unfavorite" : "Favorite",
                            systemImage: favoritesStore.favoriteLogins.contains(user.login) ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
            .listStyle(.plain)
        case let .error(message):
            ErrorStateView(message: message) {
                store.send(.retryTapped)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(
            store: Store(initialState: SearchFeature.State(searchState: .loaded([PreviewData.user]))) {
                SearchFeature()
            },
            favoritesStore: Store(initialState: FavoritesFeature.State(favoriteLogins: ["octocat"])) {
                FavoritesFeature()
            }
        )
    }
}

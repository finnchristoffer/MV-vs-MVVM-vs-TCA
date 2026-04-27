import ComposableArchitecture

@Reducer
struct FavoritesFeature {
    @ObservableState
    struct State: Equatable {
        var favoriteLogins: Set<String> = []

        var sortedFavoriteLogins: [String] {
            favoriteLogins.sorted()
        }

        func isFavorite(login: String) -> Bool {
            favoriteLogins.contains(login)
        }
    }

    enum Action: Equatable {
        case loadFavorites
        case toggleFavorite(login: String)
    }

    @Dependency(\.favoritesClient) private var favoritesClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadFavorites:
                state.favoriteLogins = favoritesClient.load()
                return .none

            case let .toggleFavorite(login):
                if state.favoriteLogins.contains(login) {
                    state.favoriteLogins.remove(login)
                } else {
                    state.favoriteLogins.insert(login)
                }

                favoritesClient.save(state.favoriteLogins)
                return .none
            }
        }
    }
}

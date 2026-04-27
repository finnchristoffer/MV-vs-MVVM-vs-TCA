import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var search = SearchFeature.State()
        var favorites = FavoritesFeature.State()
    }

    enum Action: Equatable {
        case task
        case search(SearchFeature.Action)
        case favorites(FavoritesFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: \.search) {
            SearchFeature()
        }

        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }

        Reduce { _, action in
            switch action {
            case .task:
                return .send(.favorites(.loadFavorites))

            case .search, .favorites:
                return .none
            }
        }
    }
}

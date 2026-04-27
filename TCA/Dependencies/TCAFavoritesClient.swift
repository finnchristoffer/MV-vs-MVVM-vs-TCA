import ComposableArchitecture

struct TCAFavoritesClient: Sendable {
    var load: @Sendable () -> Set<String>
    var save: @Sendable (Set<String>) -> Void
}

extension TCAFavoritesClient: DependencyKey {
    static let liveValue = Self(
        load: {
            UserDefaultsFavoritesStore().load()
        },
        save: { favorites in
            UserDefaultsFavoritesStore().save(favorites)
        }
    )
}

extension DependencyValues {
    var favoritesClient: TCAFavoritesClient {
        get { self[TCAFavoritesClient.self] }
        set { self[TCAFavoritesClient.self] = newValue }
    }
}

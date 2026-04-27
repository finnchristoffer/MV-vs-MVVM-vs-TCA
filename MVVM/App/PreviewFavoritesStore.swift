struct PreviewFavoritesStore: FavoritesStore {
    private let favorites: Set<String>

    init(favorites: Set<String> = []) {
        self.favorites = favorites
    }

    func load() -> Set<String> {
        favorites
    }

    func save(_ favorites: Set<String>) {}
}

protocol FavoritesStore {
    func load() -> Set<String>
    func save(_ favorites: Set<String>)
}

@testable import MVApp

final class MockFavoritesStore: FavoritesStore {
    private let initialFavorites: Set<String>
    private(set) var savedFavorites: [Set<String>] = []

    init(initialFavorites: Set<String> = []) {
        self.initialFavorites = initialFavorites
    }

    func load() -> Set<String> {
        initialFavorites
    }

    func save(_ favorites: Set<String>) {
        savedFavorites.append(favorites)
    }
}

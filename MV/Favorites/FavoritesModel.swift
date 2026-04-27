import Foundation
import Observation

@MainActor
@Observable
final class FavoritesModel {
    private(set) var favoriteLogins: Set<String>

    @ObservationIgnored private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
        favoriteLogins = store.load()
    }

    var sortedFavoriteLogins: [String] {
        favoriteLogins.sorted()
    }

    func isFavorite(login: String) -> Bool {
        favoriteLogins.contains(login)
    }

    func toggle(login: String) {
        if favoriteLogins.contains(login) {
            favoriteLogins.remove(login)
        } else {
            favoriteLogins.insert(login)
        }

        store.save(favoriteLogins)
    }
}

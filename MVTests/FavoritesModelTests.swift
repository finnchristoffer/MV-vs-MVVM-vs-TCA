@testable import MVApp
import XCTest

@MainActor
final class FavoritesModelTests: XCTestCase {
    func test_init_loadsPersistedFavorites() {
        let store = MockFavoritesStore(initialFavorites: ["octocat"])
        let model = FavoritesModel(store: store)

        XCTAssertEqual(model.favoriteLogins, ["octocat"])
        XCTAssertTrue(model.isFavorite(login: "octocat"))
    }

    func test_toggle_addsFavoriteAndPersists() {
        let store = MockFavoritesStore()
        let model = FavoritesModel(store: store)

        model.toggle(login: "octocat")

        XCTAssertEqual(model.favoriteLogins, ["octocat"])
        XCTAssertEqual(store.savedFavorites, [["octocat"]])
    }

    func test_toggle_removesFavoriteAndPersists() {
        let store = MockFavoritesStore(initialFavorites: ["octocat"])
        let model = FavoritesModel(store: store)

        model.toggle(login: "octocat")

        XCTAssertEqual(model.favoriteLogins, [])
        XCTAssertEqual(store.savedFavorites, [[]])
    }
}

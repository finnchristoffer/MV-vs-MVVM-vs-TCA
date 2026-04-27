@testable import MVVMApp
import XCTest

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func test_init_loadsPersistedFavorites() {
        let store = MockFavoritesStore(initialFavorites: ["octocat"])
        let viewModel = FavoritesViewModel(store: store)

        XCTAssertEqual(viewModel.favoriteLogins, ["octocat"])
        XCTAssertTrue(viewModel.isFavorite(login: "octocat"))
    }

    func test_toggle_addsFavoriteAndPersists() {
        let store = MockFavoritesStore()
        let viewModel = FavoritesViewModel(store: store)

        viewModel.toggle(login: "octocat")

        XCTAssertEqual(viewModel.favoriteLogins, ["octocat"])
        XCTAssertEqual(store.savedFavorites, [["octocat"]])
    }

    func test_toggle_removesFavoriteAndPersists() {
        let store = MockFavoritesStore(initialFavorites: ["octocat"])
        let viewModel = FavoritesViewModel(store: store)

        viewModel.toggle(login: "octocat")

        XCTAssertEqual(viewModel.favoriteLogins, [])
        XCTAssertEqual(store.savedFavorites, [[]])
    }
}

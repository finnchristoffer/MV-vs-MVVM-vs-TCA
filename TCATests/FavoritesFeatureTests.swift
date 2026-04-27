import ComposableArchitecture
@testable import TCAApp
import XCTest

@MainActor
final class FavoritesFeatureTests: XCTestCase {
    func test_init_loadsPersistedFavorites() async {
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoritesClient.load = { ["octocat"] }
        }

        await store.send(.loadFavorites) {
            $0.favoriteLogins = ["octocat"]
        }
    }

    func test_toggle_addsFavoriteAndPersists() async {
        let recorder = FavoritesRecorder()
        let store = TestStore(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoritesClient.save = { favorites in
                recorder.append(favorites)
            }
        }

        await store.send(.toggleFavorite(login: "octocat")) {
            $0.favoriteLogins = ["octocat"]
        }

        XCTAssertEqual(recorder.savedFavorites, [["octocat"]])
    }

    func test_toggle_removesFavoriteAndPersists() async {
        let recorder = FavoritesRecorder()
        let store = TestStore(initialState: FavoritesFeature.State(favoriteLogins: ["octocat"])) {
            FavoritesFeature()
        } withDependencies: {
            $0.favoritesClient.save = { favorites in
                recorder.append(favorites)
            }
        }

        await store.send(.toggleFavorite(login: "octocat")) {
            $0.favoriteLogins = []
        }

        XCTAssertEqual(recorder.savedFavorites, [[]])
    }
}

private final class FavoritesRecorder: @unchecked Sendable {
    private(set) var savedFavorites: [Set<String>] = []

    func append(_ favorites: Set<String>) {
        savedFavorites.append(favorites)
    }
}

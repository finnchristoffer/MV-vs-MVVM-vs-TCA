@testable import MVVMApp
import XCTest

final class UserDefaultsFavoritesStoreTests: XCTestCase {
    func test_save_persistsFavorites() throws {
        let suiteName = "UserDefaultsFavoritesStoreTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsFavoritesStore(userDefaults: userDefaults, key: "favorites")

        store.save(["pointfreeco", "octocat"])

        XCTAssertEqual(store.load(), ["octocat", "pointfreeco"])
        XCTAssertEqual(userDefaults.stringArray(forKey: "favorites"), ["octocat", "pointfreeco"])
    }

    func test_load_returnsEmptySetWhenNoFavoritesExist() throws {
        let suiteName = "UserDefaultsFavoritesStoreTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsFavoritesStore(userDefaults: userDefaults, key: "favorites")

        XCTAssertEqual(store.load(), [])
    }
}

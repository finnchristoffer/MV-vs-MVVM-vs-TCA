import Foundation

struct UserDefaultsFavoritesStore: FavoritesStore {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = .standard,
        key: String = "favoriteUserLogins"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> Set<String> {
        Set(userDefaults.stringArray(forKey: key) ?? [])
    }

    func save(_ favorites: Set<String>) {
        userDefaults.set(Array(favorites).sorted(), forKey: key)
    }
}

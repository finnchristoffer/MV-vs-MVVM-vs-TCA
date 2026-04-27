protocol APIClient: Sendable {
    func searchUsers(query: String) async throws -> [User]
    func fetchUser(login: String) async throws -> User
    func fetchRepos(login: String) async throws -> [Repo]
}

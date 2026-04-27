@testable import MVApp

actor MockAPIClient: APIClient {
    private(set) var searchedQueries: [String] = []
    private(set) var fetchedUsers: [String] = []
    private(set) var fetchedRepos: [String] = []

    var searchUsersResult: Result<[User], Error>
    var fetchUserResult: Result<User, Error>
    var fetchReposResult: Result<[Repo], Error>

    init(
        searchUsersResult: Result<[User], Error> = .success([]),
        fetchUserResult: Result<User, Error> = .success(TestFixtures.user),
        fetchReposResult: Result<[Repo], Error> = .success([TestFixtures.repo])
    ) {
        self.searchUsersResult = searchUsersResult
        self.fetchUserResult = fetchUserResult
        self.fetchReposResult = fetchReposResult
    }

    func searchUsers(query: String) async throws -> [User] {
        searchedQueries.append(query)
        return try searchUsersResult.get()
    }

    func fetchUser(login: String) async throws -> User {
        fetchedUsers.append(login)
        return try fetchUserResult.get()
    }

    func fetchRepos(login: String) async throws -> [Repo] {
        fetchedRepos.append(login)
        return try fetchReposResult.get()
    }
}

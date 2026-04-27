import ComposableArchitecture

struct TCAAPIClient: Sendable {
    var searchUsers: @Sendable (String) async throws -> [User]
    var fetchUser: @Sendable (String) async throws -> User
    var fetchRepos: @Sendable (String) async throws -> [Repo]
}

extension TCAAPIClient: DependencyKey {
    static let liveValue = Self(apiClient: LiveAPIClient())
}

extension TCAAPIClient {
    init(apiClient: APIClient) {
        searchUsers = { query in
            try await apiClient.searchUsers(query: query)
        }
        fetchUser = { login in
            try await apiClient.fetchUser(login: login)
        }
        fetchRepos = { login in
            try await apiClient.fetchRepos(login: login)
        }
    }
}

extension DependencyValues {
    var apiClient: TCAAPIClient {
        get { self[TCAAPIClient.self] }
        set { self[TCAAPIClient.self] = newValue }
    }
}

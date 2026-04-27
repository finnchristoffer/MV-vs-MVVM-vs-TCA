@testable import MVApp

actor SuspendingDetailAPIClient: APIClient {
    private(set) var startedRequests: [String] = []
    private var userContinuation: CheckedContinuation<User, Error>?
    private var reposContinuation: CheckedContinuation<[Repo], Error>?

    func searchUsers(query: String) async throws -> [User] {
        []
    }

    func fetchUser(login: String) async throws -> User {
        startedRequests.append("user:\(login)")
        return try await withCheckedThrowingContinuation { continuation in
            userContinuation = continuation
        }
    }

    func fetchRepos(login: String) async throws -> [Repo] {
        startedRequests.append("repos:\(login)")
        return try await withCheckedThrowingContinuation { continuation in
            reposContinuation = continuation
        }
    }

    func resume(user: User, repos: [Repo]) {
        userContinuation?.resume(returning: user)
        reposContinuation?.resume(returning: repos)
        userContinuation = nil
        reposContinuation = nil
    }
}

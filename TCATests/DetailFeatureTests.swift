import ComposableArchitecture
@testable import TCAApp
import XCTest

@MainActor
final class DetailFeatureTests: XCTestCase {
    func test_load_fetchesProfileAndReposInParallel() async {
        let apiClient = SuspendingDetailAPIClient()
        let store = TestStore(initialState: DetailFeature.State(login: "octocat")) {
            DetailFeature()
        } withDependencies: {
            $0.apiClient.fetchUser = { login in
                try await apiClient.fetchUser(login: login)
            }
            $0.apiClient.fetchRepos = { login in
                try await apiClient.fetchRepos(login: login)
            }
        }

        await store.send(.task) {
            $0.detailState = .loading
        }

        for _ in 0..<50 {
            let startedRequests = await apiClient.startedRequests
            if startedRequests.count == 2 {
                break
            }

            await Task.yield()
        }

        let startedRequests = await apiClient.startedRequests
        XCTAssertEqual(Set(startedRequests), ["user:octocat", "repos:octocat"])

        await apiClient.resume(user: TestFixtures.user, repos: [TestFixtures.repo])
        await store.receive(.detailResponse(.success(user: TestFixtures.user, repos: [TestFixtures.repo]))) {
            $0.detailState = .loaded(user: TestFixtures.user, repos: [TestFixtures.repo])
        }
    }

    func test_load_setsErrorStateWhenProfileRequestFails() async {
        let store = TestStore(initialState: DetailFeature.State(login: "octocat")) {
            DetailFeature()
        } withDependencies: {
            $0.apiClient.fetchUser = { _ in throw TestError.expected }
            $0.apiClient.fetchRepos = { _ in [TestFixtures.repo] }
        }

        await store.send(.task) {
            $0.detailState = .loading
        }
        await store.receive(\.detailResponse) {
            $0.detailState = .error(message: TestError.expected.localizedDescription)
        }
    }
}

private actor SuspendingDetailAPIClient {
    private(set) var startedRequests: [String] = []
    private var userContinuation: CheckedContinuation<User, Error>?
    private var reposContinuation: CheckedContinuation<[Repo], Error>?

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

@testable import MVApp
import XCTest

@MainActor
final class DetailModelTests: XCTestCase {
    func test_load_fetchesProfileAndReposInParallel() async {
        let apiClient = SuspendingDetailAPIClient()
        let model = DetailModel(apiClient: apiClient, login: "octocat")

        let loadTask = Task {
            await model.load()
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
        await loadTask.value

        XCTAssertEqual(model.state, .loaded(user: TestFixtures.user, repos: [TestFixtures.repo]))
    }

    func test_load_setsErrorStateWhenProfileRequestFails() async {
        let apiClient = MockAPIClient(fetchUserResult: .failure(TestError.expected))
        let model = DetailModel(apiClient: apiClient, login: "octocat")

        await model.load()

        guard case .error = model.state else {
            XCTFail("Expected error state, got \(model.state)")
            return
        }
    }
}

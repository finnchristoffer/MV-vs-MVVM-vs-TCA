@testable import MVVMApp
import XCTest

@MainActor
final class DetailViewModelTests: XCTestCase {
    func test_load_fetchesProfileAndReposInParallel() async {
        let apiClient = SuspendingDetailAPIClient()
        let viewModel = DetailViewModel(apiClient: apiClient, login: "octocat")

        let loadTask = Task {
            await viewModel.load()
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

        XCTAssertEqual(viewModel.state, .loaded(user: TestFixtures.user, repos: [TestFixtures.repo]))
    }

    func test_load_setsErrorStateWhenProfileRequestFails() async {
        let apiClient = MockAPIClient(fetchUserResult: .failure(TestError.expected))
        let viewModel = DetailViewModel(apiClient: apiClient, login: "octocat")

        await viewModel.load()

        guard case .error = viewModel.state else {
            XCTFail("Expected error state, got \(viewModel.state)")
            return
        }
    }
}

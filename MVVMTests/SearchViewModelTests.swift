@testable import MVVMApp
import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    func test_searchQueryChange_debouncesAndFetchesUsers() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let viewModel = SearchViewModel(apiClient: apiClient, searchDelay: searchDelay)

        viewModel.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.loaded([TestFixtures.user]), in: viewModel)

        let searchedQueries = await apiClient.searchedQueries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_cancelsPreviousSearch() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let viewModel = SearchViewModel(apiClient: apiClient, searchDelay: searchDelay)

        viewModel.searchQueryChanged("octo")
        await waitForPendingDelay(count: 1, in: searchDelay)
        viewModel.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 2, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.loaded([TestFixtures.user]), in: viewModel)

        let searchedQueries = await apiClient.searchedQueries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_setsEmptyStateWhenNoUsersReturn() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([]))
        let searchDelay = ManualSearchDelay()
        let viewModel = SearchViewModel(apiClient: apiClient, searchDelay: searchDelay)

        viewModel.searchQueryChanged("missing")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.empty, in: viewModel)
    }

    func test_searchQueryChange_setsErrorStateWhenRequestFails() async {
        let apiClient = MockAPIClient(searchUsersResult: .failure(TestError.expected))
        let searchDelay = ManualSearchDelay()
        let viewModel = SearchViewModel(apiClient: apiClient, searchDelay: searchDelay)

        viewModel.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchError(in: viewModel)
    }

    func test_searchQueryChange_emptyQueryClearsStateWithoutRequest() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let viewModel = SearchViewModel(apiClient: apiClient, searchDelay: searchDelay)

        viewModel.searchQueryChanged("   ")

        XCTAssertEqual(viewModel.state, .idle)
        let searchedQueries = await apiClient.searchedQueries
        XCTAssertTrue(searchedQueries.isEmpty)
    }

    private func waitForPendingDelay(
        count: Int,
        in searchDelay: ManualSearchDelay,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            let pendingCount = await searchDelay.pendingCount
            if pendingCount == count {
                return
            }

            await Task.yield()
        }

        let pendingCount = await searchDelay.pendingCount
        XCTFail("Expected \(count) pending delays, got \(pendingCount)", file: file, line: line)
    }
}

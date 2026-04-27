@testable import MVApp
import XCTest

@MainActor
final class SearchModelTests: XCTestCase {
    func test_searchQueryChange_debouncesAndFetchesUsers() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let model = SearchModel(apiClient: apiClient, searchDelay: searchDelay)

        model.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.loaded([TestFixtures.user]), in: model)

        let searchedQueries = await apiClient.searchedQueries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_cancelsPreviousSearch() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let model = SearchModel(apiClient: apiClient, searchDelay: searchDelay)

        model.searchQueryChanged("octo")
        await waitForPendingDelay(count: 1, in: searchDelay)
        model.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 2, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.loaded([TestFixtures.user]), in: model)

        let searchedQueries = await apiClient.searchedQueries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_setsEmptyStateWhenNoUsersReturn() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([]))
        let searchDelay = ManualSearchDelay()
        let model = SearchModel(apiClient: apiClient, searchDelay: searchDelay)

        model.searchQueryChanged("missing")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchState(.empty, in: model)
    }

    func test_searchQueryChange_setsErrorStateWhenRequestFails() async {
        let apiClient = MockAPIClient(searchUsersResult: .failure(TestError.expected))
        let searchDelay = ManualSearchDelay()
        let model = SearchModel(apiClient: apiClient, searchDelay: searchDelay)

        model.searchQueryChanged("octocat")
        await waitForPendingDelay(count: 1, in: searchDelay)
        await searchDelay.resumeAll()
        await waitForSearchError(in: model)
    }

    func test_searchQueryChange_emptyQueryClearsStateWithoutRequest() async {
        let apiClient = MockAPIClient(searchUsersResult: .success([TestFixtures.user]))
        let searchDelay = ManualSearchDelay()
        let model = SearchModel(apiClient: apiClient, searchDelay: searchDelay)

        model.searchQueryChanged("   ")

        XCTAssertEqual(model.state, .idle)
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

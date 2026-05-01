import ComposableArchitecture
@testable import TCAApp
import XCTest

@MainActor
final class SearchFeatureTests: XCTestCase {
    func test_searchQueryChange_debouncesAndFetchesUsers() async {
        let clock = TestClock()
        let recorder = QueryRecorder()
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.searchUsers = { query in
                await recorder.append(query)
                return [TestFixtures.user]
            }
        }

        await store.send(.searchQueryChanged("octocat")) {
            $0.query = "octocat"
            $0.searchState = .loading
        }
        await clock.advance(by: .milliseconds(400))
        await store.receive(.searchResponse(.success([TestFixtures.user]))) {
            $0.searchState = .loaded([TestFixtures.user])
        }

        let searchedQueries = await recorder.queries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_cancelsPreviousSearch() async {
        let clock = TestClock()
        let recorder = QueryRecorder()
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.searchUsers = { query in
                await recorder.append(query)
                return [TestFixtures.user]
            }
        }

        await store.send(.searchQueryChanged("octo")) {
            $0.query = "octo"
            $0.searchState = .loading
        }
        await store.send(.searchQueryChanged("octocat")) {
            $0.query = "octocat"
        }
        await clock.advance(by: .milliseconds(400))
        await store.receive(.searchResponse(.success([TestFixtures.user]))) {
            $0.searchState = .loaded([TestFixtures.user])
        }

        let searchedQueries = await recorder.queries
        XCTAssertEqual(searchedQueries, ["octocat"])
    }

    func test_searchQueryChange_setsEmptyStateWhenNoUsersReturn() async {
        let clock = TestClock()
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.searchUsers = { _ in [] }
        }

        await store.send(.searchQueryChanged("missing")) {
            $0.query = "missing"
            $0.searchState = .loading
        }
        await clock.advance(by: .milliseconds(400))
        await store.receive(.searchResponse(.success([]))) {
            $0.searchState = .empty
        }
    }

    func test_searchQueryChange_setsErrorStateWhenRequestFails() async {
        let clock = TestClock()
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.searchUsers = { _ in throw TestError.expected }
        }

        await store.send(.searchQueryChanged("octocat")) {
            $0.query = "octocat"
            $0.searchState = .loading
        }
        await clock.advance(by: .milliseconds(400))
        await store.receive(\.searchResponse) {
            $0.searchState = .error(message: TestError.expected.localizedDescription)
        }
    }

    func test_searchQueryChange_emptyQueryClearsStateWithoutRequest() async {
        let clock = TestClock()
        let recorder = QueryRecorder()
        let store = TestStore(initialState: SearchFeature.State(searchState: .loaded([TestFixtures.user]))) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.apiClient.searchUsers = { query in
                await recorder.append(query)
                return [TestFixtures.user]
            }
        }

        await store.send(.searchQueryChanged("   ")) {
            $0.query = "   "
            $0.searchState = .idle
        }

        let searchedQueries = await recorder.queries
        XCTAssertTrue(searchedQueries.isEmpty)
    }
}

private actor QueryRecorder {
    private(set) var queries: [String] = []

    func append(_ query: String) {
        queries.append(query)
    }
}

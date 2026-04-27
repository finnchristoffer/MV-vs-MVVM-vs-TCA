import ComposableArchitecture
import Foundation

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var query = ""
        var searchState: SearchViewState = .idle
    }

    enum Action: Equatable {
        case searchQueryChanged(String)
        case retryTapped
        case searchResponse(SearchResponse)
    }

    enum SearchResponse: Equatable {
        case success([User])
        case failure(String)
    }

    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.continuousClock) private var clock

    private enum CancelID {
        case search
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchQueryChanged(query):
                state.query = query

                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedQuery.isEmpty else {
                    state.searchState = .idle
                    return .cancel(id: CancelID.search)
                }

                state.searchState = .loading
                return .run { [apiClient, clock] send in
                    try await clock.sleep(for: .milliseconds(300))
                    let users = try await apiClient.searchUsers(trimmedQuery)
                    await send(.searchResponse(.success(users)))
                } catch: { error, send in
                    guard !(error is CancellationError) else {
                        return
                    }

                    await send(.searchResponse(.failure(error.localizedDescription)))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case .retryTapped:
                return .send(.searchQueryChanged(state.query))

            case let .searchResponse(.success(users)):
                state.searchState = users.isEmpty ? .empty : .loaded(users)
                return .none

            case let .searchResponse(.failure(message)):
                state.searchState = .error(message: message)
                return .none
            }
        }
    }
}

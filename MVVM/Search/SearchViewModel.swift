import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var query = ""
    @Published private(set) var state: SearchViewState = .idle

    private let apiClient: APIClient
    private let searchDelay: SearchDelay
    private var searchTask: Task<Void, Never>?

    init(
        apiClient: APIClient,
        searchDelay: SearchDelay = TaskSearchDelay()
    ) {
        self.apiClient = apiClient
        self.searchDelay = searchDelay
    }

    deinit {
        searchTask?.cancel()
    }

    func searchQueryChanged(_ query: String) {
        self.query = query
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }

        state = .loading
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await searchDelay.sleep()
                guard !Task.isCancelled else { return }

                let users = try await apiClient.searchUsers(query: trimmedQuery)
                guard !Task.isCancelled else { return }

                state = users.isEmpty ? .empty : .loaded(users)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(message: error.localizedDescription)
            }
        }
    }

    func retry() {
        searchQueryChanged(query)
    }
}

import Foundation
import Observation

@MainActor
@Observable
final class DetailModel {
    private(set) var state: DetailViewState = .idle

    @ObservationIgnored private let apiClient: APIClient
    let login: String

    init(apiClient: APIClient, login: String) {
        self.apiClient = apiClient
        self.login = login
    }

    func load() async {
        state = .loading

        do {
            async let user = apiClient.fetchUser(login: login)
            async let repos = apiClient.fetchRepos(login: login)
            state = try await .loaded(user: user, repos: repos)
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }
}

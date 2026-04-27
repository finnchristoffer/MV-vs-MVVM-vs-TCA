import ComposableArchitecture

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        let login: String
        var detailState: DetailViewState = .idle
    }

    enum Action: Equatable {
        case task
        case retryTapped
        case detailResponse(DetailResponse)
    }

    enum DetailResponse: Equatable {
        case success(user: User, repos: [Repo])
        case failure(String)
    }

    @Dependency(\.apiClient) private var apiClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryTapped:
                state.detailState = .loading
                let login = state.login
                return .run { [apiClient] send in
                    async let user = apiClient.fetchUser(login)
                    async let repos = apiClient.fetchRepos(login)
                    await send(.detailResponse(.success(user: try await user, repos: try await repos)))
                } catch: { error, send in
                    await send(.detailResponse(.failure(error.localizedDescription)))
                }

            case let .detailResponse(.success(user, repos)):
                state.detailState = .loaded(user: user, repos: repos)
                return .none

            case let .detailResponse(.failure(message)):
                state.detailState = .error(message: message)
                return .none
            }
        }
    }
}

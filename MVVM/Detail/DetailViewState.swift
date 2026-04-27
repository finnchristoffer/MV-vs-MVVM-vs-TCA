enum DetailViewState: Equatable {
    case idle
    case loading
    case loaded(user: User, repos: [Repo])
    case error(message: String)
}

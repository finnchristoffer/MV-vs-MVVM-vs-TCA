enum SearchViewState: Equatable {
    case idle
    case loading
    case empty
    case loaded([User])
    case error(message: String)
}

struct SearchResult: Codable, Equatable, Sendable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [User]
}

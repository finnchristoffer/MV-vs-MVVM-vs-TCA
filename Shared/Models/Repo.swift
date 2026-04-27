import Foundation

struct Repo: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let htmlUrl: URL
    let stargazersCount: Int
    let language: String?
    let updatedAt: Date
}

import Foundation

struct User: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: Int
    let login: String
    let avatarUrl: URL
    let htmlUrl: URL
    let name: String?
    let bio: String?
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
}

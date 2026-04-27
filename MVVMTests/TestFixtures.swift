@testable import MVVMApp
import Foundation

enum TestFixtures {
    static let user = User(
        id: 1,
        login: "octocat",
        avatarUrl: url("https://avatars.githubusercontent.com/u/583231?v=4"),
        htmlUrl: url("https://github.com/octocat"),
        name: "The Octocat",
        bio: "GitHub mascot.",
        followers: 10,
        following: 2,
        publicRepos: 3
    )

    static let repo = Repo(
        id: 2,
        name: "Hello-World",
        description: "Sample repository.",
        htmlUrl: url("https://github.com/octocat/Hello-World"),
        stargazersCount: 80,
        language: "Swift",
        updatedAt: Date(timeIntervalSince1970: 0)
    )

    static func url(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Test fixture URL is invalid.")
        }

        return url
    }
}

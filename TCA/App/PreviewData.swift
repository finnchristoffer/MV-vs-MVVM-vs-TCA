import Foundation

enum PreviewData {
    static let user = User(
        id: 1,
        login: "octocat",
        avatarUrl: url("https://avatars.githubusercontent.com/u/583231?v=4"),
        htmlUrl: url("https://github.com/octocat"),
        name: "The Octocat",
        bio: "GitHub's friendly test account.",
        followers: 10_000,
        following: 9,
        publicRepos: 8
    )

    static let repo = Repo(
        id: 1,
        name: "Hello-World",
        description: "A first repository.",
        htmlUrl: url("https://github.com/octocat/Hello-World"),
        stargazersCount: 2_000,
        language: "Swift",
        updatedAt: Date(timeIntervalSince1970: 0)
    )

    private static func url(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            preconditionFailure("Preview URL is invalid.")
        }

        return url
    }
}

import Foundation

struct PreviewAPIClient: APIClient {
    func searchUsers(query: String) async throws -> [User] {
        [Self.user]
    }

    func fetchUser(login: String) async throws -> User {
        Self.user
    }

    func fetchRepos(login: String) async throws -> [Repo] {
        [Self.repo]
    }

    private static let user = User(
        id: 583231,
        login: "octocat",
        avatarUrl: previewURL("https://avatars.githubusercontent.com/u/583231?v=4"),
        htmlUrl: previewURL("https://github.com/octocat"),
        name: "The Octocat",
        bio: "GitHub mascot and sample user.",
        followers: 9_000,
        following: 9,
        publicRepos: 8
    )

    private static let repo = Repo(
        id: 1296269,
        name: "Hello-World",
        description: "My first repository on GitHub.",
        htmlUrl: previewURL("https://github.com/octocat/Hello-World"),
        stargazersCount: 80,
        language: "Swift",
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func previewURL(_ string: String) -> URL {
    guard let url = URL(string: string) else {
        preconditionFailure("Preview URL is invalid.")
    }

    return url
}

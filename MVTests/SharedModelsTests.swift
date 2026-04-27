@testable import MVApp
import XCTest

final class SharedModelsTests: XCTestCase {
    func test_searchResult_decodesGitHubPayload() throws {
        let data = Data(
            """
            {
              "total_count": 1,
              "incomplete_results": false,
              "items": [
                {
                  "id": 583231,
                  "login": "octocat",
                  "avatar_url": "https://avatars.githubusercontent.com/u/583231?v=4",
                  "html_url": "https://github.com/octocat"
                }
              ]
            }
            """.utf8
        )

        let result = try JSONDecoder.github.decode(SearchResult.self, from: data)

        XCTAssertEqual(result.totalCount, 1)
        XCTAssertFalse(result.incompleteResults)
        XCTAssertEqual(result.items.first?.login, "octocat")
        XCTAssertEqual(result.items.first?.id, 583231)
    }

    func test_repo_decodesGitHubPayload() throws {
        let data = Data(
            """
            {
              "id": 1296269,
              "name": "Hello-World",
              "description": "My first repository on GitHub!",
              "html_url": "https://github.com/octocat/Hello-World",
              "stargazers_count": 80,
              "language": "Swift",
              "updated_at": "2025-04-20T10:30:00Z"
            }
            """.utf8
        )

        let repo = try JSONDecoder.github.decode(Repo.self, from: data)
        let expectedDate = try XCTUnwrap(ISO8601DateFormatter().date(from: "2025-04-20T10:30:00Z"))

        XCTAssertEqual(repo.name, "Hello-World")
        XCTAssertEqual(repo.stargazersCount, 80)
        XCTAssertEqual(repo.updatedAt, expectedDate)
    }
}

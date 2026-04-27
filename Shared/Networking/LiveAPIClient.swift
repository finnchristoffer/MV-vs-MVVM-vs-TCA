import Foundation

struct LiveAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.github.com") else {
            preconditionFailure("GitHub API base URL is invalid.")
        }

        return url
    }

    init(
        baseURL: URL = LiveAPIClient.defaultBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func searchUsers(query: String) async throws -> [User] {
        let result: SearchResult = try await request(
            pathComponents: ["search", "users"],
            queryItems: [URLQueryItem(name: "q", value: query)]
        )
        return result.items
    }

    func fetchUser(login: String) async throws -> User {
        try await request(pathComponents: ["users", login])
    }

    func fetchRepos(login: String) async throws -> [Repo] {
        try await request(
            pathComponents: ["users", login, "repos"],
            queryItems: [
                URLQueryItem(name: "sort", value: "updated"),
                URLQueryItem(name: "per_page", value: "5")
            ]
        )
    }

    private func request<Value: Decodable>(
        pathComponents: [String],
        queryItems: [URLQueryItem] = []
    ) async throws -> Value {
        let url = try makeURL(pathComponents: pathComponents, queryItems: queryItems)

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw APIError.httpStatus(httpResponse.statusCode)
            }

            do {
                return try JSONDecoder.github.decode(Value.self, from: data)
            } catch let error as DecodingError {
                throw APIError.decoding(error)
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            throw APIError.network(error)
        } catch {
            throw error
        }
    }

    private func makeURL(pathComponents: [String], queryItems: [URLQueryItem]) throws -> URL {
        let url = pathComponents.reduce(baseURL) { partialURL, component in
            partialURL.appendingPathComponent(component)
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }

        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let finalURL = components.url else {
            throw APIError.invalidResponse
        }

        return finalURL
    }
}

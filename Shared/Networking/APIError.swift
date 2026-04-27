import Foundation

enum APIError: Error {
    case network(URLError)
    case decoding(DecodingError)
    case httpStatus(Int)
    case invalidResponse
}

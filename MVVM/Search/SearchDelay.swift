import Foundation

protocol SearchDelay: Sendable {
    func sleep() async throws
}

struct TaskSearchDelay: SearchDelay {
    private let duration: Duration

    init(duration: Duration = .milliseconds(400)) {
        self.duration = duration
    }

    func sleep() async throws {
        try await Task.sleep(for: duration)
    }
}

@testable import MVApp

actor ManualSearchDelay: SearchDelay {
    private var continuations: [CheckedContinuation<Void, Error>] = []

    var pendingCount: Int {
        continuations.count
    }

    func sleep() async throws {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func resumeAll() {
        let continuations = continuations
        self.continuations.removeAll()

        for continuation in continuations {
            continuation.resume()
        }
    }
}

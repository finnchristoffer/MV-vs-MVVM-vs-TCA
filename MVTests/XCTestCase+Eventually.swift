@testable import MVApp
import XCTest

extension XCTestCase {
    @MainActor
    func waitForSearchState(
        _ expectedState: SearchViewState,
        in model: SearchModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if model.state == expectedState {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected \(expectedState), got \(model.state)", file: file, line: line)
    }

    @MainActor
    func waitForSearchError(
        in model: SearchModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if case .error = model.state {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected error state, got \(model.state)", file: file, line: line)
    }

    @MainActor
    func waitForDetailState(
        _ expectedState: DetailViewState,
        in model: DetailModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if model.state == expectedState {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected \(expectedState), got \(model.state)", file: file, line: line)
    }
}

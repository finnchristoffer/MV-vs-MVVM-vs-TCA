@testable import MVVMApp
import XCTest

extension XCTestCase {
    @MainActor
    func waitForSearchState(
        _ expectedState: SearchViewState,
        in viewModel: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if viewModel.state == expectedState {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected \(expectedState), got \(viewModel.state)", file: file, line: line)
    }

    @MainActor
    func waitForSearchError(
        in viewModel: SearchViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if case .error = viewModel.state {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected error state, got \(viewModel.state)", file: file, line: line)
    }

    @MainActor
    func waitForDetailState(
        _ expectedState: DetailViewState,
        in viewModel: DetailViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<50 {
            if viewModel.state == expectedState {
                return
            }

            await Task.yield()
        }

        XCTFail("Expected \(expectedState), got \(viewModel.state)", file: file, line: line)
    }
}

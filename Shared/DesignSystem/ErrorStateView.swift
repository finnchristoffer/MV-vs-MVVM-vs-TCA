import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retry: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let retry {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ErrorStateView(message: "GitHub is unavailable.", retry: {})
}

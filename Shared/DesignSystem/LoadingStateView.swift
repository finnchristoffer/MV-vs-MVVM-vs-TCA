import SwiftUI

struct LoadingStateView: View {
    let title: String

    var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
            Text(title)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.large)
    }
}

#Preview {
    LoadingStateView(title: "Loading")
}

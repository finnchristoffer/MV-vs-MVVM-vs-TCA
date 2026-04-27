import SwiftUI

struct UserRow: View {
    let user: User
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: Spacing.medium) {
            AsyncImage(url: user.avatarUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))

            VStack(alignment: .leading, spacing: Spacing.small / 2) {
                Text(user.login)
                    .font(.headline)
                if let name = user.name, !name.isEmpty {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("Favorite")
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    UserRow(
        user: User(
            id: 1,
            login: "octocat",
            avatarUrl: previewURL("https://avatars.githubusercontent.com/u/583231?v=4"),
            htmlUrl: previewURL("https://github.com/octocat"),
            name: "The Octocat",
            bio: nil,
            followers: nil,
            following: nil,
            publicRepos: nil
        ),
        isFavorite: true
    )
    .padding()
}

private func previewURL(_ string: String) -> URL {
    guard let url = URL(string: string) else {
        preconditionFailure("Preview URL is invalid.")
    }

    return url
}

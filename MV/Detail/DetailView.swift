import SwiftUI

struct DetailView: View {
    @State private var model: DetailModel
    private let favoritesModel: FavoritesModel

    init(
        model: DetailModel,
        favoritesModel: FavoritesModel
    ) {
        _model = State(initialValue: model)
        self.favoritesModel = favoritesModel
    }

    var body: some View {
        content
            .navigationTitle(model.login)
            .toolbar {
                Button {
                    favoritesModel.toggle(login: model.login)
                } label: {
                    Image(systemName: favoritesModel.isFavorite(login: model.login) ? "star.fill" : "star")
                }
                .foregroundStyle(.yellow)
                .accessibilityLabel(favoritesModel.isFavorite(login: model.login) ? "Remove favorite" : "Add favorite")
            }
            .task {
                await model.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .idle, .loading:
            LoadingStateView(title: "Loading profile")
        case let .loaded(user, repos):
            List {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        UserRow(
                            user: user,
                            isFavorite: favoritesModel.isFavorite(login: user.login)
                        )

                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: Spacing.large) {
                            statistic(title: "Followers", value: user.followers)
                            statistic(title: "Following", value: user.following)
                            statistic(title: "Repos", value: user.publicRepos)
                        }
                    }
                    .padding(.vertical, Spacing.small)
                }

                Section("Top Repositories") {
                    if repos.isEmpty {
                        Text("No repositories")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(repos) { repo in
                            VStack(alignment: .leading, spacing: Spacing.small) {
                                Text(repo.name)
                                    .font(.headline)
                                if let description = repo.description, !description.isEmpty {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                HStack(spacing: Spacing.medium) {
                                    Label("\(repo.stargazersCount)", systemImage: "star")
                                    if let language = repo.language {
                                        Text(language)
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, Spacing.small)
                        }
                    }
                }
            }
        case let .error(message):
            ErrorStateView(message: message) {
                Task {
                    await model.load()
                }
            }
        }
    }

    private func statistic(title: String, value: Int?) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small / 2) {
            Text("\(value ?? 0)")
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(
            model: DetailModel(apiClient: PreviewAPIClient(), login: "octocat"),
            favoritesModel: FavoritesModel(store: PreviewFavoritesStore())
        )
    }
}

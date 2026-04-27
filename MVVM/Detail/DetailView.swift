import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @ObservedObject private var favoritesViewModel: FavoritesViewModel

    init(
        viewModel: DetailViewModel,
        favoritesViewModel: FavoritesViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesViewModel = favoritesViewModel
    }

    var body: some View {
        content
            .navigationTitle(viewModel.login)
            .toolbar {
                Button {
                    favoritesViewModel.toggle(login: viewModel.login)
                } label: {
                    Image(systemName: favoritesViewModel.isFavorite(login: viewModel.login) ? "star.fill" : "star")
                }
                .foregroundStyle(.yellow)
                .accessibilityLabel(favoritesViewModel.isFavorite(login: viewModel.login) ? "Remove favorite" : "Add favorite")
            }
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingStateView(title: "Loading profile")
        case let .loaded(user, repos):
            List {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        UserRow(
                            user: user,
                            isFavorite: favoritesViewModel.isFavorite(login: user.login)
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
                    await viewModel.load()
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
            viewModel: DetailViewModel(apiClient: PreviewAPIClient(), login: "octocat"),
            favoritesViewModel: FavoritesViewModel(store: PreviewFavoritesStore())
        )
    }
}

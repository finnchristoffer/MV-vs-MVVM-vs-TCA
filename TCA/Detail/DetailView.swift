import ComposableArchitecture
import SwiftUI

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    let favoritesStore: StoreOf<FavoritesFeature>

    var body: some View {
        content
            .navigationTitle(store.login)
            .toolbar {
                Button {
                    favoritesStore.send(.toggleFavorite(login: store.login))
                } label: {
                    Image(systemName: favoritesStore.favoriteLogins.contains(store.login) ? "star.fill" : "star")
                }
                .foregroundStyle(.yellow)
                .accessibilityLabel(favoritesStore.favoriteLogins.contains(store.login) ? "Remove favorite" : "Add favorite")
            }
            .task {
                await store.send(.task).finish()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch store.detailState {
        case .idle, .loading:
            LoadingStateView(title: "Loading profile")
        case let .loaded(user, repos):
            List {
                Section {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        UserRow(
                            user: user,
                            isFavorite: favoritesStore.favoriteLogins.contains(user.login)
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
                store.send(.retryTapped)
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
            store: Store(
                initialState: DetailFeature.State(
                    login: "octocat",
                    detailState: .loaded(user: PreviewData.user, repos: [PreviewData.repo])
                )
            ) {
                DetailFeature()
            },
            favoritesStore: Store(initialState: FavoritesFeature.State(favoriteLogins: ["octocat"])) {
                FavoritesFeature()
            }
        )
    }
}

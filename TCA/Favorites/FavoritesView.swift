import ComposableArchitecture
import SwiftUI

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>

    var body: some View {
        Group {
            if store.sortedFavoriteLogins.isEmpty {
                ContentUnavailableView("No Favorites", systemImage: "star")
            } else {
                List(store.sortedFavoriteLogins, id: \.self) { login in
                    NavigationLink(value: login) {
                        Label(login, systemImage: "person.crop.circle")
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .navigationDestination(for: String.self) { login in
            DetailView(
                store: Store(initialState: DetailFeature.State(login: login)) {
                    DetailFeature()
                },
                favoritesStore: store
            )
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(
            store: Store(initialState: FavoritesFeature.State(favoriteLogins: ["octocat"])) {
                FavoritesFeature()
            }
        )
    }
}

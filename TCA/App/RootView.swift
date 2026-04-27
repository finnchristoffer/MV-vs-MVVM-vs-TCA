import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: StoreOf<RootFeature>

    init(
        store: StoreOf<RootFeature> = Store(initialState: RootFeature.State()) {
            RootFeature()
        }
    ) {
        self.store = store
    }

    var body: some View {
        TabView {
            NavigationStack {
                SearchView(
                    store: store.scope(state: \.search, action: \.search),
                    favoritesStore: store.scope(state: \.favorites, action: \.favorites)
                )
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                FavoritesView(
                    store: store.scope(state: \.favorites, action: \.favorites)
                )
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }
        }
        .task {
            await store.send(.task).finish()
        }
    }
}

#Preview {
    RootView(
        store: Store(
            initialState: RootFeature.State(
                search: SearchFeature.State(searchState: .loaded([PreviewData.user])),
                favorites: FavoritesFeature.State(favoriteLogins: ["octocat"])
            )
        ) {
            RootFeature()
        }
    )
}

//
//  FavoritesView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteCoffee.dateAdded, order: .reverse) private var favorites: [FavoriteCoffee]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "heart.slash",
                        description: Text("Start swiping right on coffees you love!")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(favorites) { favorite in
                                AsyncFetchImageView(imageURL: favorite.imageURL)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(.rect(cornerRadius: 12))
                                    .contextMenu {
                                        Button("Remove from Favorites", systemImage: "heart.slash", role: .destructive) {
                                            modelContext.delete(favorite)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .background {
                BackgroundView()
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: FavoriteCoffee.self)
}



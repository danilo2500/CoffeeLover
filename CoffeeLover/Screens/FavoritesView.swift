//
//  FavoritesView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(animation: .default) private var favorites: [FavoriteCoffee]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        image: "happy-coffee",
                        description: Text("Start swiping right on coffees you love!")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 30) {
                            ForEach(favorites) { favorite in
                                FramedPortraitView(imageURL: favorite.imageURL)
                                    .contextMenu {
                                        Button("Remove from Favorites", systemImage: "heart.slash", role: .destructive) {
                                            modelContext.delete(favorite)
                                        }
                                    }
                                    .transition(.scale)
                                    .overlay(alignment: .topLeading){
                                        if isEditing {
                                            Button(role: .destructive) {
                                                modelContext.delete(favorite)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 33, height: 33)
                                                    .foregroundStyle(.red)
                                            }
                                            .padding(8)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                Button(isEditing ? "Confirm" : "Edit") {
                    isEditing.toggle()
                }
                .foregroundStyle(.black)
            }
            .fontDesign(.serif)
            .foregroundStyle(.white)
            .navigationTitle("Favorites")
            .background {
                BackgroundView()
            }
        }
    }
}

#Preview("With Favorites") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FavoriteCoffee.self, configurations: config)
    
    let sampleURLs = [
        "https://coffee.alexflipnote.dev/4pdGG7SkPIQ_coffee.jpg",
        "https://coffee.alexflipnote.dev/fD_8_EAZBSo_coffee.jpg",
        "https://coffee.alexflipnote.dev/random",
        "https://coffee.alexflipnote.dev/uBN3RXLY2HA_coffee.jpg"
    ]
    
    for urlString in sampleURLs {
        if let url = URL(string: urlString) {
            let favorite = FavoriteCoffee(imageURL: url)
            container.mainContext.insert(favorite)
        }
    }
    
    return FavoritesView()
        .modelContainer(container)
}


#Preview("Empty State") {
    FavoritesView()
        .modelContainer(for: FavoriteCoffee.self, inMemory: true)
}

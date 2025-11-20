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
                            ForEach(favorites, id: \.self) { favorite in
                                FramedPortraitView(imageURL: favorite.imageURL)
                                    .overlay(alignment: .topLeading) {
                                        if isEditing {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .contextMenu {
                                        Button("Remove from Favorites", systemImage: "heart.slash", role: .destructive) {
                                            modelContext.delete(favorite)
                                        }
                                    }
                                    .onTapGesture {
//                                        if isEditing {
                                            withAnimation {
                                                modelContext.delete(favorite)
                                                print(favorite.imageURL)
                                            }
//                                        }
                                    }
                                    .transition(.scale)
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
            }
            .fontDesign(.serif)
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

//
//  MainTabBar.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct MainTabBar: View {
    
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    FeedView()
                }
            }
            Tab("Favorites", systemImage: "heart") {
                FavoritesView()
            }
        }
        .tint(.white)
    }
}
#Preview {
    MainTabBar()
}

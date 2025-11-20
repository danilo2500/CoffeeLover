//
//  CoffeeLoverApp.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI
import SwiftData

@main
struct CoffeeLoverApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabBar()
        }
        .modelContainer(for: FavoriteCoffee.self)
    }
}

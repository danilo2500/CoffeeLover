//
//  FeedViewModel.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 20/11/25.
//



import Combine
import SwiftUI
import SwiftData

@Observable class FeedViewModel: ObservableObject {
    
    var coffeeImageURL: URL?
    var nextCoffeeImageURL: URL?
    var showError: Bool = false
    
    private let restService = RESTService<CoffeeAPI>()
    
    func fetchRandomCoffee() {
        Task {
            do {
                let response: CoffeeResponse = try await restService.request(.getRandom)
                coffeeImageURL = response.file
                fetchNextCoffee()
            } catch {
                showError = true
            }
        }
    }
    
    func fetchNextCoffee() {
        Task {
            do {
                let response: CoffeeResponse = try await restService.request(.getRandom)
                nextCoffeeImageURL = response.file
            } catch {
                showError = true
            }
        }
    }
    
    func handleSwipe(liked: Bool, modelContext: ModelContext) {
        if liked, let imageURL = coffeeImageURL {
            let favorite = FavoriteCoffee(imageURL: imageURL)
            modelContext.insert(favorite)
        }
        moveToNext()
    }
    
    private func moveToNext() {
        coffeeImageURL = nextCoffeeImageURL
        nextCoffeeImageURL = nil
        fetchNextCoffee()
    }
}

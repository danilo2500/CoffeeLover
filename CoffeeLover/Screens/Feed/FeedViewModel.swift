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
    
    private let coffeeService: CoffeeServiceProtocol
    
    init(coffeeService: CoffeeServiceProtocol = CoffeeService()) {
        self.coffeeService = coffeeService
    }
    
    func fetchRandomCoffee() {
        Task {
            do {
                let response = try await coffeeService.fetchRandomCoffee()
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
                let response = try await coffeeService.fetchRandomCoffee()
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

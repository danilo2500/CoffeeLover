//
//  FeedViewModelTests.swift
//  CoffeeLoverTests
//
//  Created by Danilo Henrique on 20/11/25.
//

import XCTest
import SwiftData
@testable import CoffeeLover

@MainActor
final class FeedViewModelTests: XCTestCase {
    
    var viewModel: FeedViewModel!
    var mockService: MockCoffeeService!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: FavoriteCoffee.self, configurations: config)
        modelContext = modelContainer.mainContext
        
        // Create mock service and inject it into viewModel
        mockService = MockCoffeeService()
        viewModel = FeedViewModel(coffeeService: mockService)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockService = nil
        modelContext = nil
        modelContainer = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertNil(viewModel.coffeeImageURL, "Initial coffee image URL should be nil")
        XCTAssertNil(viewModel.nextCoffeeImageURL, "Initial next coffee image URL should be nil")
        XCTAssertFalse(viewModel.showError, "Initial error state should be false")
    }
    
    // MARK: - Fetch Random Coffee Tests
    
    func testFetchRandomCoffeeSuccess() async {
        // Given: Mock service with a specific response
        let mockURL = URL(string: "https://coffee.alexflipnote.dev/mock_coffee.jpg")!
        mockService.mockResponse = CoffeeResponse(file: mockURL)
        
        XCTAssertNil(viewModel.coffeeImageURL)
        
        // When: Fetching random coffee
        viewModel.fetchRandomCoffee()
        
        // Wait for async operations to complete
        try? await Task.sleep(for: .seconds(0.1))
        
        // Then: Coffee URL should be populated with mock data
        XCTAssertEqual(viewModel.coffeeImageURL, mockURL, "Coffee image URL should be set to mock URL")
        XCTAssertNotNil(viewModel.nextCoffeeImageURL, "Next coffee image URL should also be fetched")
        XCTAssertFalse(viewModel.showError, "Error should not be shown on success")
        XCTAssertEqual(mockService.fetchCallCount, 2, "Should fetch twice: once for current, once for next")
    }
    
    func testFetchRandomCoffeeFailure() async {
        // Given: Mock service configured to fail
        mockService.shouldFail = true
        
        XCTAssertNil(viewModel.coffeeImageURL)
        XCTAssertFalse(viewModel.showError)
        
        // When: Fetching random coffee
        viewModel.fetchRandomCoffee()
        
        // Wait for async operations to complete
        try? await Task.sleep(for: .seconds(0.1))
        
        // Then: Error should be shown and URLs remain nil
        XCTAssertTrue(viewModel.showError, "Error should be shown on failure")
        XCTAssertNil(viewModel.coffeeImageURL, "Coffee image URL should remain nil on error")
        XCTAssertEqual(mockService.fetchCallCount, 1, "Should only attempt to fetch once")
    }
    
    func testFetchNextCoffeeSuccess() async {
        // Given: Mock service with response
        let mockURL = URL(string: "https://coffee.alexflipnote.dev/next_mock.jpg")!
        mockService.mockResponse = CoffeeResponse(file: mockURL)
        
        XCTAssertNil(viewModel.nextCoffeeImageURL)
        
        // When: Fetching next coffee
        viewModel.fetchNextCoffee()
        
        // Wait for async operations
        try? await Task.sleep(for: .seconds(0.1))
        
        // Then: Next coffee URL should be set
        XCTAssertEqual(viewModel.nextCoffeeImageURL, mockURL)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(mockService.fetchCallCount, 1)
    }
    
    func testFetchNextCoffeeFailure() async {
        // Given: Mock service configured to fail
        mockService.shouldFail = true
        
        // When: Fetching next coffee
        viewModel.fetchNextCoffee()
        
        // Wait for async operations
        try? await Task.sleep(for: .seconds(0.1))
        
        // Then: Error should be shown
        XCTAssertTrue(viewModel.showError)
        XCTAssertNil(viewModel.nextCoffeeImageURL)
    }
    
    // MARK: - Handle Swipe Tests
    
    func testHandleSwipeLiked() {
        // Given: A coffee image is loaded
        let testURL = URL(string: "https://coffee.alexflipnote.dev/test_coffee.jpg")!
        viewModel.coffeeImageURL = testURL
        viewModel.nextCoffeeImageURL = URL(string: "https://coffee.alexflipnote.dev/next_coffee.jpg")!
        
        // When: User swipes right (likes)
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        // Then: Coffee should be added to favorites
        let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteCoffee>())
        XCTAssertEqual(favorites?.count, 1, "One coffee should be added to favorites")
        XCTAssertEqual(favorites?.first?.imageURL, testURL, "The favorited coffee URL should match")
    }
    
    func testHandleSwipeDisliked() {
        // Given: A coffee image is loaded
        viewModel.coffeeImageURL = URL(string: "https://coffee.alexflipnote.dev/test_coffee.jpg")!
        viewModel.nextCoffeeImageURL = URL(string: "https://coffee.alexflipnote.dev/next_coffee.jpg")!
        
        // When: User swipes left (dislikes)
        viewModel.handleSwipe(liked: false, modelContext: modelContext)
        
        // Then: Coffee should NOT be added to favorites
        let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteCoffee>())
        XCTAssertEqual(favorites?.count, 0, "No coffee should be added to favorites when disliked")
    }
    
    func testHandleSwipeMovesToNext() {
        // Given: Current and next coffee images are loaded
        let currentURL = URL(string: "https://coffee.alexflipnote.dev/current_coffee.jpg")!
        let nextURL = URL(string: "https://coffee.alexflipnote.dev/next_coffee.jpg")!
        viewModel.coffeeImageURL = currentURL
        viewModel.nextCoffeeImageURL = nextURL
        
        // When: User swipes
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        // Then: Next coffee becomes current
        XCTAssertEqual(viewModel.coffeeImageURL, nextURL, "Next coffee should become current coffee")
        XCTAssertNil(viewModel.nextCoffeeImageURL, "Next coffee should be cleared initially")
    }
    
    // MARK: - Multiple Swipes Test
    
    func testMultipleFavorites() {
        // Given: Multiple coffee images
        let url1 = URL(string: "https://coffee.alexflipnote.dev/coffee1.jpg")!
        let url2 = URL(string: "https://coffee.alexflipnote.dev/coffee2.jpg")!
        let url3 = URL(string: "https://coffee.alexflipnote.dev/coffee3.jpg")!
        
        // When: User likes multiple coffees
        viewModel.coffeeImageURL = url1
        viewModel.nextCoffeeImageURL = url2
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        viewModel.coffeeImageURL = url2
        viewModel.nextCoffeeImageURL = url3
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        viewModel.coffeeImageURL = url3
        viewModel.nextCoffeeImageURL = nil
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        // Then: All three should be in favorites
        let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteCoffee>())
        XCTAssertEqual(favorites?.count, 3, "Three coffees should be in favorites")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorStateReset() {
        // Given: Error state is true
        viewModel.showError = true
        
        // When: Resetting error
        viewModel.showError = false
        
        // Then: Error should be false
        XCTAssertFalse(viewModel.showError, "Error state should be reset")
    }
    
    func testSwipeWithNilImageURL() {
        // Given: No coffee image is loaded
        viewModel.coffeeImageURL = nil
        
        // When: User tries to swipe
        viewModel.handleSwipe(liked: true, modelContext: modelContext)
        
        // Then: Nothing should be added to favorites
        let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteCoffee>())
        XCTAssertEqual(favorites?.count, 0, "No coffee should be added when URL is nil")
    }
    
    // MARK: - Mock Service Verification Tests
    
    func testServiceCallCount() async {
        // Given: Fresh mock service
        XCTAssertEqual(mockService.fetchCallCount, 0, "Initial call count should be 0")
        
        // When: Fetching random coffee (which also fetches next)
        viewModel.fetchRandomCoffee()
        try? await Task.sleep(for: .seconds(0.1))
        
        // Then: Service should be called twice
        XCTAssertEqual(mockService.fetchCallCount, 2, "Service should be called for current and next coffee")
    }
    
}


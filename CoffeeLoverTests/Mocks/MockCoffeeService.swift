//
//  MockCoffeeService.swift
//  CoffeeLoverTests
//
//  Created by Danilo Henrique on 20/11/25.
//

import Foundation
@testable import CoffeeLover

final class MockCoffeeService: CoffeeServiceProtocol {
    
    // Configuration
    var shouldFail = false
    var mockResponse: CoffeeResponse?
    var delaySeconds: TimeInterval = 0
    
    // Tracking
    var fetchCallCount = 0
    
    func fetchRandomCoffee() async throws -> CoffeeResponse {
        fetchCallCount += 1
        
        // Simulate network delay if needed
        if delaySeconds > 0 {
            try await Task.sleep(for: .seconds(delaySeconds))
        }
        
        // Simulate error
        if shouldFail {
            throw MockError.networkError
        }
        
        // Return mock response or default
        if let mockResponse = mockResponse {
            return mockResponse
        }
        
        // Default mock response
        return CoffeeResponse(
            file: URL(string: "https://coffee.alexflipnote.dev/mock_coffee.jpg")!
        )
    }
    
    // Helper to reset state between tests
    func reset() {
        shouldFail = false
        mockResponse = nil
        delaySeconds = 0
        fetchCallCount = 0
    }
}

enum MockError: Error {
    case networkError
    case decodingError
}


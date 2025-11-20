//
//  CoffeeService.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 20/11/25.
//

import Foundation

final class CoffeeService: CoffeeServiceProtocol {
    private let restService = RESTService<CoffeeAPI>()
    
    func fetchRandomCoffee() async throws -> CoffeeResponse {
        return try await restService.request(.getRandom)
    }
}




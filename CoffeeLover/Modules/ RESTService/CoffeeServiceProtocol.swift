//
//  CoffeeServiceProtocol.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 20/11/25.
//

import Foundation

protocol CoffeeServiceProtocol {
    func fetchRandomCoffee() async throws -> CoffeeResponse
}


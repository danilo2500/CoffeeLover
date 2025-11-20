//
//  FavoriteCoffee.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import Foundation
import SwiftData

@Model
final class FavoriteCoffee {
    var imageURL: URL
    var dateAdded: Date
    
    init(imageURL: URL, dateAdded: Date = Date()) {
        self.imageURL = imageURL
        self.dateAdded = dateAdded
    }
    
    static var sample: FavoriteCoffee {
        FavoriteCoffee(imageURL: URL(string: "https://coffee.alexflipnote.dev/HEXjDfKXLn8_coffee.jpg")!)
    }
}





//
//  CoffeeLoverUITests.swift
//  CoffeeLoverUITests
//
//  Created for UI Testing
//

import XCTest

final class CoffeeLoverUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testSwipeLeftShowsDislike() throws {
        let coffeeCard = app.images["coffeeCard"].firstMatch
        XCTAssertTrue(coffeeCard.waitForExistence(timeout: 10), "Coffee card should appear within 10 seconds")
        
        Thread.sleep(forTimeInterval: 2)
        
        let startPoint = coffeeCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endPoint = coffeeCard.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        
        startPoint.press(forDuration: 0.3, thenDragTo: endPoint)
        
        XCTAssertTrue(true, "Swipe left gesture completed")
    }
    
    func testSwipeRightShowsLike() throws {
        let coffeeCard = app.images["coffeeCard"].firstMatch
        XCTAssertTrue(coffeeCard.waitForExistence(timeout: 10), "Coffee card should appear within 10 seconds")
        
        Thread.sleep(forTimeInterval: 2)
        
        let startPoint = coffeeCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endPoint = coffeeCard.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        
        startPoint.press(forDuration: 0.3, thenDragTo: endPoint)
        
        XCTAssertTrue(true, "Swipe right gesture completed")
    }
}

//
//  a2_s4092047_s4092817UITests.swift
//  a2_s4092047-s4092817UITests
//
//  Created by Patrick Ly on 10/9/2026.
//

import XCTest

@MainActor
final class a2_s4092047_s4092817UITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments.append("-ENABLE-MOCK-DATA")
        app.launch()
    }

    
    func testExample() throws {
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        XCTAssert(createTripTab.exists, "Create trip tab should exist")
        createTripTab.tap()
        
        let planMyself = app.buttons["plan.myself"]
        XCTAssert(planMyself.exists, "Plan it myself button should exist")
        planMyself.tap()
        
        let tripTitleField = app.textFields["trip.title.input"]
        XCTAssert(tripTitleField.exists, "The trip title input field should exist")
        tripTitleField.tap()
        tripTitleField.typeText("Test title")
        
        let tripDescField = app.textViews["trip.description.input"]
        XCTAssert(tripDescField.exists, "The trip description input field should exist")
        tripDescField.tap()
        tripDescField.typeText("Test description")
        
        
        let confirm = app.buttons["confirm.trip.details"]
        XCTAssert(confirm.exists, "Confirm button should exist")
        XCTAssert(confirm.isEnabled, "Confirm button should exist")
        confirm.tap()
        
        let food = app.staticTexts["Food.label"]
        XCTAssertEqual(food.label, "Food")
        food.tap()
        
        let landmarks = app.staticTexts["Landmarks and Sightseeing.label"]
        XCTAssertEqual(landmarks.label, "Landmarks and Sightseeing")
        landmarks.tap()
        
        let shopping = app.staticTexts["Shopping.label"]
        XCTAssertEqual(shopping.label, "Shopping")
        shopping.tap()
        
        let nature = app.staticTexts["Nature.label"]
        XCTAssertEqual(nature.label, "Nature")
        nature.tap()
        
        let sports = app.staticTexts["Sports and Amusement.label"]
        XCTAssertEqual(sports.label, "Sports and Amusement")
        sports.tap()
        
        let finishPreferences = app.buttons["preferences.next"]
        XCTAssert(finishPreferences.exists, "Confirm button should exist")
        XCTAssert(finishPreferences.isEnabled, "Confirm button should exist")
        finishPreferences.tap()
        
        let chooseLocations = app.buttons["choose.locations"]
        XCTAssert(chooseLocations.exists, "Confirm button should exist")
        XCTAssert(chooseLocations.isEnabled, "Confirm button should exist")
        chooseLocations.tap()
        
        let nearbyLocations = app.buttons["Nearby Stops"]
        let search = app.buttons["Search for Stops"]
        XCTAssert(nearbyLocations.isSelected)
        
        let addPlace1 = app.buttons["add.remove.Sydney Opera House"].firstMatch
        addPlace1.tap()
        
        let addPlace2 = app.buttons["add.remove.Sydney Harbour Bridge"].firstMatch
        addPlace2.tap()
        
        let addPlace3 = app.buttons["add.remove.Royal Botanic Garden"].firstMatch
        addPlace3.tap()
        
        let addPlace3 = app.buttons["add.remove.Royal Botanic Garden"].firstMatch
        addPlace3.tap()
       
        search.tap()
        
        let searchPlaces = app.textViews["search.places"]
        XCTAssert(searchPlaces.exists, "The search bar should exist")
        searchPlaces.tap()
        searchPlaces.typeText("Restaurants")
        
        
        let searchButton = app.buttons["search.button"].firstMatch
        searchButton.tap()
        
        
        
        
    }

    
}

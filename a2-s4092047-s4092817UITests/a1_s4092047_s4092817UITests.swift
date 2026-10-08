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

    /// Test that creating a trip works. Involves adding a trip name, description, preferences and selecting places from the api as well as searching. Verifies it appears in the trip feed afterwards with the inputted information.
    func testCreateTripFlowSuccess() throws {
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
        
        
        
        search.tap()
        
        let searchPlaces = app.textFields["search.places"]
        XCTAssert(searchPlaces.exists, "The search bar should exist")
        searchPlaces.tap()
        searchPlaces.typeText("Restaurants")
        
        
        let searchButton = app.buttons["search.button"].firstMatch
        XCTAssert(searchButton.exists, "Search button should exist")
        searchButton.tap()
        
        
        let addPlace4 = app.buttons["add.remove.The Rocks"].firstMatch
        addPlace4.tap()
        
        
        let doneButton = app.buttons["done.button"].firstMatch
        XCTAssert(doneButton.exists, "Done button should exist")
        doneButton.tap()
        
        
        let places = app.staticTexts.allElementsBoundByIndex
        
        XCTAssert(places.contains(where: {$0.label ==  "Sydney Opera House"}))
        XCTAssert(places.contains(where: {$0.label ==  "Sydney Harbour Bridge"}))
        XCTAssert(places.contains(where: {$0.label ==  "Royal Botanic Garden"}))
        XCTAssert(places.contains(where: {$0.label ==  "The Rocks"}))
        
        
        XCTAssertTrue(places.contains { $0.label == "Bennelong Point, Sydney NSW" })
        XCTAssertTrue(places.contains { $0.label == "Sydney Harbour Bridge, Sydney NSW" })
        XCTAssertTrue(places.contains { $0.label == "Mrs Macquaries Road, Sydney NSW" })
        XCTAssertTrue(places.contains { $0.label == "The Rocks, Sydney NSW" })
        
        let finishButton = app.buttons["finish.button"].firstMatch
        XCTAssert(finishButton.exists, "Finish button should exist")
        finishButton.tap()
        
        
        
        let createdTitle = app.staticTexts["test9.title"]
        
        print(app.staticTexts.allElementsBoundByIndex)
        XCTAssertEqual(createdTitle.label, "Test title")
        
        
        let createdPrefs = app.staticTexts["test9.preferences"]
        XCTAssertEqual(createdPrefs.label, "Food, Landmarks and Sightseeing, Nature, Shopping, Sports and Amusement")
        
        
        createdTitle.tap()
        
        let description = app.staticTexts["trip.description"]
        XCTAssertEqual(description.label, "Test description")
        
        let tripPlaces = app.buttons["Places"]
        tripPlaces.tap()
        
        let chosenPlaces = app.staticTexts.allElementsBoundByIndex
        
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "Sydney Opera House"}))
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "Sydney Harbour Bridge"}))
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "Royal Botanic Garden"}))
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "The Rocks"}))
        
        
        XCTAssertTrue(chosenPlaces.contains { $0.label == "Bennelong Point, Sydney NSW" })
        XCTAssertTrue(chosenPlaces.contains { $0.label == "Sydney Harbour Bridge, Sydney NSW" })
        XCTAssertTrue(chosenPlaces.contains { $0.label == "Mrs Macquaries Road, Sydney NSW" })
        XCTAssertTrue(chosenPlaces.contains { $0.label == "The Rocks, Sydney NSW" })
        
    }
    
    /// Tests that the errors for empty description and title are present
    func testCreateTripNameDescriptionEmptySuccess() throws {
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        XCTAssert(createTripTab.exists, "Create trip tab should exist")
        createTripTab.tap()
        
        let planMyself = app.buttons["plan.myself"]
        XCTAssert(planMyself.exists, "Plan it myself button should exist")
        planMyself.tap()
        
        
        
        let confirm = app.buttons["confirm.trip.details"]
        XCTAssert(confirm.exists, "Confirm button should exist")
        XCTAssert(confirm.isEnabled, "Confirm button should exist")
        confirm.tap()
        
        let texts = app.staticTexts.allElementsBoundByIndex
        
        XCTAssert(texts.contains(where: {$0.label ==  "Please provide a title"}))
        XCTAssert(texts.contains(where: {$0.label ==  "Please provide a description"}))
        
    }
    
    

    
}

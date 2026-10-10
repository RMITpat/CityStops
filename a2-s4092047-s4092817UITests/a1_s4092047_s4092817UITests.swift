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
       

    
    func launchWithArguments(arguments: [LaunchArgument] = []) {
        app = XCUIApplication()
        // Always need this argument in ui tests
        app.launchArguments.append(LaunchArgument.ENABLE_DEBUG.rawValue)
        
        for argument in arguments {
            app.launchArguments.append(argument.rawValue)
        }
        
        app.launch()
    }
    
    
    /// Test that creating a trip works. Involves adding a trip name, description, preferences and selecting places from the api as well as searching. Verifies it appears in the trip feed afterwards with the inputted information.
    func testCreateTripFlowSuccess() throws {
        launchWithArguments()
        
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        XCTAssert(createTripTab.exists, "Create trip tab should exist")
        createTripTab.tap()
        
        try app.performAccessibilityAudit()
        
        let planMyself = app.buttons["plan.myself"]
        XCTAssert(planMyself.exists, "Plan it myself button should exist")
        planMyself.tap()
        
        try app.performAccessibilityAudit()
        
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
        
        try app.performAccessibilityAudit()
        
        let food = app.images["Food.label"]
        XCTAssertEqual(food.label, "Select preference Food")
        food.tap()
        
        let landmarks = app.images["Landmarks and Sightseeing.label"]
        XCTAssertEqual(landmarks.label, "Select preference Landmarks and Sightseeing")
        landmarks.tap()
        
        let shopping = app.images["Shopping.label"]
        XCTAssertEqual(shopping.label, "Select preference Shopping")
        shopping.tap()
        
        let nature = app.images["Nature.label"]
        XCTAssertEqual(nature.label, "Select preference Nature")
        nature.tap()
        
        let sports = app.images["Sports and Amusement.label"]
        XCTAssertEqual(sports.label, "Select preference Sports and Amusement")
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
        
        
        
        let searchPlaces = app.searchFields["search.places"]
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
        
        // use helper function to explicitly scroll through List
        let labels = collectStaticTextLabels(in: app)

        XCTAssertTrue(labels.contains("Sydney Opera House"))
        XCTAssertTrue(labels.contains("Sydney Harbour Bridge"))
        XCTAssertTrue(labels.contains("Royal Botanic Garden"))
        XCTAssertTrue(labels.contains("The Rocks"))

        XCTAssertTrue(labels.contains("Bennelong Point, Sydney NSW"))
        XCTAssertTrue(labels.contains("Sydney Harbour Bridge, Sydney NSW"))
        XCTAssertTrue(labels.contains("Mrs Macquaries Road, Sydney NSW"))
        XCTAssertTrue(labels.contains("The Rocks, Sydney NSW"))
        
        let finishButton = app.buttons["finish.button"].firstMatch
        XCTAssert(finishButton.exists, "Finish button should exist")
        finishButton.tap()
        
        
        let createdTitle = app.staticTexts["test9.title"]
        
        XCTAssertEqual(createdTitle.label, "Test title")
        
        
        let createdPrefs = app.staticTexts["test9.preferences"]
        XCTAssertEqual(createdPrefs.label, "Food, Landmarks and Sightseeing, Nature, Shopping, Sports and Amusement")
        
        
        createdTitle.tap()
        try app.performAccessibilityAudit(for: [.hitRegion]) { issue in
            print("Audit issue:", issue)

            guard let element = issue.element else {
                return false
            }

            return element.label == "Legal"
        }
        let description = app.staticTexts["trip.description"]
        XCTAssertEqual(description.label, "Test description")
        
        let tripPlaces = app.buttons["Places"]
        tripPlaces.tap()
        
        try app.performAccessibilityAudit(for: [.hitRegion]) { issue in
            print("Audit issue:", issue)

            guard let element = issue.element else {
                return false
            }

            return element.label == "Legal"
        }
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
    func testCreateTripNameDescriptionEmpty() throws {
        launchWithArguments()
        
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        createTripTab.tap()
        
        let planMyself = app.buttons["plan.myself"]
        planMyself.tap()
        
        let confirm = app.buttons["confirm.trip.details"]
        XCTAssert(confirm.isEnabled, "Confirm button should exist")
        confirm.tap()
        
        let texts = app.staticTexts.allElementsBoundByIndex
        
        XCTAssert(texts.contains(where: {$0.label ==  "Please provide a title"}))
        XCTAssert(texts.contains(where: {$0.label ==  "Please provide a description"}))
        
    }
    
    /// Tests the ui state when searching for places and asking the api for places returns empty
    func testCreatePlaceResultsEmpty() throws {
        launchWithArguments(arguments: [.ENABLE_EMPTY_DATA])
        
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        createTripTab.tap()
        
        let planMyself = app.buttons["plan.myself"]
        planMyself.tap()
        
        let tripTitleField = app.textFields["trip.title.input"]
        tripTitleField.tap()
        tripTitleField.typeText("Test title")
        
        let tripDescField = app.textViews["trip.description.input"]
        tripDescField.tap()
        tripDescField.typeText("Test description")
        
        
        let confirm = app.buttons["confirm.trip.details"]
        confirm.tap()
        
        let food = app.images["Food.label"]
        food.tap()
       
        
        let finishPreferences = app.buttons["preferences.next"]
        finishPreferences.tap()
        
        let chooseLocations = app.buttons["choose.locations"]
        chooseLocations.tap()
        
        let search = app.buttons["Search for Stops"]
        
        let emptyNearbyLocations = app.staticTexts["nearby.locations.empty"]
        XCTAssertEqual(emptyNearbyLocations.label, "No places found nearby.")
        
        search.tap()
        
        let searchPlaces = app.searchFields["search.places"]
        searchPlaces.tap()
        searchPlaces.typeText("Parks")
        
        let searchButton = app.buttons["search.button"].firstMatch
        searchButton.tap()
        
        let emptySearch = app.staticTexts["empty.search"]
        XCTAssertEqual(emptySearch.label, "No results")
        
    }
    
    /// Tests the ui state when searching for places and asking the api for places returns error
    func testCreatePlaceResultsError() throws {
        launchWithArguments(arguments: [.ENABLE_ERROR])
        
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        createTripTab.tap()
        
        let planMyself = app.buttons["plan.myself"]
        planMyself.tap()
        
        let tripTitleField = app.textFields["trip.title.input"]
        tripTitleField.tap()
        tripTitleField.typeText("Test title")
        
        let tripDescField = app.textViews["trip.description.input"]
        tripDescField.tap()
        tripDescField.typeText("Test description")
        
        
        let confirm = app.buttons["confirm.trip.details"]
        confirm.tap()
        
        let food = app.images["Food.label"]
        food.tap()
       
        
        let finishPreferences = app.buttons["preferences.next"]
        finishPreferences.tap()
        
        let chooseLocations = app.buttons["choose.locations"]
        chooseLocations.tap()
        
        let search = app.buttons["Search for Stops"]
        
        let nearbyLocationsError = app.staticTexts["nearby.locations.error"]
        XCTAssertEqual(nearbyLocationsError.label, "Couldn't load places for Food.")
        
        let retry = app.buttons["nearby.locations.retry"]
        XCTAssert(retry.exists, "Retry fetching nearby locations button exists")
        XCTAssert(retry.isEnabled, "Retry fetching nearby locations button is enabled")
        
        search.tap()
        
        let searchPlaces = app.searchFields["search.places"]
        searchPlaces.tap()
        searchPlaces.typeText("Parks")
        
        let searchButton = app.buttons["search.button"].firstMatch
        searchButton.tap()
        
        
        let searchError = app.staticTexts["search.error"]
        XCTAssertEqual(searchError.label, "Failed to search for places.")
        
        
    }
    
    /// Test that save button switches from save to saved when tapped
    func testSavingTrip() throws {
        launchWithArguments()
        
        let createdTitle = app.staticTexts["test1.title"]
        
        createdTitle.tap()
        
        
        let saveButton = app.buttons["test1.save"]
        XCTAssertEqual(saveButton.label, "Save this trip")
        saveButton.tap()
        XCTAssertEqual(saveButton.label, "Unsave this trip")
        saveButton.tap()
        XCTAssertEqual(saveButton.label, "Save this trip")

    }
    
    /// Test that when a trip is deleted, it does not appear and user is navigated
    func testDeletingTrip() throws {
        launchWithArguments()
        
        // Assert that the trip is on the page
        let existingTrips = app.staticTexts.allElementsBoundByIndex
        XCTAssert(existingTrips.contains(where: {$0.label ==  "Sydney Food Trail"}))
   
        let createdTitle = app.staticTexts["test1.title"]
        createdTitle.tap()
        
        
        let deleteButton = app.buttons["test1.delete"]
        XCTAssertEqual(deleteButton.label, "Delete this trip")
        deleteButton.tap()
        
        // Wait for trips to load again due to 1 second constant load
        let trip2Title = app.staticTexts["test2.title"]
        XCTAssert(trip2Title.waitForExistence(timeout: 2))
        
        // Assert that the trip is no longer on the page
        let updatedTrips = app.staticTexts.allElementsBoundByIndex
        XCTAssertFalse(updatedTrips.contains(where: {$0.label ==  "Sydney Food Trail"}))

    }
    
    
    
    func testCreateAITripFlowSuccess() throws {
        launchWithArguments()
        
        let createTripTab = app.tabBars.buttons["Trip creation tab"]
        createTripTab.tap()
        
        let askAI = app.buttons["ask.ai"]
        XCTAssert(askAI.exists, "Ask Dora button should exist")
        askAI.tap()
        
       
        
   
        let landmarks = app.images["Landmarks and Sightseeing.label"]
        landmarks.tap()
     
        
        let finishPreferences = app.buttons["preferences.next"]
        XCTAssert(finishPreferences.exists, "Confirm button should exist")
        XCTAssert(finishPreferences.isEnabled, "Confirm button should exist")
        finishPreferences.tap()
        
        let doraHi = app.staticTexts["dora.hi"]
        XCTAssert(doraHi.exists)
        
        let doraQuestion = app.staticTexts["dora.question"]
        XCTAssert(doraQuestion.exists)
        
        let doraInput = app.textFields["dora.input"]
        XCTAssert(doraInput.exists, "The ai input field should exist")
        doraInput.tap()
        doraInput.typeText("Make me a test trip")
        
        
        let createAiButton = app.buttons["create.ai.trip"]
        XCTAssert(createAiButton.exists, "The button to create the ai trip exists")
        createAiButton.tap()
        
        let details = app.buttons["Details"]
        XCTAssert(details.isSelected)
        
        let places = app.buttons["Places"]

        
        let aiTitle = app.textFields["ai.title"]
        XCTAssert(aiTitle.exists, "The ai title text field should exist")
        aiTitle.tap()
       
        aiTitle.typeText("Changed title")
        
        
        let tripDescField = app.textViews["ai.description"]
        XCTAssert(tripDescField.exists, "The ai trip description input field should exist")
        tripDescField.tap()
        
        tripDescField.typeText("Changed description")
        
        places.tap()
        
        let addButton = app.buttons["add.spots"]
        XCTAssert(addButton.exists, "Add more spots with AI button should exist")
        
        let replaceButton = app.buttons["replace.spots"]
        XCTAssert(replaceButton.exists, "Replace spots with AI button should exist")
        XCTAssertFalse(replaceButton.isEnabled, "Replace spots with AI button should be disabled if no places are selected")
        
        let placeCheck = app.buttons["mock-mca-australia.check"]
        XCTAssertEqual(placeCheck.label, "Select this place to be regenerated by AI")
        placeCheck.tap()
        XCTAssertEqual(placeCheck.label, "Deselect this place to be regenerated by AI")

        XCTAssertTrue(replaceButton.isEnabled, "Replace spots with AI button should be disabled if no places are selected")
        
        addButton.tap()
        replaceButton.tap()
        
        //Navigate back to dora input
        let startAgain = app.buttons["start.again"].firstMatch
        XCTAssert(startAgain.exists, "Start again button should exist")
        startAgain.tap()
        
        landmarks.tap()
        finishPreferences.tap()

        XCTAssert(doraHi.exists)
        XCTAssert(doraQuestion.exists)
        
        //Navigate back to ai trip
        createAiButton.tap()

        let finishButton = app.buttons["finish.button"].firstMatch
        XCTAssert(finishButton.exists, "Finish button should exist")
        finishButton.tap()
        
        
        let createdTitle = app.staticTexts["test9.title"]
        
        XCTAssertEqual(createdTitle.label, "Test trip")
        
        
        let createdPrefs = app.staticTexts["test9.preferences"]
        XCTAssertEqual(createdPrefs.label, "Landmarks and Sightseeing")
        
        
        createdTitle.tap()
        
        let description = app.staticTexts["trip.description"]
        XCTAssertEqual(description.label, "Test description")
        
        let tripPlaces = app.buttons["Places"]
        tripPlaces.tap()
        
        let chosenPlaces = app.staticTexts.allElementsBoundByIndex
        
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "Museum of Contemporary Art Australia"}))
        XCTAssert(chosenPlaces.contains(where: {$0.label ==  "The Rocks"}))

        
        XCTAssertTrue(chosenPlaces.contains { $0.label == "George Street, Sydney NSW" })
        XCTAssertTrue(chosenPlaces.contains { $0.label == "The Rocks, Sydney NSW" })
        
        
    }
    
    // helper function to collect labels of all elements in a Lazy List.
    func collectStaticTextLabels(in app: XCUIApplication, maxSwipes: Int = 8) -> Set<String> {
        let list = app.collectionViews.firstMatch
        var labels = Set<String>()
        var previousCount = -1

        for _ in 0..<maxSwipes {
            labels.formUnion(app.staticTexts.allElementsBoundByIndex.map(\.label))

            // Stop once a swipe reveals nothing new
            if labels.count == previousCount { break }
            previousCount = labels.count

            list.swipeUp()
        }
        return labels
    }
}

## Welcome to CityStops!

CityStops is an iOS app that allows users to create, plan and share day-trip itineraries in their local city.

## Features

With CityStops, users can:

- **Create a day-trip route** by choosing locations on a map
- **Publish routes** for other users to discover
- **View other users’ routes** through a feed
- **Save routes** for later
- **Receive personalised trip suggestions** using machine learning
- **Create routes with Dora**, our AI-powered trip-planning agent

## Learning Outcomes

CityStops was developed as a practical project for learning Swift, SwiftUI and iOS development. The project provided experience designing a complete application while working with several Apple frameworks, third-party services and modern software development techniques.

Through developing CityStops, we explored:

- Building user interfaces with **SwiftUI**
- Integrating UIKit components where additional control or functionality was required
- Implementing complex gestures and gesture-driven interactions
- Displaying and interacting with locations using **MapKit**
- Working with asynchronous functions and modern Swift concurrency
- Making REST API calls to retrieve and process external data
- Managing application data with **SwiftData**
- Implementing authentication with **Firebase Authentication**
- Storing and synchronising application data using **Firebase Firestore**
- Using **Firebase AI Logic** and Gemini to power AI functionality
- Designing accessible interfaces with SwiftUI accessibility modifiers
- Writing unit tests and UI tests to verify application behaviour

## Artificial Intelligence

CityStops includes an AI trip-planning feature called **Dora**. Dora uses Gemini through Firebase AI Logic to help users create and edit trip itineraries using natural-language instructions.

For example, users can describe the type of trip they want, and Dora can help generate a route based on their request. The feature also supports editing and refining trips through conversational interactions.

## Machine Learning Trip Suggestions

CityStops uses the `all-MiniLM-L6-v2` machine learning model to compare trip titles based on **semantic similarity**. Rather than only comparing exact words, the model represents text as numerical embeddings and measures how similar the meanings of two titles are.

This allows the app to suggest trips with titles that are semantically similar to trips the user has already saved. For example, a user who saves a trip titled *“Best coffee shops in Melbourne”* may receive suggestions such as *“Melbourne cafés worth visiting”*, even though the titles do not contain exactly the same words.

## Technologies Used

- Swift
- SwiftUI
- UIKit
- MapKit
- SwiftData
- Firebase Authentication
- Firebase Firestore
- Firebase AI Logic
- Gemini
- REST APIs
- `all-MiniLM-L6-v2`
- XCTest unit testing
- XCUITest UI testing

## Testing and Accessibility

Accessibility was considered throughout the development process using SwiftUI accessibility modifiers, including descriptive labels and accessibility hints for interactive elements.

The project also includes:

- **Unit tests** for testing individual pieces of application logic
- **UI tests** for testing important user flows and interactions
- Gesture and navigation testing across key screens

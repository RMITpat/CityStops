//
//  GeminiService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import FirebaseAILogic
import MapKit

@MainActor
protocol GeminiService {
    func request() async throws
}

@MainActor
final class GeminiServiceImpl : GeminiService {
    
    let ai: FirebaseAI
    let model: GenerativeModel
    let currentRegion: MKCoordinateRegion
    
    /// The selectedPlaces for the trip this
    var selectedPlaces: [MKMapItem] = []
    
    /// A cache of searched places so that when the model chooses a spot, we can use the identifier to retrieve its MKMapItem immediately without needing another search
    var searchedPlaces: [String : MKMapItem] = [:]
    
    
    init(region: MKCoordinateRegion) {
        ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Change from 3.5-3.8 depending on traffic
        model = ai.generativeModel(
            modelName: "gemini-3.5-flash",
            tools: [.functionDeclarations([searchPlaces])]
        )
        currentRegion = region

    }
    
    let searchPlaces = FunctionDeclaration(
      name: "search_places",
      description: """
        Search for and retrieve existing places that a user can visit, localised to the user's location. This can be used to check if a certain place exists nearby the user. 
        If any places exist, it will return a list of places consisting of a unique identifier, the name of the place and its location category, such as restaurant or museum. If you
        would like to add one of these places to the trip, remember its unique identifier. 
        """,
      parameters: [
        "search_query": .string(
          description: """
          Your natural language search query for a type of place. e.g. Burger restaurant
          """
        ),
      ]
    )
    
    let selectPlaces = FunctionDeclaration(
      name: "select_places",
      description: """
        Add one or more existing places to the overall trip. These places should fit in with the overall goal or theme of the trip.
        """,
      parameters: [
        "place_identifiers": .array(items: .string(
              description: """
              A unique place identifier you retrieved from searching for this place. 
              """
          )
        ),
      ]
    )
    
    
    
    
    func request() async throws {

        // Provide a prompt that contains text
        let prompt = "Write a story about a magic backpack."

        // To generate text output, call generateContent with the text input
        let response = try await model.generateContent(prompt)
        print(response.text ?? "No text in response.")
        
        
        var functionResponses = [FunctionResponsePart]()
        
        
    }
    
    
    func searchPlaces(searchRequest: String) async throws -> JSONObject {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        let mapItems = response.mapItems.filter { $0.identifier != nil }
        
        return [
            "places" : .array(mapItems.map { .object($0.toJSONObject()) })
        ]
    }
    
    func selectPlaces(identifiers: [String]) {
        for identifier in identifiers {
            if let selectedPlace = searchedPlaces[identifier] {
                selectedPlaces.append(selectedPlace)
            }
        }
        
    }
    
    
    
}

extension MKMapItem {
    func toJSONObject() -> JSONObject {
        return [
            // identifier should exist, was checked in searchPlaces
            "identifier" : .string(self.identifier?.rawValue ?? ""),
            "name" : .string(self.name ?? "No name"),
            "category" : .string(self.pointOfInterestCategory?.rawValue ?? "No category")
        ]
    }
}

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
        If any places exist, it will return a list of places consisting of a unique identifier, the name of the place and its location type, such as restaurant or museum. If you
        would like to add this place to the trip, return its unique identifier. 
        """,
      parameters: [
        "search_query": .string(
          description: """
          Your natural language search query for a type of place. e.g. Burger restaurant
          """
        ),
      ]
    )
    
    let selectPlace = FunctionDeclaration(
      name: "select_place",
      description: """
        Add an existing place to the overall trip. This place should fit in with the overall goal or theme of the trip.
        """,
      parameters: [
        "place_identifier": .string(
          description: """
          The unique place identifier you retrieved from searching for this place. 
          """
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
    
    
    func searchPlaces(searchRequest: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        return response.mapItems.filter {
            $0.identifier != nil
        }
    }
    
}

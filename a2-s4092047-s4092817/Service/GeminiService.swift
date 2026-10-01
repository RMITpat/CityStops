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
    func request() async throws -> [MKMapItem]
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
            tools: [.functionDeclarations([searchPlaces, selectPlaces])]
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
    
    
    func request() async throws -> [MKMapItem] {

        // Provide a prompt that contains text
        let prompt = """
        You are an expert at creating trips for users. 
        
        Trips involve travelling on a route that consists of multiple stops at different locations, depending
        on the overall goal of the trip. For example, a trip with the aim of trying out burger restaurants could contain stops at McDonald's, Grill'd, Betsy's Burgers
        and Hungry Jacks. 
        
        The order and quantity of the stops matter and you should come up with a logical reasoning behind the order. For example, it might not make sense for users to eat
        dinner at multiple restaurants in one night, unless the trip involves experiencing multiple food locations. The order of the stops is the order in which you add them using 
        the select place tool. 
        
        The trip should balance between each of the goals of the trip to ensure an enjoyable experience for the user. For example, a trip centered around visiting museums and 
        shopping should not be heavily about shopping only.
        
        You can use tools to search for these places. Results from the search tool will always be local to the user's region. If a search fails, try modifying the query slightly. ONLY add a place
        to a trip if it came from the search tool. Try and make multiple search requests in one response instead of in individual responses.
        
        When you have searched for a place and believe it is a good fit for the trip, use the select place tool to add it to the trip. Each of these places needs to be added individually.
        
        When you have finished adding places, provide a short summary of the overall tour and its stops.
        
        The following is your trip creation task.
        Create a trip that lets me explore galleries around me.
        """
//    Create a trip that lets me explore some thrift shops and eat at some asian dessert shops. I'd also like to grab coffee before I start thrifting for some energy.
        let chat = model.startChat()

        // To generate text output, call generateContent with the text input
        var response = try await chat.sendMessage(prompt)
        
        var iterations = 20
        print(response.text ?? "no text response")
        print(response.thoughtSummary ?? "no thought summary")

        while (!response.functionCalls.isEmpty && iterations > 0) {
            print(response.text ?? "no text response")
            print(response.thoughtSummary ?? "no thought summary")

            let functionResponses = await useTools(response: response)
            
            response = try await chat.sendMessage(
                [ModelContent(role: "user", parts: functionResponses)]
            )
            iterations -= 1
        }
        
        if (iterations <= 0) {
            print("max iterations reached")
        }
        
        print(response.text ?? "no text response")
        
        return selectedPlaces
        
    }
    
    
    func useTools(response: GenerateContentResponse) async -> [FunctionResponsePart] {
        
        var functionResponses = [FunctionResponsePart]()
        
        print(response.functionCalls.count)
        for functionCall in response.functionCalls {
            
            if functionCall.name == "search_places" {
                print("searching places")
                guard case let .string(searchQuery) = functionCall.args["search_query"] else {
                    print("failed convert search_query to string")
                    fatalError()
                  
                }
                
                do {
                    print("searching for: \(searchQuery)")
                    
                    try await Task.sleep(for: .seconds(3))
                    let places = try await searchPlaces(searchRequest: searchQuery)
                    
                    functionResponses.append(FunctionResponsePart(
                        name: functionCall.name,
                        response: places
                    ))
                    
                } catch {
                    let fail: JSONObject = [
                        "places" : .array([]),
                        "search_success" : .bool(true)
                    ]
                    
                    functionResponses.append(FunctionResponsePart(
                        name: functionCall.name,
                        response: fail
                        ))
                                             
                }
                    
            } else if (functionCall.name == "select_places") {
                print("Selecting a place")
                guard case let .array(placeIdentifiers) = functionCall.args["place_identifiers"] else {
                    print("failed convert placeids to array")
                    fatalError()
                    
}
                
                for identifier in placeIdentifiers {
                    guard case let .string(stringId) = identifier else {
                        print("failed convert id to string")
                        fatalError()
                        
}
                    selectPlace(identifier: stringId)
                }
                functionResponses.append(FunctionResponsePart(
                    name: functionCall.name,
                    response: [ "success" : .bool(true)]
                ))
            }
        }
            
        return functionResponses
        
        
    }
    
    
    func searchPlaces(searchRequest: String) async throws -> JSONObject {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        let mapItems = response.mapItems.filter { $0.identifier != nil }
        
        
        var placesResult: [JSONValue] = []
        
        for item in mapItems {
            if let id = item.identifier {
                searchedPlaces[id.rawValue] = item
                placesResult.append(.object(item.toJSONObject()))
            }
            print(item.name ?? "no name")
            
        }
        
        return [
            "places" : .array(placesResult),
            "search_success" : .bool(true)
        ]
    }
    
    func selectPlace(identifier: String) {
        if let selectedPlace = searchedPlaces[identifier] {
            print(selectedPlace.name)
            selectedPlaces.append(selectedPlace)
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

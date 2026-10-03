//
//  GeminiService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import FirebaseAILogic
import MapKit

struct AITripDetails: Codable {
    let trip_name: String
    let description: String
}

@MainActor
protocol GeminiService {
    func request(tripRequest: String) async throws -> ([MKMapItem], String, String)
    func editTrip(identifiers: [String]) async throws -> ([MKMapItem], String, String)
    func generateTrip(prompt: String) async throws -> ([MKMapItem], String, String)
    
    func decodeTrip(responseText: String?) throws -> ([MKMapItem], String, String)
    
    func searchPlaces(searchRequest: String) async throws -> JSONObject
    func useTools(response: GenerateContentResponse) async -> [FunctionResponsePart]
    func multiTurn(firstResponse: GenerateContentResponse) async throws -> GenerateContentResponse
    func selectPlace(identifier: String)
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
    
    var currentChat: Chat
    
    init(region: MKCoordinateRegion) {
        ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Change from 3.5-3.8 depending on traffic
        model = ai.generativeModel(
            modelName: "gemini-3.6-flash",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: tripJSONSchema
            ),
            tools: [.functionDeclarations([searchPlaces, selectPlaces])],
        )
        currentRegion = region
        
        currentChat = model.startChat()
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
    
    
    let tripJSONSchema = Schema.object(
      properties: [
        "trip_name" : .string(),
        "description" : .string(),
      ]
    )
    func request(tripRequest: String) async throws -> ([MKMapItem], String, String) {

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
        
        You can use tools to search for these places. Results from the search_places tool will always be local to the user's region. If a search fails, try modifying the query slightly. ONLY add a place
        to a trip if it came from the search tool. Try and make multiple search requests in one response instead of in individual responses.
        
        When you have finished searching for places and have accumulated a list of stops for the trip, use the select_places tool to add all of them to the trip.
        
        After selecting your places, generate a name and description for the trip using the json schema. The description should be short and brief, outlining some of the places chosen. 
        A maximum of around 60 words. 

        
        The following is your trip creation task.
        \(tripRequest)
        """

        currentChat = model.startChat()
            
        return try await generateTrip(prompt: prompt)
        
    }
    
    func editTrip(identifiers: [String]) async throws -> ([MKMapItem], String, String) {
        selectedPlaces.removeAll()
        
        var prompt = """
            The user has reviewed your selected places and would like to remove some places. 
            Please find suitable replacements for them from your searched places or through searching for more places. Then, recreate the entire trip using the select_places tool, 
            keeping in places that were not removed. Then submit the trip again using the json schema.
            The following identifiers should be replaced:
            
            """
        for id in identifiers {
            prompt.append(id + " ")
        }
        
        return try await generateTrip(prompt: prompt)

        
    }
    
    func generateTrip(prompt: String) async throws -> ([MKMapItem], String, String) {
        let firstResponse = try await currentChat.sendMessage(prompt)
    
        let finalResponse = try await multiTurn(firstResponse: firstResponse)
        print(finalResponse.text ?? "no text response")

        return try decodeTrip(responseText: finalResponse.text)
        
        
    }
    
    func multiTurn(firstResponse: GenerateContentResponse) async throws -> GenerateContentResponse {
        var response = firstResponse
        
        var iterations = 20

        while (!response.functionCalls.isEmpty && iterations > 0) {
            let functionResponses = await useTools(response: response)
            
            response = try await currentChat.sendMessage(
                [ModelContent(role: "user", parts: functionResponses)]
            )
            iterations -= 1
        }
        
        return response
        
    }
    
    func decodeTrip(responseText: String?) throws -> ([MKMapItem], String, String) {
        let emptyTrip = (selectedPlaces, "Generated Trip", "This trip was generated by Dora")
        
        guard let text = responseText else {
            return emptyTrip
        }
        
        guard let tripDetails = text.data(using: .utf8) else {
            return emptyTrip
        }
        
        let data = try JSONDecoder().decode(AITripDetails.self, from: tripDetails)
        
        return (selectedPlaces, data.trip_name, data.description)
    }
    
    
    func useTools(response: GenerateContentResponse) async -> [FunctionResponsePart] {
        
        var functionResponses = [FunctionResponsePart]()
        
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
                        "search_success" : .bool(false)
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

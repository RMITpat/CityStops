//
//  GeminiService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import FirebaseAILogic
import MapKit

/// The struct to decode the model's JSON response to
struct AITripDetails: Codable {
    let trip_name: String
    let description: String
}

/// The AI Trip created
struct AIResult {
    let tripName: String
    let description: String
    let selectedPlaces: [MapItem]
}

/// What model is currently being used. Switch when rate limited
enum GeminiModel: String, CaseIterable, Identifiable {
    var id: Self {self}
    
    case flash5 = "gemini-3.5-flash"
    case flash6 = "gemini-3.6-flash"
    case flash7 = "gemini-3.7-flash"
    case flash8 = "gemini-3.8-flash"
    
}

/// The GeminiService responsible for making requests to the model, conducting multi turn conversations and providing tools for function calling
@MainActor
protocol GeminiService {
    var modelName: GeminiModel { get }

    func request(tripRequest: String, preferences: [String]) async throws -> AIResult
    func editTrip(identifiers: [String], selectedPlaces: [MapItem]) async throws -> AIResult
    func addStops(selectedPlaces: [MapItem]) async throws -> AIResult
    
    
    func setModel(newModel: GeminiModel)
}



@MainActor
final class GeminiServiceImpl : GeminiService {
    /// Firebase backend
    let ai: FirebaseAI
    
    /// The model we chat to
    var model: GenerativeModel
    
    /// The name of the model we are currently using
    var modelName: GeminiModel = .flash6
    
    /// The current region, used for searching places with MapKit
    let currentRegion: MKCoordinateRegion
    
    /// The selectedPlaces for the trip which the model has chosen
    var selectedPlaces: [MapItem] = []
    
    /// A cache of searched places so that when the model chooses a spot, we can use the identifier to retrieve its MapItem immediately without needing another search
    var searchedPlaces: [String : MKMapItem] = [:]
    
    /// The current chat. Used to obtain past chat history when changing models
    var currentChat: Chat
    
    init(region: MKCoordinateRegion) {
        ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Change from 3.5-3.8 depending on traffic
        model = ai.generativeModel(
            modelName: modelName.rawValue,
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: tripJSONSchema
            ),
            tools: [.functionDeclarations([searchPlaces, selectPlaces])],
        )
        currentRegion = region
        
        currentChat = model.startChat()
    }
    
    /// The search places tool that allows the model to search for places local to the user. Provides the model with the name, location category and unique identifier of each place
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
    
    /// The select places tool that allows the model to add places to the trip using the identifiers of a place
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
    
    /// The format by which the model returns the created trip's name and description
    let tripJSONSchema = Schema.object(
      properties: [
        "trip_name" : .string(),
        "description" : .string(),
      ]
    )
    
    /// The initial request for a trip. We provide the model with the user's inputted prompt and their selected preferences
    func request(tripRequest: String, preferences: [String]) async throws -> AIResult {

        // Tell the model to create a trip based off the prompt and explains to it the tools available.
        var prompt = """
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
        
        When you have finished searching for places and have accumulated a list of stops for the trip, use the select_places tool to add all of them to the trip using each place's identifier.
        
        After selecting your places, generate a name and description for the trip using the json schema. The description should be short and brief, outlining some of the places chosen. 
        A maximum of around 60 words. 

        
        The following is your trip creation task.
        \(tripRequest)
        
        If the user has selected any categories/themes for their trip, they are the following:
        """
        
        for preference in preferences {
            prompt.append(preference + ", ")
        }

        currentChat = model.startChat()
            
        return try await generateTrip(prompt: prompt)
        
    }
    
    /// Changes the current model and provides the new model with the old chat history so it has context about the created trip
    func setModel(newModel: GeminiModel) {
        let oldHistory = currentChat.history
        
        model = ai.generativeModel(
            modelName: newModel.rawValue,
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: tripJSONSchema
            ),
            tools: [.functionDeclarations([searchPlaces, selectPlaces])],
        )
        currentChat = model.startChat(history: oldHistory)
        
        modelName = newModel
    }
    
    /// A request that asks the model to edit the existing trip by replacing specific places.
    func editTrip(identifiers: [String], selectedPlaces: [MapItem]) async throws -> AIResult {
        self.selectedPlaces.removeAll()
        
        var prompt = """
            The user has reviewed your selected places and would like to remove some places. 
            Please find suitable replacements for them from your searched places or through searching for more places. Then, recreate the entire trip using the select_places tool, 
            keeping in places that were not removed. Then submit the trip again using the json schema.
            
            The user may have also reordered the locations in your trip. When the trip is recreated, maintain this order and insert new stops at the correct positions. 
            The current order is as follows: 
            
            """
        
        for place in selectedPlaces {
            prompt.append("\(place.identifier), ")
        }
       
        prompt.append("The following identifiers should be replaced: ")
        
        for id in identifiers {
            prompt.append(id + " ")
        }
        
        
        return try await generateTrip(prompt: prompt)

        
    }
    
    /// A request that asks the model to add additional stops to the trip
    func addStops(selectedPlaces: [MapItem]) async throws -> AIResult {
        self.selectedPlaces.removeAll()
        var prompt = """
            The user has reviewed your selected places and would like to add some more places.
            Please find 3 more locations from your searched places or through searching for more places. Then, add them anywhere to the existing trip.
            Recreate the entire trip using the select_places tool and submit the trip again using the json schema.   
            
            The user may have also reordered the locations in your trip. When the trip is recreated, maintain this order and add your new stops to the end. The current order is as follows:
            
            """
        for place in selectedPlaces {
            prompt.append("\(place.identifier), ")
        }
        return try await generateTrip(prompt: prompt)

    }
    
    /// Conduct the generation of the trip through conversing with the model
    func generateTrip(prompt: String) async throws -> AIResult {
        let firstResponse = try await currentChat.sendMessage(prompt)
    
        let finalResponse = try await multiTurn(firstResponse: firstResponse)
        print(finalResponse.text ?? "no text response")

        return try decodeTrip(responseText: finalResponse.text)
        
        
    }
    
    /// Manages the multi turn conversation with the model
    func multiTurn(firstResponse: GenerateContentResponse) async throws -> GenerateContentResponse {
        var response = firstResponse
        
        var iterations = 20
        // While the model still wants to make function calls, provide it function responses
        while (!response.functionCalls.isEmpty && iterations > 0) {
            let functionResponses = await useTools(response: response)
            
            response = try await currentChat.sendMessage(
                [ModelContent(role: "user", parts: functionResponses)]
            )
            iterations -= 1
        }
        
        // When no more function calls, return the final response which should be the created trip's name and description
        return response
        
    }
    
    /// Decodes the json schema provided by the model which contains the created trip's name and description
    func decodeTrip(responseText: String?) throws -> AIResult {
        // If fail to decode, return this default name and description
        let emptyTrip = AIResult(tripName: "Generated Trip", description: "This trip was generated by Dora", selectedPlaces: selectedPlaces)
        
        guard let text = responseText else {
            return emptyTrip
        }
        
        guard let tripDetails = text.data(using: .utf8) else {
            return emptyTrip
        }
        
        let data = try JSONDecoder().decode(AITripDetails.self, from: tripDetails)
        
        return AIResult(tripName: data.trip_name, description: data.description, selectedPlaces: selectedPlaces)
    }
    
    /// Provide the model with function responses based on its function call
    func useTools(response: GenerateContentResponse) async -> [FunctionResponsePart] {
        
        var functionResponses = [FunctionResponsePart]()
        
        for functionCall in response.functionCalls {
            
            // If the model wants to search for places
            if functionCall.name == "search_places" {
                print("searching places")
                
                // Extract the search query
                guard case let .string(searchQuery) = functionCall.args["search_query"] else {
                    print("failed convert search_query to string")
                    fatalError()
                  
                }
                
                do {
                    print("searching for: \(searchQuery)")
                    
                    // Set a three second limit between each query to prevent throttling
                    try await Task.sleep(for: .seconds(3))
                    
                    // Conduct search
                    let places = try await searchPlaces(searchRequest: searchQuery)
                    
                    // Return the search results
                    functionResponses.append(FunctionResponsePart(
                        name: functionCall.name,
                        response: places
                    ))
                    
                } catch {
                    // If the search fails, return an empty array and let the model know that the search failed
                    let fail: JSONObject = [
                        "places" : .array([]),
                        "search_success" : .bool(false)
                    ]
                    
                    functionResponses.append(FunctionResponsePart(
                        name: functionCall.name,
                        response: fail
                        ))
                                             
                }
            // If the model wants to choose a place for the trip
            } else if (functionCall.name == "select_places") {
                print("Selecting a place")
                
                // Extract the MKMapItem identifiers
                guard case let .array(placeIdentifiers) = functionCall.args["place_identifiers"] else {
                    print("failed convert placeids to array")
                    fatalError()
                    
                }
                
                for identifier in placeIdentifiers {
                    guard case let .string(stringId) = identifier else {
                        print("failed convert id to string")
                        fatalError()
                        
                    }
                    
                    // add the place to the trip's selected places
                    selectPlace(identifier: stringId)
                }
                
                // Let the model know it succeeded
                functionResponses.append(FunctionResponsePart(
                    name: functionCall.name,
                    response: [ "success" : .bool(true)]
                ))
            }
        }
            
        return functionResponses
        
        
    }
    
    /// Conduct a MapKit search for a place and return the results as a JSONObject
    func searchPlaces(searchRequest: String) async throws -> JSONObject {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        let mapItems = response.mapItems.filter { $0.identifier != nil }
        
        
        var placesResult: [JSONValue] = []
        
        for item in mapItems {
            if let id = item.identifier {
                // Store the search result for retrieval in the future
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
    
    /// Select a place for the trip by retrieving it from the previously searched places dictionary and adding it to selectedPlaces
    func selectPlace(identifier: String) {
        if let selectedPlace = searchedPlaces[identifier] {
            print(selectedPlace.name ?? "no name")
            
            let mapItem = MapItem(identifier: identifier, mkMapItem: selectedPlace)
            selectedPlaces.append(mapItem)
        }
        
    }
    
    
    
}

/// Turn a MKMapItem to a json object
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

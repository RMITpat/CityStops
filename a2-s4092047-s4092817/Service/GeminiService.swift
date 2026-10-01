//
//  GeminiService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import FirebaseAILogic

@MainActor
protocol GeminiService {
    func request() async throws
}

@MainActor
final class GeminiServiceImpl : GeminiService {
    
    let ai: FirebaseAI
    let model: GenerativeModel
    
    let searchPlaces = FunctionDeclaration(
      name: "searchPlaces",
      description: "Search for existing places that a user can visit, localised to the user's location. This can be used to check if a certain place exists nearby the user.",
      parameters: [
        "search query": .string(
          description: """
          A natural language search query for a type of place. e.g. Burger restaurant
          """
        ),
      ]
    )
    
    
    init() {
        ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        // Change from 3.5-3.8 depending on traffic
        model = ai.generativeModel(
            modelName: "gemini-3.5-flash",
            tools: [.functionDeclarations([searchPlaces])]
        )
    }
    
    func request() async throws {

        // Provide a prompt that contains text
        let prompt = "Write a story about a magic backpack."

        // To generate text output, call generateContent with the text input
        let response = try await model.generateContent(prompt)
        print(response.text ?? "No text in response.")
    }
    
}

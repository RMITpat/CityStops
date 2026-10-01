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
    
}

@MainActor
final class GeminiServiceImpl : GeminiService {
    func request() async throws {
        
        // Initialize the Gemini Developer API backend service
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())

        // Create a `GenerativeModel` instance with a model that supports your use case
        let model = ai.generativeModel(modelName: "gemini-3.5-flash")

        // Provide a prompt that contains text
        let prompt = "Write a story about a magic backpack."

        // To generate text output, call generateContent with the text input
        let response = try await model.generateContent(prompt)
        print(response.text ?? "No text in response.")
    }
    
}

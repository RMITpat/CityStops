//
//  AITripCreationView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI

struct AITripCreationView: View {
    @State private var gemini: GeminiViewModel = GeminiViewModel()

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        Button("ai button") {
            gemini.request()
        }
    }
}

#Preview {
    AITripCreationView()
}

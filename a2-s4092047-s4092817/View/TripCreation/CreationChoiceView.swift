//
//  CreationChoiceView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 21/9/2026.
//

import SwiftUI

/// View that allows user to choose between manually creating a ``Trip``, or
/// use ML features to plan a ``Trip``for them.
struct CreationChoiceView: View {
    var body: some View {
        VStack {
            Text("How would you like to create your daytrip?")
                .bold()
            
            NavigationLink(destination: TripNameView()) {
                Text("Plan it myself")
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            
            Text("or")
                .fontWeight(.light)
            
            //TODO: Implement AI / ML daytrip creation feature
            NavigationLink(destination: CreateTripView()) {
                Text("Let AI decide for me")
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .navigationTitle(Text("Create a Daytrip"))
        .navigationBarTitleDisplayMode(.large)
    }
        
}

#Preview {
    NavigationStack {
        CreationChoiceView()
    }
}

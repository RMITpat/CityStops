//
//  TripDetailView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI

struct TripDetailView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel

    
    var body: some View {
        if let trip = appVM.currentTrip {
            
            
            
            
        } else {
            Text("Error")
        }
    }
}

#Preview {
    TripDetailView()
}

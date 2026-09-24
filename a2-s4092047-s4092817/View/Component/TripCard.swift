//
//  TripCard.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 24/9/2026.
//

import SwiftUI
import _MapKit_SwiftUI

struct TripCard: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel

    let trip: Trip
    
    @State var routes: [MKRoute] = []
    var body: some View {
        @Bindable var locationVM = locationVM
        Text(trip.name)
        Map {
            ForEach(trip.mkMapItemPlaces, id: \.self) { place in
                    Marker(item: place)
                        .mapItemDetailSelectionAccessory(.callout)
                    ForEach(routes, id: \.self) { route in
                                    MapPolyline(route)
                                        .stroke(.blue, lineWidth: 5)
                                }
            }
            
        }
        .frame(height: 400)
        .task {
            do {
                routes = try await locationVM.createRoute(selectedPlaces: trip.mkMapItemPlaces)
            } catch {
                
            }
            
        }
    }
}



//
//  CreateRouteView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 21/9/2026.
//

import SwiftUI
import MapKit

struct CreateRouteView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel

    var body: some View {
        @Bindable var locationVM = locationVM

        Map (position: $locationVM.currentLocation) {
            ForEach(locationVM.selectedPlaces, id: \.self) { place in
                Marker(item: place)
                    .mapItemDetailSelectionAccessory(.callout)
            }
            ForEach(locationVM.routes, id: \.self) { route in
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
        }
        .frame(height:400)
        .onAppear {
            locationVM.createRoute()
            print(locationVM.routes.count)
        }
    }
}

#Preview {
    CreateRouteView()
        .environment(LocationViewModel())
}

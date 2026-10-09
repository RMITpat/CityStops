//
//  TripCard.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 24/9/2026.
//

import SwiftUI
import _MapKit_SwiftUI


///
/// The card view for each trip in the trip feed
/// 
struct TripCard: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel
    
    /// The trip this card displays information for
    let trip: Trip
    @Binding var navRoute: [FeedRoute]
    @State var routes: [MKRoute] = []
    
    var body: some View {
        @Bindable var locationVM = locationVM        

        VStack(alignment: .leading) {
            
            TripCardInfo(trip: trip)
            
            UIKitMapView(
                position: .framing(trip.mkMapItemPlaces.map({$0.mkMapItem})),
                places: trip.mkMapItemPlaces.map({$0.mkMapItem}),
                routes: routes,
                showsUserLocation: false,
                isPinSelectable: false,
                interactionModes: []
            )
            .accessibilityHidden(true)
            .padding(5)
            .frame(height: 350)
            .clipShape(RoundedRectangle(cornerRadius: 50))

            .task {
                do {
                    routes = try await locationVM.createTripRoutes(selectedPlaces: trip.mkMapItemPlaces, tripID: trip.id)
                } catch {
                    // TODO: display error somewhere
                }
                
            }
            // MARK: Desc + Save button
            VStack(alignment: .center) {
                HStack() {
                    Text(trip.createdAt.formatted())
                        .font(.subheadline)
                    Spacer()
                    SaveTripButton(trip: trip)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

        }
        
        .contentShape(Rectangle())
        .onTapGesture {
            navRoute.append(.tripDetail)
            appVM.currentTrip = trip
        }
        .padding(18)

    }
}


#Preview {
    @Previewable @State var route: [FeedRoute] = []
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    let trip = Trip(id: "1", ownerUsername: "conan", ownerId: "", name: "Cool trip", description: "Cool trip to go on!", places: [], preferences: ["Food", "Landmarks"])
    let trip2 = Trip(id: "", ownerUsername: "bob", ownerId: "", name: "Cool trip again", description: "Another cool trip to go on!", places: [], preferences: ["Food", "Sightseeing"])
    
    TripFeed(trips: [trip, trip2], isLoading: false, route: $route, onRefresh: {}, loadTrips: {} )
        .environment(LocationViewModel(user: user))
        .environment(AppViewModel(user: user))
        .environment(Router())


}

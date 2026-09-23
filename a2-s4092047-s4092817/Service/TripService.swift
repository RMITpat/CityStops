//
//  TripService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 22/9/2026.
//

import Foundation
import FirebaseFirestore

@MainActor
protocol TripService {
    
}

@MainActor
final class TripServiceImpl: TripService {
    private let db = Firestore.firestore()
    
    func saveTrip(userId: String, trip: Trip) async throws {
        let ref = db.collection("trips").document()
        
        try await ref.setData(trip.asDictionary)
    }
}

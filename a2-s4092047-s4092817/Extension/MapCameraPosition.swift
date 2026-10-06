//
//  MapCameraPosition.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 6/10/2026.
//

import SwiftUI
import MapKit

/// Used with ``UIKitMapView`` in:
/// - ``TripDetailView``
/// - ``TripCard``
/// for calculating camera center based on ``Trip`` spots.
///
extension MapCameraPosition {
    static func framing(_ items: [MKMapItem]) -> MapCameraPosition {
        let rect = items
            .map { MKMapRect(origin: MKMapPoint($0.location.coordinate), size: MKMapSize(width: 0, height: 0)) }
            .reduce(MKMapRect.null) { $0.union($1) }

        guard !rect.isNull else { return .automatic }

        // Minimum size so a single place isn't zoomed to the max
        let minSize = 2_000.0
        var padded = rect.insetBy(
            dx: -max(0, (minSize - rect.width) / 2),
            dy: -max(0, (minSize - rect.height) / 2)
        )

        // Extra breathing room around the pins
        padded = padded.insetBy(dx: -padded.width * 0.25, dy: -padded.height * 0.25)

        return .region(MKCoordinateRegion(padded))
    }
}

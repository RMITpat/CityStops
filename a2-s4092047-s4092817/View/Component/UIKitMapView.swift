
//  UIKitMapView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 5/10/2026.
//
import SwiftUI
import MapKit

/// UIKit feature - bridges ``MKMapView`` in SwiftUI, which acts as a ``MapKit`` Map view.
@MainActor
struct UIKitMapView: UIViewRepresentable {

    // Equivalent of Map(position:)
    /// Camera position of Map.
    var position: MapCameraPosition

    // Equivalent of the ForEach(selectedPlaces) { Marker(item:) }
    /// Places in the ``Trip``, displayed on the Map.
    var places: [MKMapItem]

    // Equivalent of the ForEach(routes) { MapPolyline(route) }
    /// Routes between adjacent ``MKMapItems`` in `places`.
    var routes: [MKRoute]

    /// makes the UIView for the first time.
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        map.delegate = context.coordinator
        map.showsUserLocation = true

        map.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: Coordinator.markerID
        )

        return map
    }

    /// updates the UIView when changes are made.
    func updateUIView(_ map: MKMapView, context: Context) {

        context.coordinator.parent = self

        applyCamera(to: map, context: context)

        syncPlaces(on: map)
        syncRoutes(on: map)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: Camera (MapCameraPosition -> MKMapView)
    /// applies the Map camera position and region.
    private func applyCamera(
        to map: MKMapView,
        context: Context
    ) {

        // Only apply the initial camera once based on user location;
        // otherwise camera is static
        guard !context.coordinator.hasAppliedInitialCamera else {
            return
        }

        if let region = position.region {

            map.setRegion(
                region,
                animated: false
            )

        } else if let camera = position.camera {

            map.setCamera(
                MKMapCamera(
                    lookingAtCenter: camera.centerCoordinate,
                    fromDistance: camera.distance,
                    pitch: camera.pitch,
                    heading: camera.heading
                ),
                animated: false
            )
        }
        context.coordinator.hasAppliedInitialCamera = true
    }

    // MARK: Markers
    /// syncs the selected places with UIKit annotations.
    private func syncPlaces(on map: MKMapView) {

        let existing = map.annotations.compactMap {
            $0 as? PlaceAnnotation
        }

        let existingItems = Set(
            existing.map(\.mapItem)
        )

        let newItems = Set(places)

        map.removeAnnotations(
            existing.filter {
                !newItems.contains($0.mapItem)
            }
        )

        map.addAnnotations(
            places
                .filter {
                    !existingItems.contains($0)
                }
                .map(PlaceAnnotation.init)
        )
    }

    // MARK: Routes
    /// syncs the MKRoutes of selected places with UIKit overlays.
    private func syncRoutes(on map: MKMapView) {

        let existing = Set(
            map.overlays
                .compactMap { $0 as? MKPolyline }
                .map(ObjectIdentifier.init)
        )

        let newPolylines = routes.map(\.polyline)

        let newSet = Set(
            newPolylines.map(ObjectIdentifier.init)
        )

        map.removeOverlays(
            map.overlays.filter {

                guard let p = $0 as? MKPolyline else {
                    return false
                }

                return !newSet.contains(
                    ObjectIdentifier(p)
                )
            }
        )

        map.addOverlays(
            newPolylines.filter {
                !existing.contains(
                    ObjectIdentifier($0)
                )
            }
        )
    }

    // MARK: Annotation type wrapping an MKMapItem
    /// ``MKMapItem`` wrapper.
    final class PlaceAnnotation: NSObject, MKAnnotation {

        let mapItem: MKMapItem

        var coordinate: CLLocationCoordinate2D {
            mapItem.location.coordinate
        }

        var title: String? {
            mapItem.name
        }

        init(_ mapItem: MKMapItem) {
            self.mapItem = mapItem
        }
    }

    // MARK: Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {

        static let markerID = "place-marker"

        var parent: UIKitMapView

        var isUpdatingFromMap = false

        // NEW: Tracks whether the initial camera has been applied.
        var hasAppliedInitialCamera = false

        init(_ parent: UIKitMapView) {
            self.parent = parent
        }

        // Marker(item:) + .mapItemDetailSelectionAccessory(.callout)
        /// displays pin annotation when a chosen Location on the Map is tapped.
        func mapView(
            _ mapView: MKMapView,
            selectionAccessoryFor annotation: MKAnnotation
        ) -> MKSelectionAccessory? {

            guard annotation is MKMapItemAnnotation else {
                return nil
            }

            return .mapItemDetail(.callout)
        }

        // MapPolyline(route).stroke(.blue, lineWidth: 5)
        /// renders the Polyline route on the Map.
        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {

            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(
                polyline: polyline
            )

            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5

            return renderer
        }
    }
}

// MARK: - Usage

// UIKitMapView(position: locationVM.currentLocation,
//             places: tripCreationVM.selectedPlaces,
//             routes: routes)

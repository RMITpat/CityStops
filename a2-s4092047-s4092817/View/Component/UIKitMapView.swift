
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
    
    /// Handles gesture interaction.
    var interactionModes: MapInteractionModes = .all

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
        applyInteraction(to: map)

        syncPlaces(on: map)
        syncRoutes(on: map)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Interaction (MapInteractionModes -> MKMapView)
    /// Enables or disables the map's gestures.
    private func applyInteraction(to map: MKMapView) {
        map.isScrollEnabled = interactionModes.contains(.pan)
        map.isZoomEnabled   = interactionModes.contains(.zoom)
        map.isRotateEnabled = interactionModes.contains(.rotate)
        map.isPitchEnabled  = interactionModes.contains(.pitch)
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
                .map { PlaceAnnotation($0) }
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
    /// Adapts an ``MKMapItem`` for use as an ``MKAnnotation`` in ``MKMapView``.
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

        var hasAppliedInitialCamera = false

        init(_ parent: UIKitMapView) {
            self.parent = parent
        }

        /// Builds the pin's annotation view.
        func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {

            guard let place = annotation as? PlaceAnnotation else {
                return nil
            }

            // reuse already rendered view if possible to optimise
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: Coordinator.markerID,
                for: place
            ) as! MKMarkerAnnotationView

            // Custom annotation rendering
            view.canShowCallout = true
            let stopNumber = parent.places
                .firstIndex(of: place.mapItem)
                .map { $0 + 1 }
            view.detailCalloutAccessoryView = makeDetailView(
                for: place.mapItem,
                stopNumber: stopNumber
            )

            return view
        }

        /// Rerenders the annotation when the order of the location in the ``Trip`` changes.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let place = view.annotation as? PlaceAnnotation else { return }
            let stopNumber = parent.places.firstIndex(of: place.mapItem).map { $0 + 1 }
            view.detailCalloutAccessoryView = makeDetailView(for: place.mapItem, stopNumber: stopNumber)
        }

        // MapPolyline(route).stroke(.blue, lineWidth: 5)
        /// Renders the Polyline route on the Map.
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
        
        // MARK: - Annotation render functions
        /// Builds the annotation subview (the "bubble" that pops up when a pin is tapped).
        private func makeDetailView(for item: MKMapItem, stopNumber: Int?) -> UIView {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            stack.alignment = .leading

            if let stopNumber {
                let stopLabel = UILabel()
                stopLabel.text = "\(ordinal(stopNumber)) stop"
                stopLabel.font = .preferredFont(forTextStyle: .subheadline)
                stopLabel.textColor = .secondaryLabel

                stack.addArrangedSubview(stopLabel)
                stack.setCustomSpacing(8, after: stopLabel)   // gap before the detail rows
            }

            if let address = item.address?.shortAddress {
                stack.addArrangedSubview(
                    makeRow(symbol: "location.fill", text: address)
                )
            }
            if let phone = item.phoneNumber {
                stack.addArrangedSubview(
                    makeRow(symbol: "phone.fill", text: phone)
                )
            }
            if let host = item.url?.host() {
                stack.addArrangedSubview(
                    makeRow(symbol: "globe", text: host)
                )
            }

            stack.widthAnchor.constraint(
                lessThanOrEqualToConstant: 240
            ).isActive = true

            return stack
        }
        
        /// Formats an icon, then a text row inside the annotation body.
        private func makeRow(symbol: String, text: String) -> UIView {
            let icon = UIImageView(image: UIImage(systemName: symbol))
            icon.tintColor = .secondaryLabel
            icon.contentMode = .scaleAspectFit
            icon.setContentHuggingPriority(.required, for: .horizontal)
            icon.widthAnchor.constraint(equalToConstant: 16).isActive = true

            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel

            let row = UIStackView(arrangedSubviews: [icon, label])
            row.axis = .horizontal
            row.spacing = 6
            row.alignment = .firstBaseline
            return row
        }
        
        /// Turns integer values into ordinal values (i.e. 1st, 2nd, 3rd ...)
        private func ordinal(_ n: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
        }
    }
    
}

// MARK: - Test Usage
// Some parts don't appear because the MKMapItems are fabricated.
//
// Test fully using Simulator / on-device instead
#Preview {
    let federationSquare = MKMapItem(
        location: CLLocation(latitude: -37.8180, longitude: 144.9691),
        address: nil
    )
    federationSquare.name = "Federation Square"

    let flinders = MKMapItem(
        location: CLLocation(latitude: -37.8183, longitude: 144.9671),
        address: nil
    )
    flinders.name = "Flinders Street Station"

    return UIKitMapView(
        position: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -37.8180, longitude: 144.9680),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ),
        places: [federationSquare, flinders],
        routes: []
    )
}

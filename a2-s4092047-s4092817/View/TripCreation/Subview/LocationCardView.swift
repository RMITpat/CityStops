//
//  LocationCardView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 22/9/2026.
//

import SwiftUI
import MapKit

struct LocationCardView: View {
    let location: MKMapItem
    var selectedPlaces: Binding<[MKMapItem]>?
    
    /// Takes a Binding for ``selectedPlaces`` when ``location`` can be added or deleted from a ``Trip``.
    init(location: MKMapItem,
         selectedPlaces: Binding<[MKMapItem]>?) {
        self.location = location
        self.selectedPlaces = selectedPlaces
    }

    /// Takes a ``Location`` for view-only display.
    init(location: MKMapItem) {
        self.location = location
        self.selectedPlaces = nil
    }
    
    /// View-specific state to detect if location is part of ``Trip``.
    var isSelected: Bool {
        // Only unwraps selectedPlaces if ``selectedPlaces`` is passed
        guard (selectedPlaces != nil) else { return false }
        
        return selectedPlaces!.wrappedValue.contains(where: {
            $0.identifier == location.identifier
        })
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Location pin SF Symbol icon
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.gray)
            
            // Place information
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name ?? "No name")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(location.address?.shortAddress ?? "No address")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1) // address should not be extremely long
            }
            
            Spacer()
            
            // MARK: "Add" / "Remove" button
            if (selectedPlaces != nil) {
                Button {
                    isSelected ? selectedPlaces!.wrappedValue.removeAll(where: { $0.identifier == location.identifier }) : selectedPlaces!.wrappedValue.append(location)
                } label: {
                    Image(systemName: isSelected ? "minus" : "plus")
                        .bold()
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(isSelected ? Color.red : Color.accentColor)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        // Card border
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var selectedPlaces: [MKMapItem] = []
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    LocationCardView(
        location: LocationCardPreviewData.testLocation,
        selectedPlaces: $selectedPlaces)
}

/// Test MKMapItem used for testing ``LocationCardView``.
private enum LocationCardPreviewData {
    static let testLocation: MKMapItem = {
        let location = CLLocation(
            latitude: -37.8136,
            longitude: 144.9631
        )

        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = "Federation Square"
        return mapItem
    }()
}

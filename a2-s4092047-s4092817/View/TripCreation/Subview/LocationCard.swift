//
//  LocationCard.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 22/9/2026.
//

import SwiftUI
import MapKit

struct LocationCard: View {
    let location: MKMapItem
    var selectedPlaces: Binding<[MKMapItem]>?
    var placesToRemove: Binding<[MKMapItem.Identifier]>?

    
    /// Takes a ``Location`` to be  displayed.
    /// Optionally, takes a Binding for ``selectedPlaces`` when ``location`` can be added or deleted from a ``Trip``.
    /// Optionally, takes  a binding for ``placesToRemove`` when ``location`` is to be regenerated in an AI generated trip
    init(location: MKMapItem,
         selectedPlaces: Binding<[MKMapItem]>? = nil,
         placesToRemove: Binding<[MKMapItem.Identifier]>? = nil
    ) {
        self.location = location
        self.selectedPlaces = selectedPlaces
        self.placesToRemove = placesToRemove
    }
    
    /// View-specific state to detect if location is part of ``Trip``.
    var isSelected: Bool {
        if let selectedPlaces {
            return selectedPlaces.wrappedValue.contains(where: {
                $0.identifier == location.identifier
            })
        }
        return false
    }
    
    
    var isSelectedForRemoval: Bool {
        if let placesToRemove, let identifier = location.identifier {
            return placesToRemove.wrappedValue.contains(where: {
                $0 == identifier
            })
        }
        
        return false
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
                    if let selectedPlaces {
                        isSelected ? selectedPlaces.wrappedValue.removeAll(where: { $0.identifier == location.identifier }) : selectedPlaces.wrappedValue.append(location)
                    }
                } label: {
                    Image(systemName: isSelected ? "minus" : "plus")
                        .bold()
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(isSelected ? Color.red : Color.accentColor)
                        .clipShape(Circle())
                }
            }
            
            if (placesToRemove != nil) {
                Button("",
                       systemImage: isSelectedForRemoval ? "checkmark.circle.fill" : "circle"
                ) {
                    if let identifier = location.identifier, let placesToRemove {
                        isSelectedForRemoval ? placesToRemove.wrappedValue.removeAll(where: { $0 == identifier}) : placesToRemove.wrappedValue.append(identifier)
                    }
                }
                .font(.title)
                .foregroundColor(isSelectedForRemoval ?
                    .dora : .gray
                )
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
    LocationCard(
        location: LocationCardPreviewData.testLocation,
        selectedPlaces: $selectedPlaces)
}

/// Test MKMapItem used for testing ``LocationCard``.
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

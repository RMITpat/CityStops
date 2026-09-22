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
    let locationVM: LocationViewModel
    
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
            
            // "Add" button
            Button {
                locationVM.selectedPlaces.append(location)
            } label: {
                Image(systemName: "plus")
                    .bold()
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor)
                    .clipShape(Circle())
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
    LocationCardView(
        location: LocationCardPreviewData.testLocation,
        locationVM: LocationViewModel()
    )
}

/// Test MKMapItem used for testing ``LocationCardView``.
private enum LocationCardPreviewData {
    static let testLocation: MKMapItem = {
        let coordinate = CLLocationCoordinate2D(
            latitude: -37.8136,
            longitude: 144.9631
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Federation Square"
        return mapItem
    }()
}

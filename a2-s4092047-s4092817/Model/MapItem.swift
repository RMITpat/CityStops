//
//  MapItem.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 7/10/2026.
//

import Foundation
import MapKit

/// Wrapper around MKMapItem
struct MapItem : Hashable {
    let identifier: String
    let mkMapItem: MKMapItem
    
    init(identifier: String, mkMapItem: MKMapItem) {
        self.identifier = identifier
        self.mkMapItem = mkMapItem
    }
}

//
//  SearchTerm.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import Foundation
import SwiftData

@Model
final class SearchTerm {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var term: String
    var searchDate: Date

    
    init(id: UUID = UUID(), term: String, searchDate: Date = .now) {
        self.id = id
        self.term = term
        self.searchDate = searchDate
     
    }
}


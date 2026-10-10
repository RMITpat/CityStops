//
//  MockSearchTermService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import SwiftData

///Mock search term service that will not save or read data from SwiftData
@MainActor
final class MockSearchTermService : SearchTermService {
    var modelContext: ModelContext? = nil
    
    var dummyPastTerms = [
        SearchTerm(term: "Restaurants"),
        SearchTerm(term: "Shops"),
        SearchTerm(term: "Beaches"),
        SearchTerm(term: "Cinemas"),
        SearchTerm(term: "Gardens")
    ]
    
    func fetch() -> [SearchTerm] {
        return dummyPastTerms
    }
    
    func insert(term: SearchTerm) {
        if let index = dummyPastTerms.firstIndex(where: {$0.term == term.term}) {
            dummyPastTerms.remove(at: index)
            dummyPastTerms.append(term)
            return
        }
        dummyPastTerms.removeLast()
        dummyPastTerms.append(term)
    }
    
    func delete(term: SearchTerm) {
        dummyPastTerms.removeAll(where: {$0.term == term.term})
    }
    
    func attach(modelContext: ModelContext) {
        
    }
    
    
}

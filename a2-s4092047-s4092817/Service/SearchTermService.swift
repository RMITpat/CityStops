//
//  SearchTermService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import Foundation
import SwiftData

@MainActor
protocol SearchTermService {
    var modelContext: ModelContext? { get set}

    func fetch() -> [SearchTerm]
    func insert(term: SearchTerm)
    func delete(term: SearchTerm)
    func attach(modelContext: ModelContext)
}

@MainActor
final class SearchTermServiceImpl: SearchTermService {
    var modelContext: ModelContext?
    
    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetch() -> [SearchTerm] {
        guard let ctx = modelContext else { return [] }

        
        let descriptor = FetchDescriptor<SearchTerm>(
            sortBy: [SortDescriptor(\.searchDate, order: .reverse)]
        )
        do {
            let allSearches = try ctx.fetch(descriptor)
            return allSearches
        } catch {
            return []
        }
        
    }
    
    func insert(term: SearchTerm) {
        guard let ctx = modelContext else { return }

        
        ctx.insert(term)
        
        do {
            try trimSearches()
            try ctx.save()
        } catch {
            // Doesn't really matter to user right?
            print("Search term not saved")
        }
        
    }
    
    func delete(term: SearchTerm) {
        guard let ctx = modelContext else { return }
        ctx.delete(term)
    }
    
    func trimSearches() throws {
        guard let ctx = modelContext else { return }
        
        let LIMIT = 5

        let allSearches = fetch()

        if allSearches.count > LIMIT {
            let searchesToDelete = allSearches[LIMIT...]

            for search in searchesToDelete {
                ctx.delete(search)
            }

            try ctx.save()
        }
    }
}



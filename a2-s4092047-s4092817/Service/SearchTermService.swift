//
//  SearchTermService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import Foundation
import SwiftData

/// Service that handles the SwiftData logic of a user's Location search history.
///
/// See ``SearchTermServiceImpl`` for the real implementation in the app.
@MainActor
protocol SearchTermService {
    var modelContext: ModelContext? { get set}

    /// Fetches all saved search terms, ordered from newest to oldest.
    ///
    /// - Returns: An array of search terms, or an empty array if the context is unavailable
    ///   or the fetch fails.
    func fetch() -> [SearchTerm]
    
    /// Saves a search term and removes older searches if the history exceeds the limit.
    ///
    /// - Parameter term: The search term to insert into the database.
    func insert(term: SearchTerm)
    
    /// Deletes a search term from the model context.
    ///
    /// - Parameter term: The search term to delete.
    func delete(term: SearchTerm)
    
    /// Attaches the SwiftData model context used to perform database operations.
    func attach(modelContext: ModelContext)
}

/// Real implementation of ``SearchTermService`` in the app.
@MainActor
final class SearchTermServiceImpl: SearchTermService {
    var modelContext: ModelContext?
    
    /// Attaches the SwiftData model context used to perform database operations.
    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Fetches all saved search terms, ordered from newest to oldest.
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
    
    /// Saves a search term and removes older searches if the history exceeds the limit.
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
    
    /// Deletes a search term from the model context.
    func delete(term: SearchTerm) {
        guard let ctx = modelContext else { return }
        ctx.delete(term)
    }
    
    /// Removes search terms beyond the maximum number allowed.
    ///
    /// The most recent searches are retained, while older searches are deleted.
    /// - Throws: An error if saving the updated context fails.
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



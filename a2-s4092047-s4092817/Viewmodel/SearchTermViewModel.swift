//
//  SearchTermViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import Foundation
import SwiftData

@Observable
final class SearchTermViewModel {
    private var searchTermService: SearchTermService
    
    /// Real init
    init() {
        searchTermService = SearchTermServiceImpl()
    }
    
    /// Mock init
    init(searchTermService: SearchTermService) {
        self.searchTermService = searchTermService
    }
    
    func attach(modelContext: ModelContext) {
        searchTermService.attach(modelContext: modelContext)
    }
    
    func insert(searchTerm: String) {
        let st = SearchTerm(term: searchTerm)

        searchTermService.insert(term: st)
    }
    
    func delete(searchTerm: SearchTerm) {
        searchTermService.delete(term: searchTerm)
    }
    
    func fetch() -> [SearchTerm] {
        return searchTermService.fetch()
    }
    
}

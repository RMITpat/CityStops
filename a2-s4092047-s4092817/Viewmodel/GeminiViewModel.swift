//
//  GeminiViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation

@Observable class GeminiViewModel {
    let geminiService = GeminiServiceImpl()
    
    func request() {
        Task {
            do {
                try await geminiService.request()
            } catch {
                
            }
        }
    }
}

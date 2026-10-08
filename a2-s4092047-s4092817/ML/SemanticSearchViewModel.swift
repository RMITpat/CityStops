//
//  SemanticSearchViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


import Foundation
import Combine

@MainActor
final class SemanticSearchViewModel: ObservableObject {

    struct Match: Identifiable, Hashable {
        let id = UUID()
        let text: String
        let score: Float   // cosine similarity, roughly -1...1 (higher = more related)
    }

    @Published private(set) var matches: [Match] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var engine: EmbeddingEngine?
    private var cache: [String: [Float]] = [:]   // text -> embedding, so repeat searches are fast

    /// Takes an array of input texts and returns the candidates most related to them.
    /// Multiple inputs are combined by averaging their embeddings into one "profile".
    @discardableResult
    func findRelated(to inputs: [String], in candidates: [String], topK: Int = 5) async -> [String] {
        let queries = clean(inputs)
        let pool = clean(candidates)

        guard !queries.isEmpty, !pool.isEmpty else {
            matches = []
            return []
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let eng = try await loadEngine()
            let queryVectors = try await vectors(for: queries, using: eng)
            let candidateVectors = try await vectors(for: pool, using: eng)

            let profile = normalized(mean(queryVectors))
            let inputSet = Set(queries.map { $0.lowercased() })

            let ranked = zip(pool, candidateVectors)
                .filter { !inputSet.contains($0.0.lowercased()) }   // don't return the inputs themselves
                .map { Match(text: $0.0, score: dot(profile, $0.1)) }
                .sorted { $0.score > $1.score }
                .prefix(topK)

            matches = Array(ranked)
            return matches.map(\.text)
        } catch {
            errorMessage = error.localizedDescription
            matches = []
            return []
        }
    }

    // MARK: - Private

    private func loadEngine() async throws -> EmbeddingEngine {
        if let engine { return engine }
        // Model loading is heavy, so keep it off the main thread.
        let created = try await Task.detached { try EmbeddingEngine() }.value
        engine = created
        return created
    }

    private func vectors(for texts: [String], using engine: EmbeddingEngine) async throws -> [[Float]] {
        let missing = Array(Set(texts.filter { cache[$0] == nil }))
        if !missing.isEmpty {
            let embedded = try await engine.embed(missing)
            for (text, vector) in zip(missing, embedded) { cache[text] = vector }
        }
        return texts.map { cache[$0] ?? [] }
    }

    private func clean(_ strings: [String]) -> [String] {
        var seen = Set<String>()
        return strings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    private func mean(_ vectors: [[Float]]) -> [Float] {
        guard let first = vectors.first else { return [] }
        var sum = [Float](repeating: 0, count: first.count)
        for v in vectors {
            for i in 0..<sum.count { sum[i] += v[i] }
        }
        return sum.map { $0 / Float(vectors.count) }
    }

    private func normalized(_ v: [Float]) -> [Float] {
        let norm = sqrt(v.reduce(0) { $0 + $1 * $1 })
        return norm > 0 ? v.map { $0 / norm } : v
    }

    private func dot(_ a: [Float], _ b: [Float]) -> Float {
        zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
    }
}

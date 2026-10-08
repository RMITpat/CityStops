//
//  RecommendationViewModel.swift
//  a2-s4092047-s4092817
//

import Combine
import Foundation
import CoreML


// ViewModel: Handles interaction between the SwiftUI View and the MiniLM Core ML model.
// Given what the user types, it returns the candidate strings that are most related to it.
final class RecommendationViewModel: ObservableObject {

    // MARK: - Properties

    // The Core ML model auto-generated from MiniLM.mlpackage
    private let model: MiniLM

    // Turns text into input_ids / attention_mask (needs vocab.txt in the bundle)
    private let tokeniser: WordPieceTokenizer

    // Must match the sequence length used when converting the model
    private let maxLength = 128

    // The suggestions shown in the UI (best match first)
    @Published var suggestions: [String] = []
    @Published var errorMessage: String?

    // Background queue so inference never blocks the UI
    private let mlQueue = DispatchQueue(label: "ml.minilm.queue", qos: .userInitiated)

    // Used to debounce predictions (cancel older work if the user keeps typing)
    private var pendingWorkItem: DispatchWorkItem?

    // Lets us ignore results from outdated requests (only touched on the main thread)
    private var requestCounter = 0

    // Only touched on mlQueue
    private var candidates: [String] = []
    private var candidateVectors: [[Float]] = []

    private enum EmbedError: LocalizedError {
        case noOutput
        var errorDescription: String? { "The model did not return an embedding." }
    }


    // MARK: - Init

    init() {
        do {
            model = try MiniLM(configuration: .init())

            guard let vocabURL = Bundle.main.url(forResource: "vocab", withExtension: "txt") else {
                fatalError("vocab.txt not found in app bundle")
            }

            tokeniser = try WordPieceTokenizer(vocabURL: vocabURL, maxLength: 128)

        } catch {
            fatalError("Failed to initialise ML model: \(error)")
        }
    }


    // MARK: - Candidates

    /// Call once (or whenever your list changes). Embeds every candidate in the background.
    func setCandidates(_ strings: [String]) {
        var seen = Set<String>()
        let pool = strings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }

        suggestions = []

        mlQueue.async { [weak self] in
            guard let self else { return }
            do {
                let vectors = try pool.map { try self.embed($0) }
                self.candidates = pool
                self.candidateVectors = vectors
            } catch {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                print("Indexing error:", error)
            }
        }
    }


    // MARK: - Core prediction logic

    /// Schedule a prediction after a small delay (debounce),
    /// so we don't re-run the model on every keystroke.
    func schedulePredict(context: String, topN: Int = 5) {
        // Cancel any pending work (user typed again)
        pendingWorkItem?.cancel()

        let text = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            requestCounter += 1
            suggestions = []
            return
        }

        requestCounter += 1
        let requestID = requestCounter

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            do {
                // Embed what the user typed
                let query = try self.embed(text)

                // Rank candidates by cosine similarity
                // (vectors are L2-normalised, so dot product == cosine similarity)
                let top = zip(self.candidates, self.candidateVectors)
                    .map { (text: $0.0, score: self.dot(query, $0.1)) }
                    .sorted { $0.score > $1.score }
                    .prefix(topN)
                    .map { $0.text }

                DispatchQueue.main.async {
                    guard requestID == self.requestCounter else { return }
                    self.suggestions = Array(top)
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    guard requestID == self.requestCounter else { return }
                    self.suggestions = []
                    self.errorMessage = error.localizedDescription
                }
                print("Prediction error:", error)
            }
        }

        pendingWorkItem = workItem
        // Runs on the serial mlQueue, so it always executes after candidate indexing finishes.
        mlQueue.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }


    // MARK: - Helper Methods

    /// Runs the MiniLM model and returns a normalised 384-dim embedding.
    /// Call from mlQueue only.
    private func embed(_ text: String) throws -> [Float] {
        let (ids, mask) = tokeniser.encode(text)

        let shape: [NSNumber] = [1, NSNumber(value: maxLength)]
        let idArray = try MLMultiArray(shape: shape, dataType: .int32)
        let maskArray = try MLMultiArray(shape: shape, dataType: .int32)

        for i in 0..<maxLength {
            idArray[i] = NSNumber(value: ids[i])
            maskArray[i] = NSNumber(value: mask[i])
        }

        let out = try model.prediction(input_ids: idArray, attention_mask: maskArray)

        // The converted model has a single output; its name is auto-generated, so look it up.
        guard let name = out.featureNames.first,
              let result = out.featureValue(for: name)?.multiArrayValue else {
            throw EmbedError.noOutput
        }

        var vector = (0..<result.count).map { result[$0].floatValue }

        let norm = sqrt(vector.reduce(0) { $0 + $1 * $1 })
        #if DEBUG
        print("embedding count:", vector.count, "norm:", norm, "first5:", vector.prefix(5))
        #endif

        if norm > 0 { vector = vector.map { $0 / norm } }
        return vector
    }

    private func dot(_ a: [Float], _ b: [Float]) -> Float {
        zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
    }
}

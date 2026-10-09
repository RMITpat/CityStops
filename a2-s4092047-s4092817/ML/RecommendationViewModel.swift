//
//  RecommendationViewModel.swift
//  a2-s4092047-s4092817
//

import Combine
import Foundation
import CoreML

/// Handles ``Trip`` recommendation logic using the ``all-MiniLM-L6-v2`` PyTorch model.
/// The model facilitates semantic search based on the Title of all the user's saved ``Trip``.
final class RecommendationViewModel: ObservableObject {
        
    // MARK: - Properties
    /// The Core ML model loaded from MiniLM.mlpackage.
    private let model: MiniLM

    /// Turns input text into the input type of the CoreML model.
    private let tokeniser: WordPieceTokenizer

    /// Sequence length used when converting text input to be used in the ML model.
    private let maxLength = 128

    // The suggestions shown in the UI (best match first)
    @Published var suggestions: [String] = []
    @Published var errorMessage: String?

    // Background queue so inference never blocks the UI
    private let mlQueue = DispatchQueue(label: "ml.minilm.queue", qos: .userInitiated)

    // Lets us ignore results from outdated requests (only touched on the main thread)
    private var requestCounter = 0

    // Only touched on mlQueue
    private var candidates: [String] = []
    private var candidateVectors: [[Float]] = []

    private enum EmbedError: LocalizedError {
        case noOutput

        var errorDescription: String? {
            "The model did not return an embedding."
        }
    }

    // MARK: - Init
    
    init() {
        do {
            model = try MiniLM(configuration: .init())

            guard let vocabURL = Bundle.main.url(
                forResource: "vocab",
                withExtension: "txt"
            ) else {
                fatalError("vocab.txt not found in app bundle")
            }

            tokeniser = try WordPieceTokenizer(
                vocabURL: vocabURL,
                maxLength: 128
            )
        } catch {
            fatalError("Failed to initialise ML model: \(error)")
        }
    }

    // MARK: - Candidates

    /// Call once (or whenever your list changes). Embeds every candidate in the background.
    func setCandidates(_ strings: [String]) {
        var seen = Set<String>()

        let pool = strings
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter {
                !$0.isEmpty && seen.insert($0).inserted
            }

        suggestions = []

        mlQueue.async { [weak self] in
            guard let self else {
                return
            }

            do {
                let vectors = try pool.map {
                    try self.embed($0)
                }

                self.candidates = pool
                self.candidateVectors = vectors

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }

                print("Indexing error:", error)
            }
        }
    }

    // MARK: - Core prediction logic

    /// Finds the candidates most related to a fixed set of input strings (e.g. the titles of the
    /// user's saved trips).
    ///
    /// Designed for input that does not change while the screen is showing.
    /// - Parameters:
    ///   - inputs: One or more strings; the Titles of saved ``Trip``. Their embeddings are averaged into a single recommendation "profile".
    ///   - topN: How many suggestions to return.
    ///   - comfidenceThreshold: How "similar" the String semantics must be.
    ///   - excludeInputs: If true, candidates identical to an input are not suggested back.
    func recommend(
        basedOn inputs: [String],
        topN: Int = 5,
        confidenceThreshold: Float = 0.2,
        excludeInputs: Bool = true,
        completion: (([String]) -> Void)? = nil
    ) {
        var seen = Set<String>()
        let texts = inputs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }

        guard !texts.isEmpty else {
            requestCounter += 1
            suggestions = []
            completion?([])
            return
        }

        requestCounter += 1
        let requestID = requestCounter

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else {
                return
            }

            do {
                let queryVectors = try texts.map { try self.embed($0) }
                let query = self.normalized(self.mean(queryVectors))
                let inputSet = Set(texts.map { $0.lowercased() })

                // Scored before the threshold filter
                let scored = zip(self.candidates, self.candidateVectors)
                    .filter { !excludeInputs || !inputSet.contains($0.0.lowercased()) }
                    .map { (text: $0.0, score: self.dot(query, $0.1)) }

                // Scoring DEBUG
                print("vector size:", query.count)
                print("candidates:", self.candidates.count)
                for item in scored.sorted(by: { $0.score > $1.score }) {
                    print(String(format: "%.3f", item.score), item.text)
                }

                // Only allow results that pass the confidence threshold
                let ranked = scored
                    .filter { $0.score >= confidenceThreshold }
                    .sorted { $0.score > $1.score }

                // rank by relevance
                let top = Array(ranked.prefix(topN)).map { $0.text }

                DispatchQueue.main.async {
                    guard requestID == self.requestCounter else {
                        return
                    }
                    completion?(top)
                    self.suggestions = top
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    guard requestID == self.requestCounter else {
                        return
                    }
                    completion?([])
                    self.suggestions = []
                    self.errorMessage = error.localizedDescription
                }
                print("Prediction error:", error)
            }
        }

        mlQueue.async(execute: workItem)
    }

    // MARK: - Helper Methods

    /// Runs the MiniLM model and returns the normalised word association vector for a String.
    private func embed(_ text: String) throws -> [Float] {

        let (ids, mask) = tokeniser.encode(text)

        let shape: [NSNumber] = [
            1,
            NSNumber(value: maxLength)
        ]

        let idArray = try MLMultiArray(
            shape: shape,
            dataType: .int32
        )

        let maskArray = try MLMultiArray(
            shape: shape,
            dataType: .int32
        )

        for i in 0..<maxLength {
            idArray[i] = NSNumber(value: ids[i])
            maskArray[i] = NSNumber(value: mask[i])
        }

        let out = try model.prediction(
            input_ids: idArray,
            attention_mask: maskArray
        )

        guard let name = out.featureNames.first,
              let result = out.featureValue(
                for: name
              )?.multiArrayValue else {
            throw EmbedError.noOutput
        }

        var vector = (0..<result.count).map {
            result[$0].floatValue
        }

        let norm = sqrt(
            vector.reduce(0) {
                $0 + $1 * $1
            }
        )

        if norm > 0 {
            vector = vector.map {
                $0 / norm
            }
        }
        return vector
    }
    
    /// Dot product of ``Float`` arrays.
    private func dot(_ a: [Float], _ b: [Float]) -> Float {
        zip(a, b).reduce(0) {
            $0 + $1.0 * $1.1
        }
    }

    /// Element-wise average of vectors (used to combine multiple input strings).
    private func mean(_ vectors: [[Float]]) -> [Float] {

        guard let first = vectors.first else {
            return []
        }

        var sum = [Float](
            repeating: 0,
            count: first.count
        )

        for vector in vectors {
            for i in 0..<sum.count {
                sum[i] += vector[i]
            }
        }

        return sum.map {
            $0 / Float(vectors.count)
        }
    }

    /// Scales a vector to length 1 so that similarity score is normalised after averaging.
    private func normalized(_ vector: [Float]) -> [Float] {

        let norm = sqrt(
            vector.reduce(0) {
                $0 + $1 * $1
            }
        )

        return norm > 0
            ? vector.map { $0 / norm }
            : vector
    }
}

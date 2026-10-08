//
//  EmbeddingError.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


import Foundation
import CoreML

enum EmbeddingError: LocalizedError {
    case modelNotFound
    case vocabNotFound
    case noOutput

    var errorDescription: String? {
        switch self {
        case .modelNotFound: return "MiniLM.mlmodelc not found in the app bundle. Check the model's target membership."
        case .vocabNotFound: return "vocab.txt not found in the app bundle. Add it to your Xcode target."
        case .noOutput:      return "The model did not return an embedding."
        }
    }
}

/// Wraps the Core ML model + tokenizer. Being an actor keeps inference off the main thread.
actor EmbeddingEngine {

    private let model: MLModel
    private let tokenizer: WordPieceTokenizer
    private let outputName: String
    private let maxLength = 128   // must match the length used during conversion

    init() throws {
        guard let modelURL = Bundle.main.url(forResource: "MiniLM", withExtension: "mlmodelc") else {
            throw EmbeddingError.modelNotFound
        }
        guard let vocabURL = Bundle.main.url(forResource: "vocab", withExtension: "txt") else {
            throw EmbeddingError.vocabNotFound
        }

        let config = MLModelConfiguration()
        config.computeUnits = .all

        let model = try MLModel(contentsOf: modelURL, configuration: config)

        guard let outputName = model.modelDescription.outputDescriptionsByName.keys.first else {
            throw EmbeddingError.noOutput
        }

        self.model = model
        self.outputName = outputName
        self.tokenizer = try WordPieceTokenizer(vocabURL: vocabURL, maxLength: 128)
    }

    func embed(_ texts: [String]) throws -> [[Float]] {
        try texts.map { try embed($0) }
    }

    func embed(_ text: String) throws -> [Float] {
        let (ids, mask) = tokenizer.encode(text)

        let shape: [NSNumber] = [1, NSNumber(value: maxLength)]
        let idArray = try MLMultiArray(shape: shape, dataType: .int32)
        let maskArray = try MLMultiArray(shape: shape, dataType: .int32)

        for i in 0..<maxLength {
            idArray[i] = NSNumber(value: ids[i])
            maskArray[i] = NSNumber(value: mask[i])
        }

        let input = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": idArray,
            "attention_mask": maskArray
        ])

        let output = try model.prediction(from: input)

        guard let result = output.featureValue(for: outputName)?.multiArrayValue else {
            throw EmbeddingError.noOutput
        }

        var vector = (0..<result.count).map { result[$0].floatValue }

        // The model already L2-normalizes, but make sure (cheap, and guards against fp16 drift).
        let norm = sqrt(vector.reduce(0) { $0 + $1 * $1 })
        if norm > 0 { vector = vector.map { $0 / norm } }

        return vector
    }
}
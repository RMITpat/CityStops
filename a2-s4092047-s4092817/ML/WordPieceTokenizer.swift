//
//  WordPieceTokenizer.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


import Foundation
import CoreML

/// BERT-style (uncased) WordPiece tokenizer. Matches the tokenizer used by the ML model all-MiniLM-L6-v2.
/// Used in ``RecommendationService`` to convert text into the appropriate input for the model.
/// Pulls vocabulary from `vocab.txt`.
struct WordPieceTokenizer {

    let maxLength: Int

    private let vocab: [String: Int32]
    private let clsID: Int32
    private let sepID: Int32
    private let unkID: Int32
    private let padID: Int32 = 0

    /// Gets vocabulary from the appropriate file.
    init(vocabURL: URL, maxLength: Int = 128) throws {
        let text = try String(contentsOf: vocabURL, encoding: .utf8)
        var dict = [String: Int32](minimumCapacity: 31_000)

        for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            let token = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !token.isEmpty { dict[token] = Int32(index) }
        }

        self.vocab = dict
        self.clsID = dict["[CLS]"] ?? 101
        self.sepID = dict["[SEP]"] ?? 102
        self.unkID = dict["[UNK]"] ?? 100
        self.maxLength = maxLength
    }
    
    /// Tokenizes `text` and wraps the result in the Core ML input type.
    func makeInput(_ text: String) -> MiniLMInput {
        let (ids, mask) = encode(text)
        let shape = [1, maxLength]

        return MiniLMInput(
            input_ids: MLShapedArray<Int32>(scalars: ids, shape: shape),
            attention_mask: MLShapedArray<Int32>(scalars: mask, shape: shape)
        )
    }

    /// Converts a ``String`` into padded `input_ids` and `attention_mask`, each exactly `maxLength` long.
    func encode(_ text: String) -> (ids: [Int32], mask: [Int32]) {

        // Start with the special [CLS] token required by BERT-style models.
        var ids: [Int32] = [clsID]

        // Convert the text into basic tokens, then convert each token
        // into one or more WordPiece vocabulary IDs.
        for word in basicTokenise(text) {
            ids += wordPiece(word)
            if ids.count >= maxLength - 1 {
                break
            }
        }

        // Make sure the sequence cannot exceed maxLength - 1, leaving one position for [SEP] token at very end
        ids = Array(ids.prefix(maxLength - 1))
        ids.append(sepID)

        // Number of positions containing real tokens
        let realCount = ids.count

        let padding = maxLength - realCount

        // Attention mask: 1 = real token 0 = padding
        let mask = [Int32](repeating: 1, count: realCount) +
                   [Int32](repeating: 0,count: padding)

        // Add [PAD] tokens
        ids += [Int32](repeating: padID, count: padding)

        return (ids, mask)
    }

    // MARK: - Basic tokenization (lowercase, strip accents, split on punctuation)
    /// Converts the input text into basic word-level tokens.
    ///
    /// The text is lowercased, accents are removed, whitespace separates
    /// words, and punctuation is treated as a separate token.
    private func basicTokenise(_ text: String) -> [String] {
        let scalars = text
            .lowercased()
            .decomposedStringWithCanonicalMapping
            .unicodeScalars
            .filter { $0.properties.generalCategory != .nonspacingMark }

        var tokens: [String] = []
        var current = ""

        for scalar in scalars {
            let value = scalar.value

            if value == 0 || value == 0xFFFD { continue }

            if scalar.properties.isWhitespace {
                flush(&current, into: &tokens)
            }
            else if scalar.properties.generalCategory == .control {
                continue
            }
            else if isPunctuation(scalar) {
                flush(&current, into: &tokens)
                tokens.append(String(scalar))
            }
            else {
                current.unicodeScalars.append(scalar)
            }
        }

        flush(&current, into: &tokens)
        return tokens
    }

    /// Adds the current partially-built token to the token list
    /// and resets the current token.
    private func flush(_ current: inout String, into tokens: inout [String]) {
        if !current.isEmpty {
            tokens.append(current)
            current = ""
        }
    }

    /// Checks if a character is punctuation, such as a comma, bracket, dash, or quotation mark.
    private func isPunctuation(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        if (33...47).contains(v) || (58...64).contains(v) || (91...96).contains(v) || (123...126).contains(v) {
            return true
        }
        switch scalar.properties.generalCategory {
        case .connectorPunctuation, .dashPunctuation, .openPunctuation, .closePunctuation,
             .initialPunctuation, .finalPunctuation, .otherPunctuation:
            return true
        default:
            return false
        }
    }

    /// Converts a basic token into one or more WordPiece vocabulary IDs.
    ///
    /// WordPiece uses a greedy longest-match-first approach.
    /// If a whole word is not in the vocabulary,
    /// it attempts to split the word into smaller pieces.
    private func wordPiece(_ word: String) -> [Int32] {
        let chars = Array(word.unicodeScalars)
        
        // Very long words are treated as unknown
        if chars.count > 100 { return [unkID] }

        var ids: [Int32] = []
        var start = 0

        while start < chars.count {
            var end = chars.count
            var found: Int32?

            // Gradually shorten the substring until a vocabulary entry is found
            while start < end {
                var piece = String(String.UnicodeScalarView(chars[start..<end]))
                
                // WordPiece uses "##" to indicate a continuation of a previous word piece.
                if start > 0 {
                    piece = "##" + piece
                }

                if let id = vocab[piece] {
                    found = id
                    break
                }
                end -= 1
            }

            // If no valid WordPiece can be found, represent the
            // entire word using the unknown token.
            guard let id = found else { return [unkID] }
            
            ids.append(id)
            start = end
        }

        return ids
    }
}

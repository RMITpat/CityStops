//
//  WordPieceTokenizer.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


import Foundation
import CoreML

/// BERT-style (uncased) WordPiece tokenizer. Matches the tokenizer used by all-MiniLM-L6-v2.
/// Requires `vocab.txt` from the model folder to be added to your Xcode target.
struct WordPieceTokenizer {

    let maxLength: Int

    private let vocab: [String: Int32]
    private let clsID: Int32
    private let sepID: Int32
    private let unkID: Int32
    private let padID: Int32 = 0

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

    /// Returns padded `input_ids` and `attention_mask`, each exactly `maxLength` long.
    func encode(_ text: String) -> (ids: [Int32], mask: [Int32]) {
        var ids: [Int32] = [clsID]

        for word in basicTokenize(text) {
            ids += wordPiece(word)
            if ids.count >= maxLength - 1 { break }
        }

        ids = Array(ids.prefix(maxLength - 1))
        ids.append(sepID)

        let realCount = ids.count
        let padding = maxLength - realCount

        let mask = [Int32](repeating: 1, count: realCount) + [Int32](repeating: 0, count: padding)
        ids += [Int32](repeating: padID, count: padding)

        return (ids, mask)
    }

    // MARK: - Basic tokenization (lowercase, strip accents, split on punctuation)

    private func basicTokenize(_ text: String) -> [String] {
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
            } else if scalar.properties.generalCategory == .control {
                continue
            } else if isPunctuation(scalar) || isCJK(scalar) {
                flush(&current, into: &tokens)
                tokens.append(String(scalar))
            } else {
                current.unicodeScalars.append(scalar)
            }
        }

        flush(&current, into: &tokens)
        return tokens
    }

    private func flush(_ current: inout String, into tokens: inout [String]) {
        if !current.isEmpty {
            tokens.append(current)
            current = ""
        }
    }

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

    private func isCJK(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (0x4E00...0x9FFF).contains(v)
            || (0x3400...0x4DBF).contains(v)
            || (0x20000...0x2A6DF).contains(v)
            || (0xF900...0xFAFF).contains(v)
            || (0x2F800...0x2FA1F).contains(v)
    }

    // MARK: - WordPiece (greedy longest-match-first)

    private func wordPiece(_ word: String) -> [Int32] {
        let chars = Array(word.unicodeScalars)
        if chars.count > 100 { return [unkID] }

        var ids: [Int32] = []
        var start = 0

        while start < chars.count {
            var end = chars.count
            var found: Int32?

            while start < end {
                var piece = String(String.UnicodeScalarView(chars[start..<end]))
                if start > 0 { piece = "##" + piece }

                if let id = vocab[piece] {
                    found = id
                    break
                }
                end -= 1
            }

            guard let id = found else { return [unkID] }
            ids.append(id)
            start = end
        }

        return ids
    }
}

extension WordPieceTokenizer {

    /// Tokenizes `text` and wraps the result in the Core ML input type.
    @available(macOS 13.0, iOS 16.0, *)
    func makeInput(_ text: String) -> MiniLMInput {
        let (ids, mask) = encode(text)
        let shape = [1, maxLength]

        return MiniLMInput(
            input_ids: MLShapedArray<Int32>(scalars: ids, shape: shape),
            attention_mask: MLShapedArray<Int32>(scalars: mask, shape: shape)
        )
    }
}

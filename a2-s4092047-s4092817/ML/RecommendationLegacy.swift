////
////  RecommendationLegacy.swift
////  a2-s4092047-s4092817
////
////  Created by Riley Tran on 8/10/2026.
////
//
//import Combine
//import Foundation
//import CoreML
//
//
//// ViewModel: Handles interaction between SwiftUI View and Core ML model.
//// Uses Combine (@Published) to notify the View when new suggestions are ready.
//final class RecommendationLegacy: ObservableObject {
//    
//    // MARK: - Properties
//    
//    // The Core ML model auto-generated from NextWord.mlmodel
//    private let model: MiniLM
//    
//    // The list of predicted next-word suggestions shown in the UI
//    @Published var suggestions: [String] = []
//    
//    // A background queue to run ML inference off the main thread (prevents UI freezing)
//    private let mlQueue = DispatchQueue(label: "ml.minilm.queue", qos: .userInitiated)
//    
//    // Used to debounce predictions (cancel older tasks if user keeps typing fast)
//    private var pendingWorkItem: DispatchWorkItem?
//    
//    private var tokeniser: WordPieceTokenizer
//    
//    
//    // MARK: - Init
//    
//    // Load the Core ML model into memory when ViewModel starts
//    init() {
//        do {
//            model = try MiniLM(configuration: .init())
//
//            guard let vocabURL = Bundle.main.url(
//                forResource: "vocab",
//                withExtension: "txt"
//            ) else {
//                fatalError("vocab.txt not found in app bundle")
//            }
//
//            tokeniser = try WordPieceTokenizer(vocabURL: vocabURL)
//
//        } catch {
//            fatalError("Failed to initialise ML model: \(error)")
//        }
//    }
//    
//    
//    // MARK: - Core prediction logic
//    
//    /// Schedule a prediction call after a small delay (debounce),
//    /// so we don’t re-run the model on every keystroke instantly.
//    func schedulePredict(context: String, topN: Int = 5) {
//        // Cancel any pending prediction work (user typed again)
//        pendingWorkItem?.cancel()
//        
//        do {
//            // Ask Core ML to predict the next word based on typed text
//            let out = try self.model.prediction(input: tokeniser.makeInput(context))
//            
//            // Extract the probability dictionary of candidate words
//            // (handles both old and new Create ML output names)
//            let probs = RecommendationViewModel.extractProbabilities(from: out)
//            
//            // Sort by descending probability, take top N, and remove blanks
//            let top = probs
//                .sorted { $0.value > $1.value }
//                .prefix(topN)
//                .map { $0.key }
//                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//            
//            // Update published suggestions on the main thread
//            DispatchQueue.main.async { self.suggestions = top }
//        } catch {
//            // If anything fails (model missing, invalid input, etc.)
//            DispatchQueue.main.async { self.suggestions = [] }
//            print("Prediction error:", error)
//        }
//}
//
//    
//    
//    // MARK: - Helper Methods
//    
//    /// Extracts prediction probabilities from the model output.
//    /// Some Core ML models use `labelProbability`, others use `classLabelProbs`.
//    private static func extractProbabilities(from out: MiniLMOutput) -> [String: Double] {
//        // Try modern Create ML property
//        if let dict = out.featureValue(for: "labelProbability")?.dictionaryValue {
//            return toSwiftDict(dict)
//        }
//        // Try older Create ML property
//        if let dict = out.featureValue(for: "classLabelProbs")?.dictionaryValue {
//            return toSwiftDict(dict)
//        }
//        
//        // If the model only gives the single top label, wrap it as a 1.0-probability dict
//        if let best = out.featureValue(for: "label")?.stringValue {
//            return [best: 1.0]
//        }
//        if let best = out.featureValue(for: "classLabel")?.stringValue {
//            return [best: 1.0]
//        }
//        
//        // No predictions found
//        return [:]
//    }
//    
//    /// Converts Core ML’s dictionary type (AnyHashable → NSNumber)
//    /// into a plain Swift dictionary (String → Double)
//    private static func toSwiftDict(_ dict: [AnyHashable: NSNumber]) -> [String: Double] {
//        var result: [String: Double] = [:]
//        for (k, v) in dict {
//            if let ks = k as? String {
//                result[ks] = v.doubleValue
//            }
//        }
//        return result
//    }
//}

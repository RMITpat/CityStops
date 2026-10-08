//
//  RecommendationView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


//
//  RecommendationView.swift
//  a2-s4092047-s4092817
//

import SwiftUI

// Demonstrates RecommendationViewModel: type something and the candidate
// strings most related to it appear, ranked best-first, as you type.
struct RecommendationView: View {

    @StateObject private var viewModel = RecommendationViewModel()

    @State private var text = ""
    @State private var topN = 3

    // Replace with your own data.
    private let items = [
        "Cozy Italian trattoria with handmade pasta",
        "Rooftop bar with city skyline views",
        "Specialty coffee roaster and brunch café",
        "Fine dining degustation menu",
        "Family-friendly pizza place",
        "Vegan café with smoothie bowls",
        "Fast food burger chain",
        "Late-night ramen bar",
        "Beachside fish and chips shop",
        "Hiking trail with a waterfall",
        "Art gallery with modern sculpture",
        "Car repair and tyre service"
    ]

    var body: some View {
        NavigationStack {
            List {

                // MARK: Input
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Describe what you're looking for…", text: $text)
                            .autocorrectionDisabled()

                        if !text.isEmpty {
                            Button {
                                text = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                    }

                    Stepper("Show top \(topN)", value: $topN, in: 1...items.count)
                } footer: {
                    Text("Results update as you type. Try “somewhere to get coffee” or “fix my car”.")
                }

                // MARK: Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                // MARK: Suggestions
                if !viewModel.suggestions.isEmpty {
                    Section("Most related") {
                        ForEach(Array(viewModel.suggestions.enumerated()), id: \.element) { index, suggestion in
                            HStack(spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(index == 0 ? Color.accentColor : Color.gray, in: Circle())

                                Text(suggestion)
                            }
                        }
                    }
                }

                // MARK: Candidate pool
                Section("Candidate pool (\(items.count))") {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .foregroundStyle(viewModel.suggestions.contains(item) ? .primary : .secondary)
                    }
                }
            }
            .navigationTitle("Recommendations")
            .onAppear {
                viewModel.setCandidates(items)
            }
            .onChange(of: text) { newValue in
                viewModel.schedulePredict(context: newValue, topN: topN)
            }
            .onChange(of: topN) { _ in
                viewModel.schedulePredict(context: text, topN: topN)
            }
        }
    }
}

#Preview {
    RecommendationView()
}
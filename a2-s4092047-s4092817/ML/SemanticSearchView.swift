//
//  SemanticSearchView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 8/10/2026.
//


import SwiftUI

struct SemanticSearchView: View {

    @StateObject private var viewModel = SemanticSearchViewModel()

    @State private var inputs: [String] = ["A nice restaurant in Melbourne"]
    @State private var newInput = ""
    @State private var topK = 3
    @State private var candidateText = """
    Cozy Italian trattoria with handmade pasta
    Rooftop bar with city skyline views
    Specialty coffee roaster and brunch café
    Fine dining degustation menu
    Family-friendly pizza place
    Vegan café with smoothie bowls
    Fast food burger chain
    Late-night ramen bar
    Beachside fish and chips shop
    Hiking trail with a waterfall
    Art gallery with modern sculpture
    Car repair and tyre service
    """

    private var candidates: [String] {
        candidateText.components(separatedBy: .newlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Input texts") {
                    ForEach(inputs, id: \.self) { Text($0) }
                        .onDelete { inputs.remove(atOffsets: $0) }

                    HStack {
                        TextField("Add a text…", text: $newInput)
                            .onSubmit(addInput)
                        Button(action: addInput) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .buttonStyle(.borderless)
                        .disabled(newInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Candidates (one per line)") {
                    TextEditor(text: $candidateText)
                        .frame(minHeight: 160)
                        .font(.callout)
                }

                Section {
                    Stepper("Return top \(topK)", value: $topK, in: 1...20)

                    Button {
                        Task { await viewModel.findRelated(to: inputs, in: candidates, topK: topK) }
                    } label: {
                        HStack {
                            Text("Find related")
                            if viewModel.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(inputs.isEmpty || viewModel.isLoading)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }

                if !viewModel.matches.isEmpty {
                    Section("Most related") {
                        ForEach(viewModel.matches) { match in
                            HStack {
                                Text(match.text)
                                Spacer()
                                Text(match.score, format: .number.precision(.fractionLength(3)))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Semantic Match")
        }
    }

    private func addInput() {
        let trimmed = newInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !inputs.contains(trimmed) else { return }
        inputs.append(trimmed)
        newInput = ""
    }
}

#Preview {
    SemanticSearchView()
}
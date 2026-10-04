//
//  GestureView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI

struct GestureView: View {

    @State private var viewModel = GestureViewModel()
    @GestureState private var gestureState = complexGestureState.inactive

    var body: some View {

        ZStack {

            // Original background
            Color(.systemBackground)
                .ignoresSafeArea()

            // Original content
            VStack {
                Text("hello")

                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        viewModel.showFailure
                        ? .red
                        : viewModel.swipeDirection != nil
                            ? .green
                            : .blue
                    )
                    .frame(width: 200, height: 120)
            }

            // Overlay layer
            if gestureState.isLongPressComplete {
                GestureOverlay()
            }
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: gestureState.isLongPressComplete
        )
        .contentShape(Rectangle())
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .sequenced(
                    before: DragGesture(minimumDistance: 0)
                )
                .updating($gestureState) { value, state, _ in

                    switch value {

                    case .first(true):
                        state = .pressing

                    case .second(true, let drag):

                        let translation = drag?.translation ?? .zero

                        state = .dragging(
                            translation: translation
                        )

                        viewModel.updateDrag(
                            translation: translation
                        )

                    default:
                        break
                    }
                }
                .onEnded { _ in
                    viewModel.endGesture()
                }
        )
    }
}

#Preview {
    GestureView()
}

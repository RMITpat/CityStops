//
//  GestureView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI

struct GestureView: View {
 
    @State private var viewModel = GestureViewModel()
    @GestureState private var gestureState = ComplexGestureState.inactive
 
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
 
            VStack {
                Text("hello")
 
                RoundedRectangle(cornerRadius: 20)
                    .fill(viewModel.feedback.color)
                    .frame(width: 200, height: 120)
            }
 
            if gestureState.isLongPressComplete {
                GestureOverlay()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gestureState.isLongPressComplete)
        .contentShape(Rectangle())
        .gesture(longPressThenDrag)
    }
 
    // MARK: - Gesture
    private var longPressThenDrag: some Gesture {
        LongPressGesture(minimumDuration:               viewModel.longPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 0))
            
            // Detect the gesture state (pressing, dragging)
            .updating($gestureState) { value, state, _ in
                switch value {
                    case .first(true):
                        state = .pressing
                    case .second(true, let drag):
                        state = .dragging(translation: drag?.translation ?? .zero)
                    default:
                        break
                }
            }
        
            // Update swiping translation to gestureVM
            .onChanged { value in
                if case .second(true, let drag?) = value {
                    viewModel.updateDragDirection(translation: drag.translation)
                }
            }
        
            .onEnded { _ in
                viewModel.endGesture()
            }
    }
}
 
// MARK: - Presentation mapping
 
private extension GestureViewModel.Feedback {
    var color: Color {
        switch self {
        case .idle: .blue
        case .swiping: .green
        case .success: .red
        }
    }
}

#Preview {
    GestureView()
}

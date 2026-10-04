//
//  GestureViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI
import Observation
 
@MainActor
@Observable
final class GestureViewModel {
 
    /// Single source of truth for what the UI should show.
    enum Feedback: Equatable {
        case idle
        case swiping(SwipeDirection)
        case success
    }
 
    // MARK: - Fixed gesture configuration values
    /// The distance that the user must swipe horizontally in any direction for successful gesture execution.
    let swipeThreshold: CGFloat = 50
    /// The duration that the user must pressed for successful gesture execution.
    let longPressDuration: TimeInterval = 0.5
    
    private let successDisplayDuration: Duration = .seconds(1)
 
    // MARK: - States
    /// Stores swipe direction of user.
    private(set) var swipeDirection: SwipeDirection?
    /// Stores successful gesture execution state.
    private var isShowingSuccess = false
    
    private var resetTask: Task<Void, Never>?
 
    /// Used to control view elements changing based on gesture stage.
    var feedback: Feedback {
        if isShowingSuccess { return .success }
        if let swipeDirection { return .swiping(swipeDirection) }
        return .idle
    }
 
    // MARK: - Intents
    
    /// determines whether the user is dragging left or right.
    func updateDragDirection(translation: CGSize) {
        clearSuccess()
 
        if translation.width <= -swipeThreshold {
            swipeDirection = .left
        } else if translation.width >= swipeThreshold {
            swipeDirection = .right
        } else {
            swipeDirection = nil
        }
    }
 
    /// runs when the user lets go of the screen while performing the gesture.
    func endGesture() {
        let didSwipe = swipeDirection != nil
        swipeDirection = nil
 
        guard didSwipe else { return }
 
        isShowingSuccess = true
        resetTask = Task { [weak self, successDisplayDuration] in
            try? await Task.sleep(for: successDisplayDuration)
            guard !Task.isCancelled else { return }
            self?.isShowingSuccess = false
        }
    }
 
    // MARK: - Private
    /// clears states after a successful gesture execution.
    private func clearSuccess() {
        resetTask?.cancel()
        resetTask = nil
        isShowingSuccess = false
    }
}

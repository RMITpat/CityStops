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

    // MARK: - Fixed gesture configuration values

    /// The distance that the user must swipe horizontally in any direction for successful gesture execution.
    let swipeThreshold: CGFloat = 100
    /// The duration that the user must press for successful gesture execution.
    let longPressDuration: TimeInterval = 0.5

    // MARK: - States

    /// Direction the finger is currently moving, set as soon as there is any movement.
    private(set) var swipeDirection: SwipeDirection?
    /// How far the user has swiped toward the threshold, from 0 to 1.
    private(set) var swipeProgress: CGFloat = 0
    /// Called when the user releases the gesture after reaching the threshold.
    var onSuccessfulSwipe: ((SwipeDirection) -> Void)?

    /// True once the user has swiped far enough that releasing will execute the gesture.
    var isArmed: Bool { swipeProgress >= 1 }

    // MARK: - Intents

    /// Determines whether the user is dragging left or right, and how close they are
    /// to the threshold required to execute the gesture.
    func updateDragDirection(translation: CGSize) {
        let width = translation.width

        guard width != 0 else {
            swipeDirection = nil
            swipeProgress = 0
            return
        }

        swipeDirection = width < 0 ? .left : .right
        swipeProgress = min(abs(width) / swipeThreshold, 1)
    }

    /// Runs when the user lets go of the screen while performing the gesture.
    /// Only executes the action if the threshold was reached.
    func endGesture() {
        let direction = swipeDirection
        let armed = isArmed

        swipeDirection = nil
        swipeProgress = 0

        guard armed, let direction else { return }
        onSuccessfulSwipe?(direction)
    }
}

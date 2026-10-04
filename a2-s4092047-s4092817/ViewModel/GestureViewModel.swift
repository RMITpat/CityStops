//
//  GestureViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI
import Observation



/// e
@Observable

final class GestureViewModel {

    let swipeThreshold: CGFloat = 50

    var swipeDirection: SwipeDirection?
    var showFailure = false

    func updateDrag(translation: CGSize) {
        if translation.width <= -swipeThreshold {
            swipeDirection = .left
        } else if translation.width >= swipeThreshold {
            swipeDirection = .right
        } else {
            swipeDirection = nil
        }
    }

    func endGesture() {
        let didSwipe = swipeDirection != nil

        swipeDirection = nil

        guard didSwipe else {
            return
        }

        showFailure = true

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            self?.showFailure = false
        }
    }
}

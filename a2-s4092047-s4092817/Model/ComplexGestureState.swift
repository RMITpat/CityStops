//
//  ComplexGestureState.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI

    /// ``enum`` that holds the sequential Gesture's current state.
    enum ComplexGestureState {
        case inactive
        case pressing
        case dragging(translation: CGSize)

        /// determines the translation from the gesture start point, to its current point.
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero

            case .dragging(let translation):
                return translation
            }
        }
        
        /// determines if the user is long pressing.
        var isLongPressComplete: Bool {
            switch self {
            // if dragging state has begun, the long pressing has already registered.
            case .dragging:
                return true

            case .inactive, .pressing:
                return false
            }
        }
    }

    /// ``enum`` defining the swipe direction of the sequential Gesture.
    enum SwipeDirection {
        case left
        case right
    }

import SwiftUI
import Observation

@Observable
final class GestureViewModel {

    // Distance the finger must move from the centre
    // before the block becomes green.
    let triggerDistance: CGFloat = 150

    // Whether the finger is currently far enough
    // left or right from the centre.
    var isTriggered = false

    // Whether the user has successfully triggered
    // the failure state.
    var showFailure = false

    // Determines the colour the block should display.
    var blockColor: Color {
        if showFailure {
            return .red
        } else if isTriggered {
            return .green
        } else {
            return .blue
        }
    }

    // Called whenever the finger moves.
    func updateDrag(location: CGPoint, screenWidth: CGFloat) {

        let centreX = screenWidth / 2

        let distanceFromCentre = location.x - centreX

        // Check whether the finger is far enough
        // to either the left OR right.
        isTriggered = abs(distanceFromCentre) >= triggerDistance
    }

    // Called when the user releases their finger.
    func endGesture() {

        // Check whether they released while
        // inside the trigger region.
        if isTriggered {
            showFailure = true
            isTriggered = false

            Task {
                try? await Task.sleep(for: .seconds(1))

                showFailure = false
            }
        } else {
            isTriggered = false
        }
    }
}
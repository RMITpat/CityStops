//
//  GestureOverlay.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 4/10/2026.
//

import SwiftUI

/// Overlay component used in ``CreateRouteView``, where user can do a custom
/// ``Gesture`` to exit the route creation flow, or delete all ``LocationCard`` in their list.
struct GestureOverlay: View {

    let vm: GestureViewModel

    var body: some View {

        ZStack {

            // MARK: - Overlay background

            Rectangle()
                .fill(.gray.opacity(0.5))
                .background(.ultraThinMaterial)
                .opacity(0.85)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // MARK: - Gesture action labels

            HStack {

                // MARK: Left action
                VStack(spacing: 8) {

                    Image(systemName: "arrow.left")
                        .font(.title)
                        .scaleEffect(
                            vm.swipeDirection == .left
                            ? 0.8 + (0.6 * vm.swipeProgress)
                            : 0.8
                        )

                    Text("""
                         Cancel trip
                         creation
                         """)
                        .multilineTextAlignment(.center)
                        .fontWeight(
                            vm.swipeDirection == .left && vm.swipeProgress >= 1
                            ? .bold
                            : .regular
                        )
                    // "Progress" bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {

                            Capsule()
                                .fill(.secondary.opacity(0.3))

                            Capsule()
                                .fill(.primary)
                            // Show progress only when swipe is significant enough; UX feels better
                                .frame(
                                    width: geometry.size.width * (
                                        (vm.swipeDirection == .left
                                        && vm.swipeProgress >= 0.2)
                                        ? vm.swipeProgress
                                        : 0
                                    )
                                )
                            // Animation for smoothness when appearing
                                .animation(
                                    .linear(duration: 0.05),
                                    value: vm.swipeProgress
                                )
                        }
                    }
                    .frame(width: 80, height: 6)
                }

                Spacer()

                // MARK: Right action

                VStack(spacing: 8) {

                    Image(systemName: "arrow.right")
                        .font(.title)
                        .scaleEffect(
                            vm.swipeDirection == .right
                            ? 0.8 + (0.6 * vm.swipeProgress)
                            : 0.8
                        )

                    Text("""
                         Clear all
                         locations
                         """)
                        .multilineTextAlignment(.center)
                        .fontWeight(
                            vm.swipeDirection == .right && vm.swipeProgress >= 1
                            ? .bold
                            : .regular
                        )
                    // "Progress" bar
                    GeometryReader { geometry in

                        ZStack(alignment: .trailing) {

                            Capsule()
                                .fill(.secondary.opacity(0.3))

                            Capsule()
                                .fill(.primary)
                            // Show progress only when swipe is significant enough; UX feels better
                                .frame(
                                    width: geometry.size.width * (
                                        (vm.swipeDirection == .right
                                        && vm.swipeProgress >= 0.2)
                                        ? vm.swipeProgress
                                        : 0
                                    )
                                )
                            // Animation for smoothness when appearing
                                .animation(
                                    .linear(duration: 0.05),
                                    value: vm.swipeProgress
                                )
                        }
                    }
                    .frame(width: 80, height: 6)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    GestureOverlay(vm: GestureViewModel())
}


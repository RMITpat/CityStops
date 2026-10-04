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
    var body: some View {
        ZStack {
            
            // MARK: Overlay background
            Rectangle()
                .fill(.black.opacity(0.25))
                .background(.ultraThinMaterial)
                .opacity(0.75)
                .ignoresSafeArea()
                .transition(.opacity)
                .allowsHitTesting(false)
            
            // MARK: Gesture action labels
            HStack {
                Text("""
                     Cancel trip 
                     creation
                     """)
                .multilineTextAlignment(.center)
                
                Spacer()
                
                Text("""
                     Clear all
                     locations
                     """)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    GestureOverlay()
}

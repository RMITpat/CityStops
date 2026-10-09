//
//  BottomButtonFormat.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 1/10/2026.
//

import SwiftUI

/// Base ``ViewModifier`` for all Buttons.
struct ButtonFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .controlSize(.large)
            .buttonStyle(.glassProminent)
    }
}

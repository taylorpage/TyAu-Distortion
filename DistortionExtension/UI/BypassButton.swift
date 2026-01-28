//
//  BypassButton.swift
//  DistortionExtension
//
//  A bypass button with indicator light for audio effect bypass
//

import SwiftUI

struct BypassButton: View {
    @State var param: ObservableAUParameter

    let buttonSize: CGFloat = 60
    let indicatorSize: CGFloat = 12

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Button background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.6),
                                Color.gray.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                // Button label
                Text(param.boolValue ? "OFF" : "ON")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                // Indicator light (top-right corner)
                Circle()
                    .fill(param.boolValue ? Color.gray.opacity(0.3) : Color.green)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(
                        color: param.boolValue ? .clear : .green.opacity(0.8),
                        radius: param.boolValue ? 0 : 4,
                        x: 0,
                        y: 0
                    )
                    .offset(x: buttonSize / 3, y: -buttonSize / 3)
            }
            .onTapGesture {
                param.onEditingChanged(true)
                param.boolValue.toggle()
                param.onEditingChanged(false)
            }

            // Parameter name
            Text(param.displayName)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .accessibility(identifier: param.displayName)
    }
}

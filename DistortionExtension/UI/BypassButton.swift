//
//  BypassButton.swift
//  DistortionExtension
//
//  A stomp switch button for audio effect bypass
//

import SwiftUI

struct BypassButton: View {
    @State var param: ObservableAUParameter
    @State private var isPressed = false

    let switchSize: CGFloat = 70

    var body: some View {
        ZStack {
            // Base stomp mechanism (always visible)
            if let stompImage = NSImage(named: "stomp") {
                Image(nsImage: stompImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: switchSize, height: switchSize)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
            }

            // Stomp button (animated on press)
            if let stompButtonImage = NSImage(named: "stompButton") {
                Image(nsImage: stompButtonImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: switchSize * 0.88, height: switchSize * 0.88)
                    // Scale down and add slight vertical offset when pressed
                    .scaleEffect(isPressed ? 0.97 : 1.0)
                    .offset(y: isPressed ? 1.5 : 0)
                    .shadow(color: .black.opacity(isPressed ? 0.3 : 0.4),
                           radius: isPressed ? 2 : 4,
                           x: 0,
                           y: isPressed ? 1 : 2)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.05)) {
                        isPressed = false
                    }
                    // Toggle bypass state
                    param.onEditingChanged(true)
                    param.boolValue.toggle()
                    param.onEditingChanged(false)
                }
        )
        .accessibility(identifier: param.displayName)
    }
}

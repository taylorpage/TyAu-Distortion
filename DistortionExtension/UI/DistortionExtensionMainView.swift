//
//  DistortionExtensionMainView.swift
//  DistortionExtension
//
//  Created by Taylor Page on 1/22/26.
//

import SwiftUI

struct DistortionExtensionMainView: View {
    var parameterTree: ObservableAUParameterGroup

    var body: some View {
        ZStack {
            // Vintage pedal chassis background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.25, green: 0.28, blue: 0.27),
                            Color(red: 0.18, green: 0.21, blue: 0.20)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.4, green: 0.45, blue: 0.43), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)

            // White border inset (classic pedal look)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                .padding(12)

            VStack(spacing: 30) {
                // 9V Power indicator
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("9V")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Circle()
                            .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 6, height: 6)
                            )
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                }

                Spacer()

                // Drive knob with scale
                VStack(spacing: 10) {
                    ParameterKnob(param: parameterTree.global.drive)
                }

                Spacer()

                // Pedal branding
                VStack(spacing: 4) {
                    Text("DISTORTION")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(2)
                }

                Spacer()

                // Stomp switch and LED
                HStack(spacing: 40) {
                    // LED indicator
                    Circle()
                        .fill(param.boolValue ? Color(red: 0.3, green: 0.35, blue: 0.32) : Color.green)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.6), lineWidth: 2)
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            param.boolValue ? Color.clear : Color.white.opacity(0.6),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 10
                                    )
                                )
                        )
                        .shadow(
                            color: param.boolValue ? .clear : .green.opacity(0.8),
                            radius: param.boolValue ? 0 : 6,
                            x: 0,
                            y: 0
                        )

                    // Stomp switch
                    BypassButton(param: parameterTree.global.bypass)
                }
                .padding(.bottom, 20)

                // Location text
                Text("PORTLAND, OR")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 300, height: 500)
    }

    var param: ObservableAUParameter {
        parameterTree.global.bypass
    }
}

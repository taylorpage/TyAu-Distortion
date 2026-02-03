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
            // Red pedal chassis background - matches pizzaFuzz PNG exactly (RGB: 147, 40, 39)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 147/255, green: 40/255, blue: 39/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 167/255, green: 60/255, blue: 59/255), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)

            // Pizza Fuzz graphic - BACKGROUND IMAGE
            if let pizzaImage = NSImage(named: "pizzaFuzz") {
                Image(nsImage: pizzaImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 320, height: 350)
                    .clipped()
                    .offset(y: 40)
            }

            // White border inset (classic pedal look)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                .padding(12)

            VStack(spacing: 0) {
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
                .padding(.bottom, 20)

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
                    .padding(.bottom, 8)

                // Drive knob
                ParameterKnob(param: parameterTree.global.drive)
                    .padding(.bottom, 130)

                Spacer()

                // Centered stomp switch
                BypassButton(param: parameterTree.global.bypass)
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 280, height: 600)
    }

    var param: ObservableAUParameter {
        parameterTree.global.bypass
    }
}

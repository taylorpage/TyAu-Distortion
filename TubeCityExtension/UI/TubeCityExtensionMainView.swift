//
//  TubeCityExtensionMainView.swift
//  TubeCityExtension
//
//  Created by Taylor Page on 1/22/26.
//

import SwiftUI

struct TubeCityExtensionMainView: View {
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

            // Pizza Fuzz graphic - BACKGROUND IMAGE (clipped to white border area)
            if let pizzaImage = NSImage(named: "pizzaFuzz") {
                Image(nsImage: pizzaImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 350)
                    .offset(y: 60)
                    .padding(.horizontal, 12)
                    .clipped()
            }

            // Yellow border inset (matches Pizza Fuzz graphic)
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 234/255, green: 180/255, blue: 50/255), lineWidth: 2)
                .padding(12)

            // Output jack (left side) with vertical label
            HStack {
                HStack(spacing: 4) {
                    if let jackImage = NSImage(named: "jack") {
                        Image(nsImage: jackImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }
                    Text("OUTPUT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 234/255, green: 180/255, blue: 50/255))
                        .rotationEffect(.degrees(-90))
                        .fixedSize()
                }
                .offset(x: -21)
                Spacer()
            }
            .padding(.top, 20)

            // Input jack (right side) with vertical label
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("INPUT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 234/255, green: 180/255, blue: 50/255))
                        .rotationEffect(.degrees(-90))
                        .fixedSize()
                        .offset(x: -3)
                    if let jackImage = NSImage(named: "jack") {
                        Image(nsImage: jackImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                            .scaleEffect(x: -1, y: 1)
                            .offset(x: 3)
                    }
                }
                .offset(x: 18)
            }
            .padding(.top, 20)

            VStack(spacing: 0) {
                // 9V Power indicator (moved lower to avoid border)
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("9V")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 234/255, green: 180/255, blue: 50/255))
                        Circle()
                            .stroke(Color(red: 234/255, green: 180/255, blue: 50/255), lineWidth: 1.5)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .fill(Color(red: 234/255, green: 180/255, blue: 50/255))
                                    .frame(width: 6, height: 6)
                            )
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 8)

                // LED indicator
                ZStack {
                    // Main LED body
                    Circle()
                        .fill(param.boolValue ? Color(red: 0.3, green: 0.35, blue: 0.32) : Color.red)
                        .frame(width: 20, height: 20)

                    // Dark bezel/rim
                    Circle()
                        .stroke(Color.black.opacity(0.6), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    // Center glow (when on)
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
                        .frame(width: 20, height: 20)

                    // Glass reflection (top-left highlight)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.5), location: 0.0),
                                    .init(color: Color.white.opacity(0.2), location: 0.3),
                                    .init(color: Color.clear, location: 0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 20, height: 20)
                        .mask(
                            Circle()
                                .frame(width: 8, height: 8)
                                .offset(x: -3, y: -3)
                        )
                }
                .shadow(
                    color: param.boolValue ? .clear : .red.opacity(0.8),
                    radius: param.boolValue ? 0 : 6,
                    x: 0,
                    y: 0
                )
                .padding(.bottom, 8)

                // Drive knob
                ParameterKnob(param: parameterTree.global.drive)
                    .padding(.bottom, 145)

                Spacer()

                // Centered stomp switch
                BypassButton(param: parameterTree.global.bypass)
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 24)

            // TaylorAudio logo (bottom left corner)
            VStack {
                Spacer()
                HStack {
                    if let logoImage = NSImage(named: "TaylorAudio") {
                        Image(nsImage: logoImage)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    Spacer()
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 280, height: 600)
    }

    var param: ObservableAUParameter {
        parameterTree.global.bypass
    }
}

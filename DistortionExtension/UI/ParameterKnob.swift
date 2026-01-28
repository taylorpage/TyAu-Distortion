//
//  ParameterKnob.swift
//  DistortionExtension
//
//  A rotary knob control for AU parameters
//

import SwiftUI

struct ParameterKnob: View {
    @State var param: ObservableAUParameter

    @State private var isDragging = false
    @State private var lastDragValue: CGFloat = 0

    let knobSize: CGFloat = 80
    let strokeWidth: CGFloat = 8

    var specifier: String {
        switch param.unit {
        case .midiNoteNumber:
            return "%.0f"
        default:
            return "%.2f"
        }
    }

    // Convert parameter value (0-1 normalized) to angle
    var angle: Angle {
        let normalizedValue = (param.value - param.min) / (param.max - param.min)
        let startAngle: Double = -135 // Start at bottom-left (7 o'clock)
        let endAngle: Double = 135    // End at bottom-right (5 o'clock - 270 degrees of rotation)
        let angleRange = endAngle - startAngle
        return Angle(degrees: startAngle + (Double(normalizedValue) * angleRange))
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: strokeWidth)
                    .frame(width: knobSize, height: knobSize)

                // Value arc
                Circle()
                    .trim(from: 0, to: CGFloat((param.value - param.min) / (param.max - param.min)))
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .frame(width: knobSize, height: knobSize)
                    .rotationEffect(Angle(degrees: -135))

                // Knob body
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: knobSize - strokeWidth * 2, height: knobSize - strokeWidth * 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                // Indicator line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3, height: knobSize / 3)
                    .offset(y: -knobSize / 4)
                    .rotationEffect(angle)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            lastDragValue = gesture.translation.height
                            param.onEditingChanged(true)
                        }

                        // Vertical drag to control value
                        let delta = lastDragValue - gesture.translation.height
                        let sensitivity: CGFloat = 0.005
                        let valueChange = Float(delta * sensitivity) * (param.max - param.min)

                        let newValue = param.value + valueChange
                        param.value = min(max(newValue, param.min), param.max)

                        lastDragValue = gesture.translation.height
                    }
                    .onEnded { _ in
                        isDragging = false
                        param.onEditingChanged(false)
                    }
            )

            // Parameter name
            Text(param.displayName)
                .font(.caption)
                .foregroundColor(.primary)

            // Parameter value
            Text("\(param.value, specifier: specifier)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .accessibility(identifier: param.displayName)
    }
}

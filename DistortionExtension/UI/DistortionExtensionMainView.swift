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
        HStack(spacing: 40) {
            ParameterKnob(param: parameterTree.global.gain)
            ParameterKnob(param: parameterTree.global.tubeDrive)
        }
        .padding()
    }
}

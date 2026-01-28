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
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                ParameterKnob(param: parameterTree.global.drive)
                BypassButton(param: parameterTree.global.bypass)
            }
        }
        .padding()
    }
}

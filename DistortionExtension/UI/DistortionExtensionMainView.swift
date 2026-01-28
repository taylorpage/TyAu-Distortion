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
            ParameterKnob(param: parameterTree.global.drive)
        }
        .padding()
    }
}

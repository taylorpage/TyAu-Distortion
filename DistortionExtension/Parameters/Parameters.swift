//
//  Parameters.swift
//  DistortionExtension
//
//  Created by Taylor Page on 1/22/26.
//

import Foundation
import AudioToolbox

let DistortionExtensionParameterSpecs = ParameterTreeSpec {
    ParameterGroupSpec(identifier: "global", name: "Global") {
        ParameterSpec(
            address: .drive,
            identifier: "drive",
            name: "Drive",
            units: .percent,
            valueRange: 0.0...1.0,
            defaultValue: 0.5
        )
    }
}

extension ParameterSpec {
    init(
        address: DistortionExtensionParameterAddress,
        identifier: String,
        name: String,
        units: AudioUnitParameterUnit,
        valueRange: ClosedRange<AUValue>,
        defaultValue: AUValue,
        unitName: String? = nil,
        flags: AudioUnitParameterOptions = [AudioUnitParameterOptions.flag_IsWritable, AudioUnitParameterOptions.flag_IsReadable],
        valueStrings: [String]? = nil,
        dependentParameters: [NSNumber]? = nil
    ) {
        self.init(address: address.rawValue,
                  identifier: identifier,
                  name: name,
                  units: units,
                  valueRange: valueRange,
                  defaultValue: defaultValue,
                  unitName: unitName,
                  flags: flags,
                  valueStrings: valueStrings,
                  dependentParameters: dependentParameters)
    }
}

//
//  DistortionExtensionParameterAddresses.h
//  DistortionExtension
//
//  Created by Taylor Page on 1/22/26.
//

#pragma once

#include <AudioToolbox/AUParameters.h>

typedef NS_ENUM(AUParameterAddress, DistortionExtensionParameterAddress) {
    gain = 0,
    tubeDrive = 1
};

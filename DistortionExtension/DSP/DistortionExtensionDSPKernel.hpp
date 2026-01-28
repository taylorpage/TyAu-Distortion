//
//  DistortionExtensionDSPKernel.hpp
//  DistortionExtension
//
//  Created by Taylor Page on 1/22/26.
//

#pragma once

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>
#import <vector>
#import <span>

#import "DistortionExtensionParameterAddresses.h"

/*
 DistortionExtensionDSPKernel
 As a non-ObjC class, this is safe to use from render thread.
 */
class DistortionExtensionDSPKernel {
public:
    void initialize(int inputChannelCount, int outputChannelCount, double inSampleRate) {
        mSampleRate = inSampleRate;
    }
    
    void deInitialize() {
    }
    
    // MARK: - Bypass
    bool isBypassed() {
        return mBypassed;
    }
    
    void setBypass(bool shouldBypass) {
        mBypassed = shouldBypass;
    }
    
    // MARK: - Parameter Getter / Setter
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case DistortionExtensionParameterAddress::drive:
                mDrive = value;
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        // Return the goal. It is not thread safe to return the ramping value.

        switch (address) {
            case DistortionExtensionParameterAddress::drive:
                return (AUValue)mDrive;

            default: return 0.f;
        }
    }
    
    // MARK: - Max Frames
    AUAudioFrameCount maximumFramesToRender() const {
        return mMaxFramesToRender;
    }
    
    void setMaximumFramesToRender(const AUAudioFrameCount &maxFrames) {
        mMaxFramesToRender = maxFrames;
    }
    
    // MARK: - Musical Context
    void setMusicalContextBlock(AUHostMusicalContextBlock contextBlock) {
        mMusicalContextBlock = contextBlock;
    }
    
    /**
     MARK: - Internal Process
     
     This function does the core siginal processing.
     Do your custom DSP here.
     */
    void process(std::span<float const*> inputBuffers, std::span<float *> outputBuffers, AUEventSampleTime bufferStartTime, AUAudioFrameCount frameCount) {
        /*
         Note: For an Audio Unit with 'n' input channels to 'n' output channels, remove the assert below and
         modify the check in [DistortionExtensionAudioUnit allocateRenderResourcesAndReturnError]
         */
        assert(inputBuffers.size() == outputBuffers.size());
        
        if (mBypassed) {
            // Pass the samples through
            for (UInt32 channel = 0; channel < inputBuffers.size(); ++channel) {
                std::copy_n(inputBuffers[channel], frameCount, outputBuffers[channel]);
            }
            return;
        }
        
        // Use this to get Musical context info from the Plugin Host,
        // Replace nullptr with &memberVariable according to the AUHostMusicalContextBlock function signature
        /*
         if (mMusicalContextBlock) {
         mMusicalContextBlock(nullptr, 	// currentTempo
         nullptr, 	// timeSignatureNumerator
         nullptr, 	// timeSignatureDenominator
         nullptr, 	// currentBeatPosition
         nullptr, 	// sampleOffsetToNextBeat
         nullptr);	// currentMeasureDownbeatPosition
         }
         */
        
        // Perform per sample dsp on the incoming float in before assigning it to out
        for (UInt32 channel = 0; channel < inputBuffers.size(); ++channel) {
            for (UInt32 frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float input = inputBuffers[channel][frameIndex];

                // Apply pre-gain based on drive (1.0 to 10.0)
                float preGain = 1.0f + (mDrive * 9.0f);
                float sample = input * preGain;

                // Apply progressive clipping (soft → hard transition)
                float clipped;
                if (mDrive < 0.5f) {
                    // Soft clipping (tanh-based)
                    float softAmount = mDrive * 2.0f;  // 0.0 to 1.0
                    clipped = std::tanh(sample * (1.0f + softAmount));
                } else {
                    // Transition to hard clipping
                    float hardAmount = (mDrive - 0.5f) * 2.0f;  // 0.0 to 1.0
                    float threshold = 1.0f - (hardAmount * 0.3f);  // 1.0 to 0.7

                    // Hard clip
                    if (sample > threshold) {
                        clipped = threshold;
                    } else if (sample < -threshold) {
                        clipped = -threshold;
                    } else {
                        clipped = std::tanh(sample);
                    }
                }

                // Apply makeup gain to compensate for clipping
                float makeupGain = 1.0f / (1.0f + mDrive * 0.5f);
                float output = clipped * makeupGain;

                outputBuffers[channel][frameIndex] = output;
            }
        }
    }
    
    void handleOneEvent(AUEventSampleTime now, AURenderEvent const *event) {
        switch (event->head.eventType) {
            case AURenderEventParameter: {
                handleParameterEvent(now, event->parameter);
                break;
            }
                
            default:
                break;
        }
    }
    
    void handleParameterEvent(AUEventSampleTime now, AUParameterEvent const& parameterEvent) {
        setParameter(parameterEvent.parameterAddress, parameterEvent.value);
    }
    
    // MARK: Member Variables
    AUHostMusicalContextBlock mMusicalContextBlock;

    double mSampleRate = 44100.0;
    float mDrive = 0.5f;  // 0.0 to 1.0
    bool mBypassed = false;
    AUAudioFrameCount mMaxFramesToRender = 1024;
};

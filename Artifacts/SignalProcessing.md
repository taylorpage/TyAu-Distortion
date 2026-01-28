# TyAu-Distortion Signal Processing Documentation

This document describes the complete signal processing chain and design decisions for the TyAu-Distortion audio plugin.

## Signal Flow Overview

```
Input Signal
    ↓
[Pre-Distortion EQ] - High-pass filter at 75Hz
    ↓
[Pre-Gain] - Drive-dependent gain (1x to 6x)
    ↓
[2x Oversampling - Upsample] - Linear interpolation
    ↓
[Hard Clipping] - Asymmetric threshold limiting
    ↓
[2x Oversampling - Downsample] - Averaging + DC blocker
    ↓
[Makeup Gain] - Drive-compensated output level
    ↓
Output Signal
```

## 1. Pre-Distortion EQ

**Purpose:** Shape the frequency content before it hits the distortion stage

**Implementation:**
- **Type:** 2nd-order Butterworth high-pass filter
- **Frequency:** 75Hz
- **Q:** 0.707 (critically damped)
- **Processing:** Biquad IIR filter, per-channel state

**Why:**
- Removes low-frequency rumble and mud before distortion
- Prevents flabby bass from eating up headroom
- Creates tighter, more focused distortion character
- Modeled after natural guitar amp frequency response

**Filter Coefficients:**
```
fc = 75Hz / sampleRate
w0 = 2π × fc
α = sin(w0) / (2 × Q)

b0 = (1 + cos(w0)) / 2
b1 = -(1 + cos(w0))
b2 = (1 + cos(w0)) / 2
a0 = 1 + α
a1 = -2 × cos(w0)
a2 = 1 - α

All coefficients normalized by a0
```

## 2. Pre-Gain Stage

**Purpose:** Control distortion intensity

**Implementation:**
```cpp
preGain = 1.0 + (drive × 5.0)
// Maps drive (0.4-1.0) to gain (3.0x-6.0x)
```

**Drive Range:**
- Minimum: 40% → 3.0x gain
- Maximum: 100% → 6.0x gain
- Default: 70% → 4.5x gain

**Why restricted range:**
- Below 40% drive produces weak, unusable distortion
- Starting at 40% ensures consistent, quality distortion character
- User experience: knob only covers the "sweet spot"

## 3. 2x Oversampling

**Purpose:** Reduce aliasing artifacts from non-linear distortion

### Upsampling (1 sample → 2 samples)

**Method:** Linear interpolation
```cpp
out1 = current_sample
out2 = (current_sample + previous_sample) × 0.5
```

**Why linear interpolation:**
- Simple and efficient
- Low CPU overhead
- Sufficient for 2x oversampling
- Maintains phase relationships

### Downsampling (2 samples → 1 sample)

**Method:** Averaging with DC blocking
```cpp
downsampled = (sample1 + sample2) × 0.5

// DC blocker (1st-order high-pass at ~5Hz)
output = downsampled - z1 + 0.995 × previous_output
z1 = downsampled
```

**Why DC blocker:**
- Asymmetric clipping can introduce DC offset
- High-pass at 5Hz removes DC without affecting audio
- Prevents speaker cone drift and downstream issues

**Per-Channel State:**
- All oversampling state variables are per-channel (8 channel support)
- Prevents crosstalk between stereo channels
- Essential for independent left/right processing

## 4. Hard Clipping Algorithm

**Type:** Asymmetric hard threshold limiting

**Implementation:**
```cpp
positiveThreshold = 0.8 - (drive × 0.55)  // 0.58 to 0.25
negativeThreshold = 0.9 - (drive × 0.55)  // 0.68 to 0.35

if (sample > positiveThreshold)
    return positiveThreshold
else if (sample < -negativeThreshold)
    return -negativeThreshold
else
    return sample
```

**Asymmetry:**
- Positive peaks clip earlier and harder (creates bite)
- Negative peaks clip later (adds warmth)
- Generates even-order harmonics for richer tone

**Why hard clipping:**
- Crisp, aggressive character
- No soft-knee artifacts at low drive levels
- Predictable, consistent behavior
- Oversampling smooths the edges

**Design Evolution:**
1. Started with soft clipping (tanh) → too grungy
2. Tried hybrid soft/hard → volume jumps at transitions
3. Settled on pure hard clip → clean, artifact-free

## 5. Makeup Gain

**Purpose:** Compensate for volume reduction from clipping

**Implementation:**
```cpp
makeupGain = 1.0 / (1.0 + drive × 0.5)
```

**Behavior:**
- At 40% drive: ~1.17x makeup gain
- At 70% drive: ~1.28x makeup gain
- At 100% drive: ~1.33x makeup gain

**Why:**
- Maintains consistent perceived loudness across drive range
- Prevents volume drop when increasing drive
- Smooth, progressive compensation curve

## Technical Specifications

### Performance
- **Sample Rate:** Independent (initialized per-instance)
- **Channel Support:** Mono (1→1), Stereo (2→2), up to 8 channels
- **Max Frame Count:** 1024 frames per render block
- **In-Place Processing:** Supported
- **Thread Safety:** Real-time safe (no allocations, locks, or blocking)

### Latency
- **Additional Latency:** 0 samples
- 2x oversampling is internal buffering only
- No lookahead or delay compensation needed

### CPU Usage
- Extremely efficient
- Simple algorithms optimized for real-time
- Per-sample processing, no FFT or convolution

## Frequency Response Characteristics

### Pre-Distortion EQ
- **75Hz:** -3dB
- **50Hz:** ~-7dB
- **30Hz:** ~-15dB
- **100Hz+:** Flat (0dB)

### Overall Character
- **Low End:** Tight and focused (75Hz HPF)
- **Midrange:** Punchy with harmonic richness (asymmetric clipping)
- **High End:** Crisp and clear (oversampling prevents aliasing)

## Design Philosophy

1. **Simplicity:** Each stage has a single, well-defined purpose
2. **Quality:** Oversampling ensures smooth, professional sound
3. **Artifact-Free:** Pure hard clipping eliminates soft-knee transitions
4. **Musical:** Asymmetric clipping adds harmonic complexity
5. **User-Focused:** Drive range restricted to usable sweet spot (40-100%)

## Future Enhancements

Potential additions (not implemented):
- Adjustable pre-distortion EQ
- Mix/blend control (dry/wet)
- Multiple distortion modes (switchable algorithms)
- Post-distortion tone controls
- 4x oversampling option for even smoother response

---

**Last Updated:** January 27, 2026
**Version:** 1.0
**Author:** Taylor Page with Claude Sonnet 4.5

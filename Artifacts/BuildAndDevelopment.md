# TyAu-Distortion Build and Development Guide

This document contains essential information for building, testing, and developing the TyAu-Distortion audio plugin.

## Project Location

**Repository Root:** `/Users/taylorpage/Repos/TyAu/TyAu-Pedals/TyAu-Distortion/`

**Xcode Project:** `Distortion.xcodeproj`

## Build Instructions

### Building from Command Line

The project must be built in **Debug** configuration for Logic Pro to pick up changes during development.

```bash
cd /Users/taylorpage/Repos/TyAu/TyAu-Pedals/TyAu-Distortion
xcodebuild -project Distortion.xcodeproj -scheme Distortion -configuration Debug build
```

For Release builds:
```bash
xcodebuild -project Distortion.xcodeproj -scheme Distortion -configuration Release build
```

### Build Output Locations

**Debug Build:**
```
/Users/taylorpage/Library/Developer/Xcode/DerivedData/Distortion-fyljndefnpmzoddtiipblczwgard/Build/Products/Debug/Distortion.app
```

**Audio Unit Extension (Debug):**
```
/Users/taylorpage/Library/Developer/Xcode/DerivedData/Distortion-fyljndefnpmzoddtiipblczwgard/Build/Products/Debug/Distortion.app/Contents/PlugIns/DistortionExtension.appex
```

**Release Build:**
```
/Users/taylorpage/Library/Developer/Xcode/DerivedData/Distortion-fyljndefnpmzoddtiipblczwgard/Build/Products/Release/Distortion.app
```

## Development Workflow

### Testing in Logic Pro

1. **Initial Setup:**
   - Build the Debug configuration
   - Launch `Distortion.app` to register the Audio Unit extension
   - Open Logic Pro
   - The plugin will appear as "Distortion" under Audio Units

2. **Making Changes:**
   - Edit source files (Swift, C++, etc.)
   - Rebuild in Debug configuration
   - Logic Pro will typically crash or reload when the plugin binary is overwritten
   - If Logic doesn't auto-reload, close and reopen the plugin window or restart Logic

3. **Plugin Registration:**
   The plugin is registered with the system via `pluginkit`. Check registration:
   ```bash
   pluginkit -m -v 2>&1 | grep -i distortion
   ```

### Important Files and Directories

**UI Components:**
- `DistortionExtension/UI/ParameterKnob.swift` - Rotary knob control
- `DistortionExtension/UI/DistortionExtensionMainView.swift` - Main plugin UI
- `DistortionExtension/UI/ParameterSlider.swift` - Slider control

**Audio Processing:**
- `DistortionExtension/Common/Audio Unit/DistortionExtensionAudioUnit.swift` - Audio Unit wrapper
- DSP implementation (C++) - Signal processing chain

**Parameters:**
- `DistortionExtension/Parameters/Parameters.swift` - Plugin parameters definition

## Project Structure

```
TyAu-Pedals/TyAu-Distortion/
├── Artifacts/                          # Documentation and design files
│   ├── SignalProcessing.md            # DSP implementation details
│   └── BuildAndDevelopment.md         # This file
├── Distortion/                         # Host application
│   ├── DistortionApp.swift
│   ├── ContentView.swift
│   ├── ValidationView.swift
│   └── Common/                         # Shared utilities
├── DistortionExtension/               # Audio Unit Extension (the plugin)
│   ├── UI/                            # SwiftUI interface
│   ├── Common/                        # Core AU implementation
│   └── Parameters/                    # Parameter definitions
└── Distortion.xcodeproj               # Xcode project
```

## Key Information

### Bundle Identifiers
- **App:** `com.taylor.audio.Distortion`
- **Extension:** `com.taylor.audio.Distortion.DistortionExtension`

### Audio Unit Type
- **Type:** Effect (aufx)
- **Subtype:** Custom distortion
- **Manufacturer:** Taylor Audio

### Parameter Ranges
- **Drive:** 0.4 to 1.0 (40% to 100%)
  - Default: 0.7 (70%)
  - Maps to 3.0x-6.0x internal gain

### Code Signing
- **Developer:** jontaylorpage@gmail.com
- **Team:** SWA5UWWQY7
- **Certificate:** Apple Development

## Common Tasks

### Force Plugin Refresh in Logic
```bash
# Kill Logic Pro
killall "Logic Pro"

# Clear plugin cache (if needed)
killall -9 AudioComponentRegistrar

# Rebuild and restart
cd /Users/taylorpage/Repos/TyAu/TyAu-Pedals/TyAu-Distortion
xcodebuild -project Distortion.xcodeproj -scheme Distortion -configuration Debug build
open /Users/taylorpage/Library/Developer/Xcode/DerivedData/Distortion-*/Build/Products/Debug/Distortion.app
```

### Check Build Logs
Build logs are saved when output is large. Look for:
```
~/.claude/projects/-Users-taylorpage-Repos-TyAu/*/tool-results/
```

### Clean Build
```bash
cd /Users/taylorpage/Repos/TyAu/TyAu-Pedals/TyAu-Distortion
xcodebuild -project Distortion.xcodeproj -scheme Distortion clean
```

## Design Decisions

### UI Design
- Knob rotation: 7 o'clock to 5 o'clock (270° range)
- Start angle: -135° (bottom-left)
- End angle: 135° (bottom-right)
- Dead zone: Bottom position (typical audio equipment style)

### Signal Processing
See [SignalProcessing.md](SignalProcessing.md) for complete DSP documentation.

## Troubleshooting

### Logic Not Seeing Updates
1. Ensure you're building Debug configuration (not Release)
2. Check plugin registration: `pluginkit -m -v | grep Distortion`
3. Try restarting Logic Pro
4. Clear audio unit cache: `killall -9 AudioComponentRegistrar`

### Build Errors
1. Check Xcode version compatibility
2. Verify code signing certificate is valid
3. Clean build folder and rebuild

### Plugin Crashes Logic
1. Check Console.app for crash logs
2. Look for Audio Unit validation errors
3. Verify DSP code doesn't have memory issues

## Notes

- Always build Debug configuration during development
- Logic Pro loads plugins from DerivedData during development
- The plugin needs to be properly signed to load in Logic
- Changes to DSP code typically require Logic restart
- UI changes may hot-reload depending on the change

---

**Last Updated:** January 27, 2026
**Project Version:** 1.0
**Xcode Version:** 17C52
**macOS Version:** Sequoia 15.7

# Swiggy IPA with Device ID Rotation

Custom Swiggy iOS app with **device identifier rotation** capability. This allows you to manually rotate device IDs (UDID, IDFV, IDFA) to bypass device-based restrictions.

## ✨ Features

- 🔄 **Manual Device ID Rotation** - Rotate UDID, IDFV, IDFA with a single tap
- 🎯 **Floating UI Button** - Draggable button positioned in safe zone (top-left)
- 🔒 **Persistent IDs** - Device IDs remain consistent until manually rotated
- 📱 **No Jailbreak Required** - Works with sideloading tools (AltStore, Sideloadly)
- ⚡ **Automated Building** - GitHub Actions builds IPA automatically

## 🚀 Quick Start

### Option 1: Download Pre-built IPA (Recommended)

1. Go to [GitHub Actions](../../actions) or [Releases](../../releases)
2. Download `Swiggy-DeviceRotation.ipa`
3. Install using AltStore or Sideloadly (see [Installation](#installation))

### Option 2: Build Locally

**Requirements:**
- macOS or Linux
- Theos installed
- `ldid` and `insert_dylib` tools

**Steps:**
```bash
# 1. Clone repository
git clone <your-repo-url>
cd scarlet-aldrin

# 2. Build dylib
cd DeviceRotation
make package
cd ..

# 3. Inject dylib and build IPA
python3 inject_dylib.py
python3 build_ipa.py
```

### Option 3: GitHub Actions (No Mac Required)

1. **Fork this repository** to your GitHub account
2. **Push the code** to your fork
3. **Go to Actions tab** in your fork
4. **Run the workflow** manually or push a commit
5. **Download the IPA** from workflow artifacts

## 📦 Installation

### Using AltStore

1. Download [AltStore](https://altstore.io)
2. Install AltStore on your iPhone
3. Open AltStore on your phone
4. Tap **"+"** and select `Swiggy-DeviceRotation.ipa`
5. Wait for installation to complete

### Using Sideloadly

1. Download [Sideloadly](https://sideloadly.io)
2. Connect your iPhone to computer
3. Drag `Swiggy-DeviceRotation.ipa` into Sideloadly
4. Enter your Apple ID
5. Click **Start**

### Using TrollStore (Jailbroken Devices)

1. Open TrollStore
2. Import `Swiggy-DeviceRotation.ipa`
3. Install permanently (no 7-day expiration)

## 🎮 Usage

1. **Launch Swiggy** - The app will load normally
2. **Floating Button** - You'll see a 🔄 button in the top-left corner
3. **Rotate Device IDs** - Tap the button to generate new device identifiers
4. **Success Animation** - Button will spin and turn green briefly
5. **Enjoy** - Use Swiggy with the new device IDs

### Moving the Button

- **Drag** the button anywhere on screen
- It will **snap to edges** when released
- Position it in a comfortable spot to avoid accidental taps

## 🔧 How It Works

### Device ID Rotation

The dylib hooks iOS system functions to provide custom device identifiers:

```
┌─────────────────────────────────────────────┐
│  App Requests Device ID                     │
├─────────────────────────────────────────────┤
│  MGCopyAnswer("UniqueDeviceID")            │
│  UIDevice.identifierForVendor              │
│  ASIdentifierManager.advertisingIdentifier │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  DeviceRotation Dylib (Hooked)             │
├─────────────────────────────────────────────┤
│  1. Check UserDefaults for stored ID       │
│  2. If not found, generate random UUID     │
│  3. Return custom ID to app                │
└─────────────────────────────────────────────┘
```

### Rotation Process

When you tap the rotate button:

1. **New IDs Generated** - Random UUIDs created for UDID, IDFV, IDFA
2. **Stored in UserDefaults** - IDs persist across app restarts
3. **Immediately Active** - New IDs used for all subsequent requests
4. **Logs to Console** - View changes in Xcode Console if connected

## 📋 Technical Details

### Hooked Functions

| Function | Purpose | Spoofed Value |
|----------|---------|---------------|
| `MGCopyAnswer` | Hardware UDID/Serial | Random UUID |
| `identifierForVendor` | App Vendor ID (IDFV) | Random UUID |
| `advertisingIdentifier` | Advertising ID (IDFA) | Random UUID |

### Files Modified

- **swiggy binary** - Injected with dylib load command
- **Frameworks/DeviceRotation.dylib** - Custom dylib with hooks

### Storage

Device IDs are stored in `UserDefaults`:
```
RotatedUDID: "ABC12345-1234-5678-90AB-CDEF12345678"
RotatedIDFV: "DEF67890-5678-1234-56AB-1234567890CD"
RotatedIDFA: "987FED65-4321-8765-43CD-BA9876543210"
RotatedSerial: "C02AB12CD3"
RotatedModel: "iPhone14,2"
```

## ⚠️ Important Notes

### Legal & Terms of Service

- This is for **educational purposes only**
- Using modified apps may violate Swiggy's Terms of Service
- Your account may be suspended if detected
- Use at your own risk

### Limitations

- **7-Day Expiration** - AltStore/Sideloadly IPAs expire after 7 days (re-sign required)
- **No App Store** - Cannot install from App Store, must sideload
- **Detection Possible** - Advanced anti-fraud systems may still detect patterns

### Compatibility

- **iOS 14.0+** - Minimum iOS version
- **arm64 only** - iPhone 5S and newer
- **Tested on**: iOS 14, 15, 16, 17

## 🛠️ Troubleshooting

### Button Not Appearing

- Wait 2-3 seconds after launch
- Check if dylib was injected: `otool -L swiggy-extracted/swiggy`
- View logs in Xcode Console for errors

### IPA Installation Failed

- **Provisioning Error**: Use a different Apple ID
- **Untrusted Developer**: Trust the certificate in Settings → General → Device Management
- **Expired IPA**: Re-sign with AltStore/Sideloadly

### Device IDs Not Changing

- Check Console logs for hook success messages
- Ensure dylib is in `Frameworks/` directory
- Verify dylib architecture matches app (arm64)

### App Crashes on Launch

- Check if dylib was signed: `codesign -dv Frameworks/DeviceRotation.dylib`
- Re-build with proper code signing
- View crash logs in Settings → Privacy → Analytics

## 🔄 Updating

To update to a newer version:

1. **Delete old app** from iPhone
2. **Download new IPA** from releases/actions
3. **Install** using your preferred method
4. **Note**: Device IDs will reset (stored in app sandbox)

## 📝 Development

### Project Structure

```
scarlet-aldrin/
├── DeviceRotation/
│   ├── DeviceRotation.m      # Main hook implementation
│   ├── FloatingButton.m       # UI button component
│   └── Makefile              # Theos build config
├── swiggy-extracted/         # Decrypted Swiggy app
├── inject_dylib.py           # Dylib injection script
├── build_ipa.py              # IPA packaging script
└── .github/workflows/
    └── build.yml             # CI/CD pipeline
```

### Building Dylib Only

```bash
cd DeviceRotation
export THEOS=~/theos
make clean
make package
```

### Modifying Hooks

Edit `DeviceRotation/DeviceRotation.m` to customize:
- Device ID formats
- Additional hooks (location, etc.)
- Logging behavior

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 📄 License

This project is for educational purposes. Use responsibly.

## 🙏 Credits

- **Theos** - iOS development framework
- **insert_dylib** - Dylib injection tool
- **AltStore** - Sideloading platform

---

**Disclaimer**: This project is not affiliated with Swiggy. Use at your own risk.

# AudioPure iOS App - Setup Guide

## 📱 What You Have

A complete, production-ready iOS app for audio processing using Meta SAM Audio AI via Modal backend!

**Features:**
- ✅ File selection from Photos library
- ✅ Text-based prompting ("voice", "wind", "music")
- ✅ Isolate or Remove sound modes
- ✅ Real-time progress tracking
- ✅ Audio playback and sharing
- ✅ Beautiful SwiftUI UI with dark mode
- ✅ Smooth animations

---

## 🚀 Quick Start

### 1. Open in Xcode

1. Open Xcode (version 15.0 or later)
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Set:
   - **Product Name**: `AudioPure`
   - **Team**: Select your team (NBVF93876Q)
   - **Organization Identifier**: `com.yourcompany` (or use your own)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployment**: iOS 16.0
5. Click **Next** and save

### 2. Import Source Files

After creating the project, **replace the default files** with the ones I've created:

1. Delete the default `ContentView.swift` and `AudioPureApp.swift` from Xcode
2. In Finder, copy all files from `/Users/keshavkotteswaran/Desktop/AudioPure/AudioPure/` 
3. Drag them into your Xcode project, maintaining the folder structure:
   - App/
   - Models/
   - Services/
   - ViewModels/
   - Views/
   - Extensions/

4. Replace `Info.plist` with the one at `/Users/keshavkotteswaran/Desktop/AudioPure/Info.plist`

### 3. Add App Icon

1. In Xcode, open **Assets.xcassets**
2. Click on **AppIcon**
3. Drag the generated icon image into the **1024x1024** slot
4. Icon location: `/Users/keshavkotteswaran/.gemini/antigravity/brain/9abc868d-aae4-4395-8989-072cd0524b0a/pureaudio_app_icon_*.png`

### 4. Configure Code Signing

1. Select your project in Xcode
2. Go to **Signing & Capabilities**
3. Select your **Team**: NBVF93876Q
4. Xcode will automatically provision the app

### 5. Build and Run!

1. Select an iPhone simulator or your device
2. Press **⌘R** or click the Play button
3. The app should launch! 🎉

---

## 🧪 Testing the App

### First Launch
1. You'll see the onboarding screen
2. Tap "Get Started"
3. You'll be taken to the main screen

### Test Processing Flow
1. Tap the file picker card
2. Select an audio/video file from your Photos
3. Enter a prompt (e.g., "voice" or "wind noise")
4. Select "Isolate" or "Remove" mode
5. Tap "Process Audio"
6. Watch the progress bar
7. When complete, play the result and share!

### Test Without Real Backend (Initially)
The app will attempt to connect to your Modal endpoint. If you want to test without the backend first, you can:
1. Comment out the API call in `AudioProcessor.swift`
2. Add mock data for testing the UI flow
3. Uncomment once your Modal backend is ready

---

## ⚙️ Configuration

### Modal API Endpoint

The app is configured to use your Modal endpoint:
```
https://keshavk2089--pureaudio-fastapi-app.modal.run
```

This is set in `Config.swift`. If your endpoint changes, update:
```swift
static let modalAPIBase = "YOUR_NEW_ENDPOINT"
```

### API Request Format

The app sends a multipart POST request with:
- `audio`: Audio file data
- `prompt`: Text prompt (string)
- `mode`: "isolate" or "remove" (string)

If your Modal API expects a different format, adjust `ModalService.swift`.

---

## 📁 Project Structure

```
AudioPure/
├── App/
│   ├── AudioPureApp.swift          # App entry point
│   └── Config.swift                # Configuration constants
├── Models/
│   ├── AudioFile.swift             # Audio file model
│   ├── ProcessingMode.swift        # Isolate/Remove enum
│   └── ProcessingJob.swift         # Job state tracking
├── Services/
│   ├── ModalService.swift          # API communication
│   └── AudioProcessor.swift        # Processing orchestration
├── ViewModels/
│   └── MainViewModel.swift         # App state management
├── Views/
│   ├── OnboardingView.swift        # First-time setup
│   ├── ContentView.swift           # Main screen (4 states)
│   ├── SettingsView.swift          # Settings modal
│   └── Components/
│       ├── FilePickerButton.swift  # File selection
│       ├── PromptInputCard.swift   # Prompt input
│       ├── ProcessingView.swift    # Progress display
│       └── ResultView.swift        # Result playback
└── Extensions/
    ├── Color+Extensions.swift      # Brand colors
    └── View+Extensions.swift       # View modifiers
```

---

## 🔧 Common Issues & Solutions

### Issue: "PhotosPicker doesn't work in simulator"
**Solution**: Use a real device, or add sample media to the simulator via drag-and-drop

### Issue: "Network request fails"
**Solution**: 
1. Check your Modal endpoint is running
2. Verify `Config.modalAPIBase` is correct
3. Add `NSAppTransportSecurity` exception if using HTTP (not recommended)

### Issue: "Build errors about missing imports"
**Solution**: Ensure all files are added to the target in Xcode (check the file inspector)

### Issue: "App crashes on file selection"
**Solution**: Make sure Info.plist privacy permissions are set correctly

---

## 🎨 Customization

### Colors
Edit `Color+Extensions.swift` to change the app's color scheme:
```swift
static let primaryPurple = Color(red: 122/255, green: 61/255, blue: 222/255)
static let accentPink = Color(red: 255/255, green: 75/255, blue: 140/255)
```

### Prompt Suggestions
Edit `MainViewModel.swift`:
```swift
let promptSuggestions = [
    "voice", "wind noise", "music", "guitar",
    // Add your own suggestions here
]
```

### File Size Limit
Edit `Config.swift`:
```swift
static let maxFileSizeMB: Double = 100.0  // Change this
```

---

## 📱 App Store Preparation

Before submitting to the App Store:

1. **Migrate API Keys**: Move any secrets from UserDefaults to Keychain
2. **Test on Real Device**: Test all features on an actual iPhone
3. **Screenshots**: Take screenshots of all screens for App Store listing
4. **Privacy Policy**: Create a privacy policy (required for photo access)
5. **App Store Connect**: Set up your app listing, metadata, and screenshots
6. **TestFlight**: Upload a build for beta testing first

---

## 🐛 Known Limitations

1. **Beta API**: Modal endpoint may change structure - adjust `ModalService.swift` accordingly
2. **Large Files**: Files over 100MB are rejected client-side
3. **No Offline Mode**: App requires network connection
4. **iPhone Only**: Currently iPhone only (iPad support coming)
5. **Portrait Only**: Locked to portrait orientation

---

## 💡 Next Steps

1. **Test the UI**: Run in simulator to verify all screens work
2. **Test with Mock Data**: Create test files to verify the flow
3. **Connect to Modal**: Once backend is ready, test real processing
4. **Polish**: Add more animations, improve error messages
5. **TestFlight**: Upload for beta testing
6. **App Store**: Submit when ready!

---

## 🆘 Need Help?

If you encounter issues:

1. **Check Xcode Console**: Look for error messages
2. **Verify Modal Endpoint**: Test it with curl or Postman
3. **Review Code Comments**: All files have detailed comments
4. **Modal API Structure**: You may need to adjust `ModalService.swift` based on actual API response format

---

**You're all set!** 🎉

Your AudioPure iOS app is ready to build and test. Just open it in Xcode and run!

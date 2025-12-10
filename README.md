# GuardianLink

A Flutter-based parental control app for managing and monitoring child device usage via Bluetooth Low Energy (BLE).

## Features

- **BLE Device Connection**: Scans and connects to ESP32 parental control devices over Bluetooth Low Energy.
- **Device Management**: View connected device info and status.
- **Parental Lock**: Enable/disable remote device locking via toggle.
- **Profile Management**: Switch between different child profiles (Child 1, Child 2, Teenager, Admin).
- **Security & PIN**: Set and manage a 4-digit PIN for additional security.
- **App Control**: View installed apps, set time limits, and block/unblock specific apps.
- **System Tools**: Access network diagnostics, device information, storage manager, and cache clearing utilities.
- **Permissions Handling**: Proper runtime permissions for Bluetooth and location on Android; Bluetooth permission on iOS.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.1)
- Android SDK (API 33 or higher) or iOS 11+
- Dart SDK (bundled with Flutter)
- A device with Bluetooth capability

### Installation

1. Clone or navigate to the project directory:
   ```bash
   cd guardianlink
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Connect a physical device or emulator.

4. Run the app:
   ```bash
   flutter run
   ```

### Build for Release

**Android:**
```bash
flutter build apk --release
# or for App Bundle:
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

- `lib/main.dart` – Main app entry point with UI and BLE integration
- `android/` – Android-specific configuration and native code
- `ios/` – iOS-specific configuration and native code
- `test/` – Widget and unit tests

## Key Dependencies

- `flutter_reactive_ble` (^5.0.2) – BLE communication
- `permission_handler` (^11.0.0) – Runtime permission handling
- `flutter_lints` (^6.0.0) – Code linting

## Testing

Run all tests:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

## Notes

- The app requires a physical device for BLE connectivity; simulators do not support Bluetooth.
- Android 12+ requires Bluetooth SCAN and CONNECT permissions at runtime.
- iOS requires `NSBluetoothAlwaysUsageDescription` and `NSBluetoothPeripheralUsageDescription` in `Info.plist`.

## License

This project is private and not published.

For more information on Flutter, see the [official documentation](https://flutter.dev/).

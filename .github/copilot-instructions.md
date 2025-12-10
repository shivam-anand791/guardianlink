Purpose
This file gives immediate, actionable guidance for AI coding agents working on this Flutter BLE client project.

**Big Picture**
- **Type**: Flutter multi-platform app (mobile-first) that acts as a BLE client for an ESP32 device.
- **Core behavior**: The app scans for a specific BLE service, connects, and writes simple text commands (`LOCK`/`UNLOCK`) to a characteristic. See `lib/main.dart` for the primary flow.

**Key Files**
- `lib/main.dart`: Single-file BLE implementation used by the sample UI. Important symbols: `SERVICE_UUID`, `CHAR_UUID`, global `flutterReactiveBle`, `_scanSub`/`_connSub` (subscriptions), and `QualifiedCharacteristic` usage.
- `pubspec.yaml`: Dependencies include `flutter_reactive_ble` and `permission_handler` (versions pinned here). Keep dependency edits consistent with the file.
- `android/`, `ios/`: Platform configuration and native plugin integration. Check these when changing permissions or plugin versions.
- `test/widget_test.dart`: Existing basic test harness; run with `flutter test`.

**Developer Workflows (project-specific)**
- Install deps: `flutter pub get`.
- Run on device: `flutter run -d <device-id>` (BLE requires a real device; iOS simulator does not support BLE).
- Build APK: `flutter build apk`.
- Tests: `flutter test`.
- Inspect native config: review `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` when changing runtime permissions or privacy strings.

**Patterns & Conventions to preserve**
- Single BLE client instance: a global `FlutterReactiveBle()` is used; avoid creating multiple instances (may cause platform issues).
- Stream subscription lifecycle: scans and connection streams are cancelled with `_scanSub?.cancel()` and `_connSub?.cancel()` and `dispose()` uses these—preserve this pattern when refactoring.
- Write protocol: commands are UTF-8 text encoded (`utf8.encode(cmd)`) and sent via `writeCharacteristicWithResponse(...)` to the `QualifiedCharacteristic` constructed from `SERVICE_UUID`, `CHAR_UUID`, and `deviceId`.
- Permissions: runtime permission checks use `permission_handler` and `Platform.isAndroid`/`Platform.isIOS` branching in `lib/main.dart`—follow that same pattern for new BLE features.

**Integration & External Dependencies**
- `flutter_reactive_ble` (see `pubspec.yaml`) handles scanning/connection; consult its docs for advanced features (notifications, MTU, bonded devices).
- `permission_handler` is used for runtime permissions; Android 12+ requires `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` and older versions may require location. Update `AndroidManifest.xml` and `Info.plist` accordingly.
- Native builds: typical Flutter plugin lifecycle applies—use `flutter pub get` then platform build commands. For Android debugging, confirm `local.properties` points to the correct SDK when needed.

**What to watch out for / common pitfalls**
- Do not rely on simulator for BLE debugging (use a real device).
- Avoid forgetting to cancel subscriptions; leaking subscriptions leads to unexpected behavior after hot-reload/hot-restart.
- Changing characteristic UUIDs or write mode (with/without response) changes ESP32 firmware expectations — coordinate with firmware.

**Concrete code references (examples)**
- Scan for devices: `flutterReactiveBle.scanForDevices(withServices: [SERVICE_UUID])` (in `lib/main.dart`).
- Create characteristic for writes:
  `QualifiedCharacteristic(serviceId: SERVICE_UUID, characteristicId: CHAR_UUID, deviceId: device.id)`
- Send payload: `flutterReactiveBle.writeCharacteristicWithResponse(txChar!, value: utf8.encode(cmd));`

If anything here is incomplete or you'd like additional sections (CI, more platform-specific commands, firmware contract examples), tell me which area to expand and I'll iterate.

Requested next step: confirm whether you want CI steps, platform manifest diffs, or example firmware message format included.

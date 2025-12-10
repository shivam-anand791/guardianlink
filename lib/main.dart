// lib/main.dart
import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/home_screen.dart';
import 'widgets/settings_screen.dart';
import 'widgets/apps_screen.dart';
import 'widgets/tools_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardianLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabIndex = 0;
  String deviceName = 'No Device';

  // BLE
  FlutterReactiveBle? flutterReactiveBle;
  final Uuid serviceUuid = Uuid.parse('0000abcd-0000-1000-8000-00805f9b34fb');
  final Uuid charUuid = Uuid.parse('0000abce-0000-1000-8000-00805f9b34fb');
  DiscoveredDevice? espDevice;
  QualifiedCharacteristic? txChar;
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  bool isScanning = false;

  // Settings state
  bool parentalLockEnabled = true;
  String? selectedProfile = 'Child 1';
  String? pinCode = '1234';
  bool pinSet = true;

  // Apps state
  late List<Map<String, dynamic>> installedApps;

  // System info
  late Map<String, dynamic> systemInfo;

  // Device info fetchers
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _refreshTimer;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _askPermissions();
    _initializeData();
    _refreshSystemInfo();
    _listenToBattery();
    _listenToConnectivity();
    // Refresh device info every 5 seconds to catch device changes
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _refreshSystemInfo();
    });
    // Refresh location every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchLocation();
    });
  }

  void _initializeData() {
    installedApps = [
      {'name': 'YouTube', 'category': 'Entertainment', 'blocked': false, 'timeLimit': 60},
      {'name': 'TikTok', 'category': 'Social Media', 'blocked': true, 'timeLimit': 0},
      {'name': 'Instagram', 'category': 'Social Media', 'blocked': false, 'timeLimit': 45},
      {'name': 'Game of War', 'category': 'Games', 'blocked': true, 'timeLimit': 0},
      {'name': 'Clash Royale', 'category': 'Games', 'blocked': false, 'timeLimit': 90},
      {'name': 'Safari', 'category': 'Browser', 'blocked': false, 'timeLimit': 120},
    ];

    systemInfo = {
      'deviceName': 'Loading...',
      'osVersion': 'Loading...',
      'batteryLevel': 0,
      'wifiStatus': 'Detecting...',
      'wifiName': 'Detecting...',
      'storageUsed': 'Loading...',
      'latitude': 'Fetching...',
      'longitude': 'Fetching...',
      'accuracy': 'Fetching...',
    };
  }

  Future<void> _refreshSystemInfo() async {
    try {
      String deviceName = 'Unknown';
      String osVersion = 'Unknown';
      int batteryLevel = 0;

      if (Platform.isAndroid) {
        try {
          final androidInfo = await _deviceInfo.androidInfo;
          deviceName = androidInfo.model;
          osVersion = 'Android ${androidInfo.version.release}';
          debugPrint('Device info fetched: $deviceName, $osVersion');
        } catch (e) {
          debugPrint('Error fetching Android info: $e');
        }
      } else if (Platform.isIOS) {
        try {
          final iosInfo = await _deviceInfo.iosInfo;
          deviceName = iosInfo.model;
          osVersion = iosInfo.systemVersion;
        } catch (e) {
          debugPrint('Error fetching iOS info: $e');
        }
      }

      try {
        batteryLevel = await _battery.batteryLevel;
        debugPrint('Battery level: $batteryLevel');
      } catch (e) {
        debugPrint('Error fetching battery: $e');
      }

      if (mounted) {
        setState(() {
          systemInfo = {
            'deviceName': deviceName,
            'osVersion': osVersion,
            'batteryLevel': batteryLevel,
            'wifiStatus': 'Connected',
            'wifiName': 'Home-WiFi',
            'storageUsed': '32 GB / 128 GB',
          };
        });
      }
    } catch (e) {
      debugPrint('Error in _refreshSystemInfo: $e');
    }
  }

  void _listenToBattery() {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _refreshSystemInfo();
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateWifiInfo(result);
    });
  }

  Future<void> _updateWifiInfo(ConnectivityResult result) async {
    try {
      String wifiStatus = 'Disconnected';
      String wifiName = 'None';

      if (result == ConnectivityResult.wifi) {
        wifiStatus = 'Connected';
        // Try to get WiFi name (limited on Android 10+)
        wifiName = 'WiFi Network';
      } else if (result == ConnectivityResult.mobile) {
        wifiStatus = 'Mobile Data';
        wifiName = 'Mobile Network';
      }

      if (mounted) {
        setState(() {
          systemInfo['wifiStatus'] = wifiStatus;
          systemInfo['wifiName'] = wifiName;
        });
      }
    } catch (e) {
      debugPrint('Error updating WiFi info: $e');
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).timeout(
          const Duration(seconds: 5),
        );

        if (mounted) {
          setState(() {
            systemInfo['latitude'] = position.latitude.toStringAsFixed(4);
            systemInfo['longitude'] = position.longitude.toStringAsFixed(4);
            systemInfo['accuracy'] = '${position.accuracy.toStringAsFixed(1)}m';
          });
        }
      } catch (e) {
        debugPrint('Timeout or error getting location: $e');
      }
    } catch (e) {
      debugPrint('Error in _fetchLocation: $e');
    }
  }

  Future<void> _askPermissions() async {
    if (Platform.isAndroid) {
      final perms = <Permission>[];
      if (await Permission.bluetoothScan.isDenied) perms.add(Permission.bluetoothScan);
      if (await Permission.bluetoothConnect.isDenied) perms.add(Permission.bluetoothConnect);
      if (await Permission.locationWhenInUse.isDenied) perms.add(Permission.locationWhenInUse);
      if (await Permission.location.isDenied) perms.add(Permission.location);
      if (perms.isNotEmpty) await perms.request();
    } else if (Platform.isIOS) {
      if (await Permission.bluetooth.isDenied) await Permission.bluetooth.request();
      if (await Permission.locationWhenInUse.isDenied) await Permission.locationWhenInUse.request();
    }
  }

  void _onConnectPressed() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting...')));
    _startScan();
  }

  void _startScan() {
    if (isScanning) return;
    setState(() {
      isScanning = true;
      espDevice = null;
    });

    _scanSub?.cancel();
    bool startedScan = false;
    try {
      flutterReactiveBle ??= FlutterReactiveBle();
      _scanSub = flutterReactiveBle!.scanForDevices(withServices: [serviceUuid]).listen((device) {
        if (espDevice == null) {
          espDevice = device;
          setState(() {
            deviceName = device.name.isNotEmpty ? device.name : device.id;
            isScanning = false;
          });
          _scanSub?.cancel();
          _scanSub = null;
          _connect(device);
        }
      }, onError: (e) {
        setState(() {
          isScanning = false;
        });
      });
      startedScan = true;
    } catch (e) {
      setState(() {
        isScanning = false;
      });
    }

    if (startedScan) {
      Timer(const Duration(seconds: 12), () {
        if (espDevice == null) {
          _scanSub?.cancel();
          _scanSub = null;
          setState(() {
            isScanning = false;
          });
        }
      });
    }
  }

  void _connect(DiscoveredDevice device) {
    _connSub?.cancel();
    if (flutterReactiveBle == null) return;
    _connSub = flutterReactiveBle!.connectToDevice(id: device.id, connectionTimeout: const Duration(seconds: 10)).listen((update) {
      connectionState = update.connectionState;
      if (update.connectionState == DeviceConnectionState.connected) {
        txChar = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: charUuid, deviceId: device.id);
        setState(() {
          deviceName = device.name.isNotEmpty ? device.name : device.id;
        });
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        txChar = null;
      }
    }, onError: (e) {
      txChar = null;
    });
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
    _refreshTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return HomeScreen(
          flutterReactiveBle: flutterReactiveBle,
          serviceUuid: serviceUuid,
          charUuid: charUuid,
          deviceName: deviceName,
          isScanning: isScanning,
          onConnectPressed: _onConnectPressed,
          isConnected: connectionState == DeviceConnectionState.connected,
        );
      case 1:
        return SettingsScreen(
          parentalLockEnabled: parentalLockEnabled,
          selectedProfile: selectedProfile,
          pinCode: pinCode,
          pinSet: pinSet,
          onParentalLockChanged: (v) {
            setState(() => parentalLockEnabled = v);
          },
          onProfileChanged: (profile) {
            setState(() => selectedProfile = profile);
          },
          onPinChanged: (pin) {
            setState(() {
              pinCode = pin;
              pinSet = true;
            });
          },
        );
      case 2:
        return AppsScreen(
          installedApps: installedApps,
          onAppStatusChanged: (idx, blocked) {
            setState(() => installedApps[idx]['blocked'] = blocked);
          },
          onTimeLimitChanged: (idx, limit) {
            setState(() => installedApps[idx]['timeLimit'] = limit);
          },
        );
      case 3:
        return ToolsScreen(systemInfo: systemInfo);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}

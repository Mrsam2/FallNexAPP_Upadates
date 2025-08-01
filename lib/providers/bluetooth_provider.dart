import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../services/bluetooth_service.dart';
import '../services/firebase_service.dart';

class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final FirebaseService _firebaseService = FirebaseService();

  List<fbp.ScanResult> _espScanResults = [];
  List<fbp.BluetoothDevice> _connectedESPDevices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  String? _connectedDeviceId;
  String? _connectedDeviceName;
  Map<String, dynamic>? _latestData;
  String _connectionStatus = 'No ESP device connected';
  bool _isBluetoothOn = false;

  // System status monitoring
  bool _isSystemActive = false;
  DateTime? _lastDataReceived;
  Timer? _systemStatusTimer;
  static const Duration _dataTimeout = Duration(seconds: 30); // Consider system inactive after 30 seconds

  // Getters
  List<fbp.ScanResult> get espScanResults => _espScanResults;
  List<fbp.BluetoothDevice> get connectedESPDevices => _connectedESPDevices;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isBluetoothOn => _isBluetoothOn;
  String? get connectedDeviceId => _connectedDeviceId;
  String? get connectedDeviceName => _connectedDeviceName;
  Map<String, dynamic>? get latestData => _latestData;
  String get connectionStatus => _connectionStatus;
  bool get isSystemActive => _isSystemActive;
  DateTime? get lastDataReceived => _lastDataReceived;

  BluetoothProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _bluetoothService.initialize();
    await _firebaseService.initialize();

    // Check Bluetooth state
    _isBluetoothOn = await fbp.FlutterBluePlus.isOn;

    // Listen to Bluetooth state changes
    fbp.FlutterBluePlus.adapterState.listen((state) {
      _isBluetoothOn = state == fbp.BluetoothAdapterState.on;
      if (!_isBluetoothOn) {
        _connectionStatus = 'Bluetooth is off';
        _isConnected = false;
        _connectedDeviceId = null;
        _connectedDeviceName = null;
        _updateSystemStatus(false);
      }
      notifyListeners();
    });

    // Listen to incoming ESP data
    _bluetoothService.dataStream.listen((data) {
      _latestData = data;
      _lastDataReceived = DateTime.now();
      _updateSystemStatus(true);
      notifyListeners();

      // Send data to Firebase
      _firebaseService.sendSensorData(data);

      // Check for fall detection
      _checkForFallDetection(data);
    });

    // Start system status monitoring timer
    _startSystemStatusMonitoring();

    // Check for already connected ESP devices
    _checkConnectedESPDevices();
  }

  void _startSystemStatusMonitoring() {
    _systemStatusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkSystemStatus();
    });
  }

  void _checkSystemStatus() {
    if (_lastDataReceived == null) {
      _updateSystemStatus(false);
      return;
    }

    final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);
    final shouldBeActive = _isConnected &&
        _isBluetoothOn &&
        timeSinceLastData < _dataTimeout;

    if (_isSystemActive != shouldBeActive) {
      _updateSystemStatus(shouldBeActive);
    }
  }

  void _updateSystemStatus(bool isActive) {
    if (_isSystemActive != isActive) {
      _isSystemActive = isActive;
      notifyListeners();
      print('System status changed: ${isActive ? "ACTIVE" : "INACTIVE"}');
    }
  }

  String getSystemStatusMessage() {
    if (!_isBluetoothOn) {
      return 'Bluetooth is turned off';
    } else if (!_isConnected) {
      return 'ESP device not connected';
    } else if (_lastDataReceived == null) {
      return 'Waiting for sensor data...';
    } else if (_isSystemActive) {
      return 'Fall detection system is active and monitoring';
    } else {
      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);
      if (timeSinceLastData.inMinutes > 1) {
        return 'No data received for ${timeSinceLastData.inMinutes} minutes';
      } else {
        return 'No data received for ${timeSinceLastData.inSeconds} seconds';
      }
    }
  }

  String getDetailedSystemStatus() {
    if (_isSystemActive && _lastDataReceived != null) {
      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);
      return 'Last data: ${timeSinceLastData.inSeconds}s ago';
    } else if (_lastDataReceived != null) {
      final timeSinceLastData = DateTime.now().difference(_lastDataReceived!);
      return 'Data stopped ${timeSinceLastData.inSeconds}s ago';
    } else {
      return 'No data received yet';
    }
  }

  Future<void> _checkConnectedESPDevices() async {
    try {
      _connectedESPDevices = await _bluetoothService.getConnectedESPDevices();
      if (_connectedESPDevices.isNotEmpty) {
        // If there's already a connected ESP device, update status
        final device = _connectedESPDevices.first;
        _isConnected = true;
        _connectedDeviceId = device.remoteId.toString();
        _connectedDeviceName = device.platformName;
        _connectionStatus = 'Connected to ${device.platformName}';
        // Don't set system as active until we receive data
        notifyListeners();
      }
    } catch (e) {
      print('Error checking connected ESP devices: $e');
    }
  }

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> turnOnBluetooth() async {
    try {
      if (await fbp.FlutterBluePlus.isSupported == false) {
        _connectionStatus = 'Bluetooth not supported on this device';
        notifyListeners();
        return;
      }

      // Request to turn on Bluetooth
      await fbp.FlutterBluePlus.turnOn();
      _connectionStatus = 'Bluetooth turned on';
      notifyListeners();
    } catch (e) {
      _connectionStatus = 'Failed to turn on Bluetooth: $e';
      notifyListeners();
    }
  }

  Future<void> scanForESPDevices() async {
    if (!await requestPermissions()) {
      _connectionStatus = 'Bluetooth permissions denied';
      notifyListeners();
      return;
    }

    if (!_isBluetoothOn) {
      _connectionStatus = 'Bluetooth is off - cannot scan for ESP devices';
      notifyListeners();
      return;
    }

    _isScanning = true;
    _connectionStatus = 'Scanning for ESP devices...';
    notifyListeners();

    try {
      _espScanResults = await _bluetoothService.scanForESPDevices();
      _connectedESPDevices = await _bluetoothService.getConnectedESPDevices();

      if (_espScanResults.isEmpty) {
        _connectionStatus = 'No ESP devices found nearby';
      } else {
        _connectionStatus = 'Found ${_espScanResults.length} ESP device(s)';
      }
    } catch (e) {
      _connectionStatus = 'Error scanning for ESP devices: $e';
    }

    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connectToESPDevice(fbp.BluetoothDevice device) async {
    _connectionStatus = 'Connecting to ESP device ${device.platformName}...';
    notifyListeners();

    bool success = await _bluetoothService.connectToESPDevice(device);

    if (success) {
      _isConnected = true;
      _connectedDeviceId = device.remoteId.toString();
      _connectedDeviceName = device.platformName;
      _connectionStatus = 'Connected to ESP device: ${device.platformName}';
      // Reset data tracking for new connection
      _lastDataReceived = null;
      _updateSystemStatus(false);
    } else {
      _isConnected = false;
      _connectedDeviceId = null;
      _connectedDeviceName = null;
      _connectionStatus = 'Failed to connect to ESP device: ${device.platformName}';
      _updateSystemStatus(false);
    }

    notifyListeners();
    return success;
  }

  Future<void> disconnectFromESP() async {
    await _bluetoothService.disconnect();
    _isConnected = false;
    _connectedDeviceId = null;
    _connectedDeviceName = null;
    _connectionStatus = 'Disconnected from ESP device';
    _latestData = null;
    _lastDataReceived = null;
    _updateSystemStatus(false);
    notifyListeners();
  }

  Future<bool> sendCommandToESP(String command) async {
    return await _bluetoothService.sendDataToESP(command);
  }

  void _checkForFallDetection(Map<String, dynamic> data) {
    // Check if the ESP data indicates a fall
    bool isFallDetected = false;

    if (data.containsKey('fall_detected')) {
      isFallDetected = data['fall_detected'] == true;
    } else if (data.containsKey('acceleration')) {
      // Check acceleration threshold for fall detection
      double acceleration = data['acceleration']?.toDouble() ?? 0.0;
      isFallDetected = acceleration > 2.5; // Adjust threshold as needed
    } else if (data.containsKey('accel_magnitude')) {
      // Alternative acceleration field name
      double accelMagnitude = data['accel_magnitude']?.toDouble() ?? 0.0;
      isFallDetected = accelMagnitude > 2.5;
    }

    if (isFallDetected) {
      _handleFallDetection(data);
    }
  }

  void _handleFallDetection(Map<String, dynamic> data) {
    Map<String, dynamic> alertData = {
      'sensorData': data,
      'deviceId': _connectedDeviceId,
      'deviceName': _connectedDeviceName,
      'deviceType': 'ESP32',
      'detectionTime': DateTime.now().toIso8601String(),
      'alertType': 'fall_detected',
    };

    _firebaseService.sendFallAlert(alertData);
    print('Fall detected by ESP device: ${_connectedDeviceName}');
  }

  String getESPDeviceInfo() {
    if (_isConnected && _connectedDeviceName != null) {
      return 'ESP Device: $_connectedDeviceName\nAddress: $_connectedDeviceId';
    }
    return 'No ESP device connected';
  }

  @override
  void dispose() {
    _systemStatusTimer?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _characteristic;
  StreamController<Map<String, dynamic>>? _dataController;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _characteristicSubscription;
  bool _isConnected = false;
  String? _connectedDeviceId;

  // ESP device identification patterns
  static const List<String> _espDeviceNames = [
    'ESP32',
    'ESP8266',
    'ESP-32',
    'ESP_32',
    'FallDetection',
    'Fall_Detection',
    'MPU6050',
  ];

  // ESP MAC address prefixes (Espressif company OUI)
  static const List<String> _espMacPrefixes = [
    '24:0A:C4',  // Espressif Inc.
    '30:AE:A4',  // Espressif Inc.
    '7C:9E:BD',  // Espressif Inc.
    '84:CC:A8',  // Espressif Inc.
    'A4:CF:12',  // Espressif Inc.
    'B4:E6:2D',  // Espressif Inc.
    'CC:50:E3',  // Espressif Inc.
    'DC:A6:32',  // Espressif Inc.
    '40:22:D8',  // Your specific device prefix
  ];

  Stream<Map<String, dynamic>> get dataStream => _dataController!.stream;
  bool get isConnected => _isConnected;
  String? get connectedDeviceId => _connectedDeviceId;

  Future<void> initialize() async {
    _dataController = StreamController<Map<String, dynamic>>.broadcast();
  }

  bool _isESPDevice(fbp.BluetoothDevice device) {
    // Check device name
    String deviceName = device.platformName.toUpperCase();
    for (String espName in _espDeviceNames) {
      if (deviceName.contains(espName.toUpperCase())) {
        return true;
      }
    }

    // Check MAC address prefix
    String macAddress = device.remoteId.toString().toUpperCase();
    for (String prefix in _espMacPrefixes) {
      if (macAddress.startsWith(prefix.toUpperCase())) {
        return true;
      }
    }

    return false;
  }

  Future<List<fbp.BluetoothDevice>> getConnectedESPDevices() async {
    try {
      List<fbp.BluetoothDevice> allConnected = await fbp.FlutterBluePlus.connectedDevices;
      return allConnected.where((device) => _isESPDevice(device)).toList();
    } catch (e) {
      print('Error getting connected ESP devices: $e');
      return [];
    }
  }

  Future<List<fbp.ScanResult>> scanForESPDevices({Duration timeout = const Duration(seconds: 15)}) async {
    List<fbp.ScanResult> espResults = [];

    try {
      // Check if Bluetooth is on
      if (await fbp.FlutterBluePlus.isOn == false) {
        throw Exception('Bluetooth is not enabled');
      }

      // Start scanning with longer timeout for ESP devices
      await fbp.FlutterBluePlus.startScan(timeout: timeout);

      // Listen to scan results and filter ESP devices
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((scanResults) {
        espResults = scanResults.where((result) => _isESPDevice(result.device)).toList();
      });

      // Wait for scan to complete
      await Future.delayed(timeout);
      await fbp.FlutterBluePlus.stopScan();

      print('Found ${espResults.length} ESP devices out of total scan results');
      return espResults;
    } catch (e) {
      print('Error scanning for ESP devices: $e');
      await fbp.FlutterBluePlus.stopScan();
      return [];
    }
  }

  Future<bool> connectToESPDevice(fbp.BluetoothDevice device) async {
    try {
      // Verify it's an ESP device before connecting
      if (!_isESPDevice(device)) {
        print('Device ${device.platformName} is not an ESP device');
        return false;
      }

      if (_isConnected) {
        await disconnect();
      }

      print('Connecting to ESP device: ${device.platformName} (${device.remoteId})');

      // Connect to device with longer timeout for ESP devices
      await device.connect(timeout: const Duration(seconds: 20));
      _connectedDevice = device;
      _isConnected = true;
      _connectedDeviceId = device.remoteId.toString();

      // Discover services
      List<fbp.BluetoothService> services = await device.discoverServices();

      // Find the characteristic for data communication
      // Look for common ESP32 service UUIDs or any writable/readable characteristic
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          // Look for notify or read characteristics for data reception
          if (characteristic.properties.notify ||
              characteristic.properties.read ||
              characteristic.properties.write) {
            _characteristic = characteristic;

            // Enable notifications if supported
            if (characteristic.properties.notify) {
              await characteristic.setNotifyValue(true);
              _characteristicSubscription = characteristic.lastValueStream.listen(_onDataReceived);
              print('Enabled notifications on characteristic: ${characteristic.uuid}');
            }
            break;
          }
        }
        if (_characteristic != null) break;
      }

      // Listen for disconnection
      device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          print('ESP device disconnected');
          _handleConnectionClosed();
        }
      });

      print('Successfully connected to ESP device: ${device.platformName}');
      return true;
    } catch (e) {
      print('Failed to connect to ESP device: $e');
      _isConnected = false;
      _connectedDeviceId = null;
      _connectedDevice = null;
      return false;
    }
  }

  void _onDataReceived(List<int> data) {
    try {
      String receivedString = String.fromCharCodes(data);
      print('Received ESP data: $receivedString');

      // Parse JSON data from ESP
      Map<String, dynamic> parsedData = jsonDecode(receivedString);

      // Add metadata
      parsedData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      parsedData['deviceId'] = _connectedDeviceId;
      parsedData['deviceType'] = 'ESP32';
      parsedData['source'] = 'bluetooth';

      // Emit data to stream
      _dataController?.add(parsedData);
    } catch (e) {
      print('Error parsing ESP data: $e');
      // If not JSON, treat as raw string but still mark as ESP data
      Map<String, dynamic> rawData = {
        'rawData': String.fromCharCodes(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceId': _connectedDeviceId,
        'deviceType': 'ESP32',
        'source': 'bluetooth',
      };
      _dataController?.add(rawData);
    }
  }

  void _handleConnectionClosed() {
    _isConnected = false;
    _connectedDeviceId = null;
    _connectedDevice = null;
    _characteristic = null;
    _characteristicSubscription?.cancel();
  }

  Future<void> disconnect() async {
    try {
      _characteristicSubscription?.cancel();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        print('Disconnected from ESP device');
      }
      _handleConnectionClosed();
    } catch (e) {
      print('Error disconnecting from ESP device: $e');
    }
  }

  Future<bool> sendDataToESP(String data) async {
    if (!_isConnected || _characteristic == null) {
      print('Cannot send data: ESP device not connected');
      return false;
    }

    try {
      List<int> bytes = utf8.encode(data);
      await _characteristic!.write(bytes);
      print('Sent data to ESP: $data');
      return true;
    } catch (e) {
      print('Error sending data to ESP: $e');
      return false;
    }
  }

  String? getConnectedESPDeviceName() {
    return _connectedDevice?.platformName;
  }

  String? getConnectedESPDeviceAddress() {
    return _connectedDevice?.remoteId.toString();
  }

  void dispose() {
    _scanSubscription?.cancel();
    _characteristicSubscription?.cancel();
    disconnect();
    _dataController?.close();
  }
}

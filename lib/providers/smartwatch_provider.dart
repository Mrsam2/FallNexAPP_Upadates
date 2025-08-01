// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:async';
// import 'package:flutter/foundation.dart'; // Import for defaultTargetPlatform
//
// class SmartwatchProvider extends ChangeNotifier {
//   BluetoothDevice? _connectedDevice;
//   BluetoothDevice? get connectedDevice => _connectedDevice;
//
//   int? _heartRate;
//   int? get heartRate => _heartRate;
//
//   int? _steps;
//   int? get steps => _steps;
//
//   bool _isScanning = false;
//   bool get isScanning => _isScanning;
//
//   final List<BluetoothDevice> _scanResults = [];
//   List<BluetoothDevice> get scanResults => _scanResults;
//
//   StreamSubscription? _scanSubscription;
//   StreamSubscription? _connectionStateSubscription;
//   StreamSubscription? _heartRateSubscription;
//   StreamSubscription? _stepsSubscription;
//
//   SmartwatchProvider() {
//     _initBluetooth();
//   }
//
//   void _initBluetooth() {
//     FlutterBluePlus.setLogLevel(LogLevel.verbose);
//
//     // Listen for Bluetooth adapter state changes
//     FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
//       if (state == BluetoothAdapterState.off) {
//         // Handle Bluetooth being turned off
//         _connectedDevice = null;
//         _heartRate = null;
//         _steps = null;
//         _scanResults.clear();
//         notifyListeners();
//         print("Bluetooth adapter is OFF");
//       } else if (state == BluetoothAdapterState.on) {
//         print("Bluetooth adapter is ON");
//       }
//     });
//   }
//
//   Future<void> startScan() async {
//     if (_isScanning) return;
//
//     _scanResults.clear();
//     _isScanning = true;
//     notifyListeners();
//
//     // Check if Bluetooth is supported on the device
//     if (!await FlutterBluePlus.isSupported) {
//       print("Bluetooth not supported by this device");
//       _isScanning = false;
//       notifyListeners();
//       return;
//     }
//
//     // Check if Bluetooth adapter is ON
//     if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
//       print("Bluetooth is not ON. Please turn on Bluetooth.");
//       // Optionally, you can prompt the user to turn on Bluetooth here
//       // await FlutterBluePlus.turnOn(); // This might require user interaction
//       _isScanning = false;
//       notifyListeners();
//       return;
//     }
//
//     // On Android, location services must be enabled for BLE scanning
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       if (!await FlutterBluePlus.isLocationOn) {
//         print("Location services are not enabled. Please enable them for BLE scanning.");
//         // Optionally, you can prompt the user to enable location services
//         // await FlutterBluePlus.turnOnLocationServices(); // This might require user interaction
//         _isScanning = false;
//         notifyListeners();
//         return;
//       }
//     }
//
//     _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult r in results) {
//         if (!_scanResults.any((device) => device.remoteId == r.device.remoteId)) {
//           _scanResults.add(r.device);
//           notifyListeners();
//           print('Found device: ${r.device.name} - ${r.device.remoteId}');
//         }
//       }
//     });
//
//     await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
//     _isScanning = false;
//     notifyListeners();
//     print("Scan finished.");
//   }
//
//   Future<void> stopScan() async {
//     await FlutterBluePlus.stopScan();
//     _isScanning = false;
//     notifyListeners();
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     if (_connectedDevice != null) {
//       await disconnect();
//     }
//
//     try {
//       await device.connect();
//       _connectedDevice = device;
//       notifyListeners();
//       print('Connected to ${device.name}');
//
//       _connectionStateSubscription = device.connectionState.listen((BluetoothConnectionState state) async {
//         if (state == BluetoothConnectionState.disconnected) {
//           print('Disconnected from ${device.name}');
//           _connectedDevice = null;
//           _heartRate = null;
//           _steps = null;
//           notifyListeners();
//           await _connectionStateSubscription?.cancel();
//           await _heartRateSubscription?.cancel();
//           await _stepsSubscription?.cancel();
//         }
//       });
//
//       await _discoverServices(device);
//     } catch (e) {
//       print('Failed to connect to device: $e');
//       _connectedDevice = null;
//       notifyListeners();
//     }
//   }
//
//   Future<void> disconnect() async {
//     if (_connectedDevice != null) {
//       try {
//         await _connectedDevice!.disconnect();
//       } catch (e) {
//         print('Error disconnecting: $e');
//       } finally {
//         _connectedDevice = null;
//         _heartRate = null;
//         _steps = null;
//         notifyListeners();
//         await _scanSubscription?.cancel(); // Also cancel scan subscription if active
//         await _connectionStateSubscription?.cancel();
//         await _heartRateSubscription?.cancel();
//         await _stepsSubscription?.cancel();
//       }
//     }
//   }
//
//   Future<void> _discoverServices(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       print('Service UUID: ${service.uuid}');
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         print('  Characteristic UUID: ${characteristic.uuid}');
//
//         // --- Heart Rate Service (Standard UUID: 0x180D) ---
//         // Heart Rate Measurement Characteristic (Standard UUID: 0x2A37)
//         if (characteristic.uuid.toString().toLowerCase() == '00002a37-0000-1000-8000-00805f9b34fb') {
//           if (characteristic.properties.notify) {
//             await characteristic.setNotifyValue(true);
//             _heartRateSubscription = characteristic.value.listen((value) {
//               if (value.isNotEmpty) {
//                 // Heart Rate Measurement characteristic format:
//                 // Byte 0: Flags (bit 0 indicates 8-bit or 16-bit heart rate value)
//                 // Byte 1: Heart Rate Value (8-bit)
//                 // If bit 0 of flags is 1, then it's 16-bit, and value is bytes 1 & 2
//                 int bpm = value[1]; // Assuming 8-bit value for simplicity
//                 _heartRate = bpm;
//                 notifyListeners();
//                 print('Heart Rate: $_heartRate BPM');
//               }
//             });
//             print('Subscribed to Heart Rate Characteristic');
//           } else if (characteristic.properties.read) {
//             List<int> value = await characteristic.read();
//             if (value.isNotEmpty) {
//               int bpm = value[1];
//               _heartRate = bpm;
//               notifyListeners();
//               print('Read Heart Rate: $_heartRate BPM');
//             }
//           }
//         }
//
//         // --- Example for Steps Characteristic (Common but not standard UUID) ---
//         // You will need to find the actual UUID for steps from your Caliber Buzz
//         // This is a placeholder UUID, replace with your actual steps characteristic UUID
//         if (characteristic.uuid.toString().toLowerCase() == '00002a53-0000-1000-8000-00805f9b34fb') { // Example: Cycling Power Measurement
//           if (characteristic.properties.notify) {
//             await characteristic.setNotifyValue(true);
//             _stepsSubscription = characteristic.value.listen((value) {
//               if (value.length >= 2) {
//                 // This is a placeholder for how steps might be encoded.
//                 // You'll need to reverse-engineer the actual byte format.
//                 int currentSteps = (value[1] << 8) | value[0]; // Example: assuming 16-bit little-endian
//                 _steps = currentSteps;
//                 notifyListeners();
//                 print('Steps: $_steps');
//               }
//             });
//             print('Subscribed to Steps Characteristic');
//           } else if (characteristic.properties.read) {
//             List<int> value = await characteristic.read();
//             if (value.length >= 2) {
//               int currentSteps = (value[1] << 8) | value[0];
//               _steps = currentSteps;
//               notifyListeners();
//               print('Read Steps: $_steps');
//             }
//           }
//         }
//         // Add more characteristics here for other data like sleep, etc.
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _scanSubscription?.cancel();
//     _connectionStateSubscription?.cancel();
//     _heartRateSubscription?.cancel();
//     _stepsSubscription?.cancel();
//     disconnect(); // Ensure disconnection on dispose
//     super.dispose();
//   }
// }

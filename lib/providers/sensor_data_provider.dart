import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fall_detection/models/fall_event.dart';
import 'package:fall_detection/services/ml_service.dart';
import 'package:fall_detection/services/notification_service.dart';
import 'package:fall_detection/services/sensor_service.dart';

class SensorDataProvider with ChangeNotifier {
  final SensorService _sensorService = SensorService();
  final MLService _mlService = MLService();
  final NotificationService _notificationService = NotificationService();

  bool _isMonitoring = false;
  bool _isFallDetected = false;
  bool _isDeviceConnected = false;
  
  String _accelerometerData = 'No data';
  String _gyroscopeData = 'No data';
  String _locationData = 'No data';
  
  String _monitoringStartTime = '';
  
  List<FallEvent> _recentFallEvents = [];

  // Getters
  bool get isMonitoring => _isMonitoring;
  bool get isFallDetected => _isFallDetected;
  bool get isDeviceConnected => _isDeviceConnected;
  
  bool get isAccelerometerAvailable => _sensorService.isAccelerometerAvailable;
  bool get isGyroscopeAvailable => _sensorService.isGyroscopeAvailable;
  bool get isLocationAvailable => _sensorService.isLocationAvailable;
  
  String get accelerometerData => _accelerometerData;
  String get gyroscopeData => _gyroscopeData;
  String get locationData => _locationData;
  
  String get monitoringStartTime => _monitoringStartTime;
  
  List<FallEvent> get recentFallEvents => _recentFallEvents;

  // Methods
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    await _sensorService.initialize();
    
    _isMonitoring = true;
    _monitoringStartTime = DateFormat('MMM dd, HH:mm').format(DateTime.now());
    
    _sensorService.startAccelerometerListener((x, y, z) {
      _accelerometerData = 'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}';
      _processSensorData(x, y, z);
      notifyListeners();
    });
    
    _sensorService.startGyroscopeListener((x, y, z) {
      _gyroscopeData = 'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}';
      notifyListeners();
    });
    
    _sensorService.startLocationListener((lat, lng) {
      _locationData = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
      notifyListeners();
    });
    
    notifyListeners();
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _sensorService.stopAccelerometerListener();
    _sensorService.stopGyroscopeListener();
    _sensorService.stopLocationListener();
    
    _isMonitoring = false;
    notifyListeners();
  }

  void _processSensorData(double x, double y, double z) async {
    if (!_isMonitoring || _isFallDetected) return;
    
    final isFall = await _mlService.detectFall(x, y, z);
    
    if (isFall) {
      _handleFallDetection();
    }
  }

  void _handleFallDetection() async {
    _isFallDetected = true;
    notifyListeners();
    
    // Get current location
    final location = await _sensorService.getCurrentLocation();
    final locationStr = location != null 
        ? '${location.latitude?.toStringAsFixed(6)}, ${location.longitude?.toStringAsFixed(6)}'
        : 'Unknown';
    
    // Create fall event
    final fallEvent = FallEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      location: locationStr,
      isFalseAlarm: false,
    );
    
    // Add to recent falls
    _recentFallEvents.insert(0, fallEvent);
    if (_recentFallEvents.length > 10) {
      _recentFallEvents.removeLast();
    }
    
    // Send notifications
    _notificationService.sendFallAlert(fallEvent);
    
    notifyListeners();
  }

  void resetFallDetection() {
    if (!_isFallDetected) return;
    
    // Mark the latest fall event as false alarm
    if (_recentFallEvents.isNotEmpty) {
      final latestEvent = _recentFallEvents.first;
      final updatedEvent = FallEvent(
        id: latestEvent.id,
        timestamp: latestEvent.timestamp,
        location: latestEvent.location,
        isFalseAlarm: true,
      );
      
      _recentFallEvents[0] = updatedEvent;
    }
    
    _isFallDetected = false;
    notifyListeners();
  }

  void triggerManualSOS() {
    _handleFallDetection();
  }

  Future<void> connectDevice() async {
    // Simulate connecting to a wearable device
    _isDeviceConnected = true;
    notifyListeners();
  }
}

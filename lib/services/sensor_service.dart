import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';

class SensorService {
  // Sensor availability flags
  bool _isAccelerometerAvailable = false;
  bool _isGyroscopeAvailable = false;
  bool _isLocationAvailable = false;
  
  // Sensor data streams
  Stream<AccelerometerEvent>? _accelerometerStream;
  Stream<GyroscopeEvent>? _gyroscopeStream;
  
  // Location service
  final Location _location = Location();
  
  // Sensor data listeners
  Function(double, double, double)? _accelerometerCallback;
  Function(double, double, double)? _gyroscopeCallback;
  Function(double, double)? _locationCallback;
  
  // Getters for sensor availability
  bool get isAccelerometerAvailable => _isAccelerometerAvailable;
  bool get isGyroscopeAvailable => _isGyroscopeAvailable;
  bool get isLocationAvailable => _isLocationAvailable;
  
  // Initialize sensors
  Future<void> initialize() async {
    try {
      // Check accelerometer availability
      _accelerometerStream = accelerometerEvents;
      _isAccelerometerAvailable = true;
    } catch (e) {
      print('Accelerometer not available: $e');
      _isAccelerometerAvailable = false;
    }
    
    try {
      // Check gyroscope availability
      _gyroscopeStream = gyroscopeEvents;
      _isGyroscopeAvailable = true;
    } catch (e) {
      print('Gyroscope not available: $e');
      _isGyroscopeAvailable = false;
    }
    
    try {
      // Check location availability
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _isLocationAvailable = false;
          return;
        }
      }
      
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _isLocationAvailable = false;
          return;
        }
      }
      
      _isLocationAvailable = true;
      
      // Configure location service
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // 10 seconds
      );
    } catch (e) {
      print('Location service not available: $e');
      _isLocationAvailable = false;
    }
  }
  
  // Start accelerometer listener
  void startAccelerometerListener(Function(double, double, double) callback) {
    if (!_isAccelerometerAvailable) return;
    
    _accelerometerCallback = callback;
    _accelerometerStream?.listen((AccelerometerEvent event) {
      if (_accelerometerCallback != null) {
        _accelerometerCallback!(event.x, event.y, event.z);
      }
    });
  }
  
  // Stop accelerometer listener
  void stopAccelerometerListener() {
    _accelerometerCallback = null;
  }
  
  // Start gyroscope listener
  void startGyroscopeListener(Function(double, double, double) callback) {
    if (!_isGyroscopeAvailable) return;
    
    _gyroscopeCallback = callback;
    _gyroscopeStream?.listen((GyroscopeEvent event) {
      if (_gyroscopeCallback != null) {
        _gyroscopeCallback!(event.x, event.y, event.z);
      }
    });
  }
  
  // Stop gyroscope listener
  void stopGyroscopeListener() {
    _gyroscopeCallback = null;
  }
  
  // Start location listener
  void startLocationListener(Function(double, double) callback) {
    if (!_isLocationAvailable) return;
    
    _locationCallback = callback;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_locationCallback != null && 
          currentLocation.latitude != null && 
          currentLocation.longitude != null) {
        _locationCallback!(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
    });
  }
  
  // Stop location listener
  void stopLocationListener() {
    _locationCallback = null;
  }
  
  // Get current location
  Future<LocationData?> getCurrentLocation() async {
    if (!_isLocationAvailable) return null;
    
    try {
      return await _location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}

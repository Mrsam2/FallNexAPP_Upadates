import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class HealthDataProvider with ChangeNotifier {
  // Simulated health data
  int _heartRate = 72;
  String _bloodPressure = '120/80';
  double _temperature = 36.8;
  String _overallHealth = 'Good';
  
  // Getters
  int get heartRate => _heartRate;
  String get bloodPressure => _bloodPressure;
  double get temperature => _temperature;
  String get overallHealth => _overallHealth;
  
  // Constructor that starts a timer to simulate changing health data
  HealthDataProvider() {
    // Simulate changing health data every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateHealthDataChanges();
    });
  }
  
  // Simulate small changes in health data
  void _simulateHealthDataChanges() {
    final random = Random();
    
    // Simulate heart rate changes (±3 beats per minute)
    _heartRate += random.nextInt(7) - 3;
    if (_heartRate < 60) _heartRate = 60;
    if (_heartRate > 100) _heartRate = 100;
    
    // Simulate blood pressure changes
    final systolic = int.parse(_bloodPressure.split('/')[0]);
    final diastolic = int.parse(_bloodPressure.split('/')[1]);
    final newSystolic = systolic + (random.nextInt(5) - 2);
    final newDiastolic = diastolic + (random.nextInt(3) - 1);
    _bloodPressure = '$newSystolic/$newDiastolic';
    
    // Simulate temperature changes (±0.2°C)
    _temperature += (random.nextDouble() * 0.4 - 0.2);
    _temperature = double.parse(_temperature.toStringAsFixed(1));
    
    // Update overall health based on values
    _updateOverallHealth();
    
    notifyListeners();
  }
  
  // Update overall health status based on current values
  void _updateOverallHealth() {
    if (_heartRate < 60 || _heartRate > 100 ||
        _temperature < 36.0 || _temperature > 37.5) {
      _overallHealth = 'Fair';
    } else {
      _overallHealth = 'Good';
    }
  }
  
  // Method to be called when fall is detected to check if health data indicates an emergency
  bool checkHealthEmergency() {
    return _heartRate > 100 || _temperature > 38.0;
  }
}

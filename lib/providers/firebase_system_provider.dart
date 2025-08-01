import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firebase_service.dart';

class FirebaseSystemProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // System status monitoring based on Firebase data
  bool _isSystemActive = false;
  DateTime? _lastFirebaseDataReceived;
  Map<String, dynamic>? _latestFirebaseData;
  Timer? _systemStatusTimer;
  Timer? _immediateCheckTimer;
  static const Duration _dataTimeout = Duration(seconds: 10); // Very short timeout for immediate response
  static const Duration _checkInterval = Duration(seconds: 1); // Check every second

  // Getters
  bool get isSystemActive => _isSystemActive;
  DateTime? get lastFirebaseDataReceived => _lastFirebaseDataReceived;
  Map<String, dynamic>? get latestFirebaseData => _latestFirebaseData;

  FirebaseSystemProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _firebaseService.initialize();

    // Listen to Firebase real-time data stream
    _firebaseService.realtimeDataStream.listen((data) {
      _latestFirebaseData = data;
      _lastFirebaseDataReceived = DateTime.now();

      // Immediately set system as active
      if (!_isSystemActive) {
        _updateSystemStatus(true);
        print('🟢 System IMMEDIATELY ACTIVE - Firebase data received');
      }

      notifyListeners();

      // Cancel any pending immediate check
      _immediateCheckTimer?.cancel();

      // Schedule immediate check after expected timeout
      _immediateCheckTimer = Timer(_dataTimeout + Duration(seconds: 1), () {
        _checkSystemStatus();
        print('⏰ Immediate timeout check triggered');
      });
    });

    // Start very frequent system status monitoring
    _startSystemStatusMonitoring();
  }

  void _startSystemStatusMonitoring() {
    _systemStatusTimer = Timer.periodic(_checkInterval, (timer) {
      _checkSystemStatus();
    });
  }

  void _checkSystemStatus() {
    if (_lastFirebaseDataReceived == null) {
      _updateSystemStatus(false);
      return;
    }

    final timeSinceLastData = DateTime.now().difference(_lastFirebaseDataReceived!);
    final shouldBeActive = timeSinceLastData < _dataTimeout;

    if (_isSystemActive != shouldBeActive) {
      _updateSystemStatus(shouldBeActive);
      if (shouldBeActive) {
        print('🟢 System status: ACTIVE (data within ${timeSinceLastData.inSeconds}s)');
      } else {
        print('🔴 System status: INACTIVE (no data for ${timeSinceLastData.inSeconds}s)');
      }
    }
  }

  void _updateSystemStatus(bool isActive) {
    if (_isSystemActive != isActive) {
      _isSystemActive = isActive;
      notifyListeners();
    }
  }

  String getSystemStatusMessage() {
    if (_lastFirebaseDataReceived == null) {
      return 'Waiting for real-time data from Firebase...';
    } else if (_isSystemActive) {
      final timeSinceLastData = DateTime.now().difference(_lastFirebaseDataReceived!);
      return 'System ACTIVE - last data ${timeSinceLastData.inSeconds}s ago';
    } else {
      final timeSinceLastData = DateTime.now().difference(_lastFirebaseDataReceived!);
      if (timeSinceLastData.inSeconds < 30) {
        return '⚠️ System OFFLINE - stopped ${timeSinceLastData.inSeconds}s ago';
      } else {
        return '❌ System OFFLINE - no data for ${timeSinceLastData.inSeconds}s';
      }
    }
  }

  String getDetailedSystemStatus() {
    if (_isSystemActive && _lastFirebaseDataReceived != null) {
      final timeSinceLastData = DateTime.now().difference(_lastFirebaseDataReceived!);
      return '✅ Active - ${timeSinceLastData.inSeconds}s ago';
    } else if (_lastFirebaseDataReceived != null) {
      final timeSinceLastData = DateTime.now().difference(_lastFirebaseDataReceived!);
      return '❌ Offline - ${timeSinceLastData.inSeconds}s ago';
    } else {
      return '⏳ Waiting for first data...';
    }
  }

  String getLatestDataInfo() {
    if (_latestFirebaseData == null) return 'No data received yet';

    String dataStr = _latestFirebaseData!['data']?.toString() ?? 'No sensor data';
    String deviceId = _latestFirebaseData!['device_id']?.toString() ?? 'Unknown';
    int timestamp = _latestFirebaseData!['timestamp'] ?? 0;

    return 'Device: $deviceId\nData: $dataStr\nTimestamp: $timestamp';
  }

  // Method to manually trigger immediate status check
  void forceStatusCheck() {
    _checkSystemStatus();
    print('🔄 Manual status check triggered');
  }

  @override
  void dispose() {
    _systemStatusTimer?.cancel();
    _immediateCheckTimer?.cancel();
    _firebaseService.dispose();
    super.dispose();
  }
}

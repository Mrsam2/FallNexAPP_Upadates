import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../models/fall_event.dart';
import '../services/notification_service.dart';

class EnhancedFallDetectionService {
  static final EnhancedFallDetectionService _instance = EnhancedFallDetectionService._internal();
  factory EnhancedFallDetectionService() => _instance;
  EnhancedFallDetectionService._internal() {
    _fallDetectionController = StreamController<bool>.broadcast();
    _fallCountController = StreamController<int>.broadcast();
    _fallEventsController = StreamController<List<FallEvent>>.broadcast();
    _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
    _alertLevelController = StreamController<String>.broadcast();
  }

  static const MethodChannel _channel = MethodChannel('fall_detection_ml');

  late DatabaseReference _database;
  final NotificationService _notificationService = NotificationService();

  bool _isModelLoaded = false;
  bool _isInitialized = false;
  int _fallCount = 0;
  int _minorAlertCount = 0;
  int _basicAlertCount = 0;
  int _highAlertCount = 0;
  List<FallEvent> _recentFalls = [];
  Map<String, dynamic>? _latestSensorData;
  String _currentAlertLevel = 'NONE';

  // Enhanced detection parameters with tiered thresholds
  List<Map<String, dynamic>> _sensorHistory = [];
  static const int HISTORY_SIZE = 5;

  // Tiered Alert Thresholds
  static const double MINOR_THRESHOLD = 0.75;  // 75% - Count only
  static const double BASIC_THRESHOLD = 0.80;  // 80% - Minor alert
  static const double HIGH_THRESHOLD = 0.90;   // 90% - High alert

  // Streams
  StreamController<bool>? _fallDetectionController;
  StreamController<int>? _fallCountController;
  StreamController<List<FallEvent>>? _fallEventsController;
  StreamController<Map<String, dynamic>>? _sensorDataController;
  StreamController<String>? _alertLevelController;

  // Getters
  Stream<bool> get fallDetectionStream => _fallDetectionController?.stream ?? Stream.empty();
  Stream<int> get fallCountStream => _fallCountController?.stream ?? Stream.empty();
  Stream<List<FallEvent>> get fallEventsStream => _fallEventsController?.stream ?? Stream.empty();
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController?.stream ?? Stream.empty();
  Stream<String> get alertLevelStream => _alertLevelController?.stream ?? Stream.empty();

  bool get isModelLoaded => _isModelLoaded;
  int get fallCount => _fallCount;
  int get minorAlertCount => _minorAlertCount;
  int get basicAlertCount => _basicAlertCount;
  int get highAlertCount => _highAlertCount;
  List<FallEvent> get recentFalls => _recentFalls;
  Map<String, dynamic>? get latestSensorData => _latestSensorData;
  String get currentAlertLevel => _currentAlertLevel;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://fall-detection-1851d-default-rtdb.firebaseio.com/'
      ).ref();

      await _notificationService.initialize();
      await _initializeEnhancedModel();
      _startRealtimeDataListener();

      _isInitialized = true;
      print('✅ Enhanced Tiered Fall Detection Service initialized');
    } catch (e) {
      print('❌ Error initializing Enhanced Fall Detection Service: $e');
      throw e;
    }
  }

  Future<void> _initializeEnhancedModel() async {
    try {
      final result = await _channel.invokeMethod('initializeModel', {
        'modelName': 'Enhanced_Fall_Detection',
      });

      _isModelLoaded = result['success'] == true;
      print('🤖 Enhanced ML Model loaded: $_isModelLoaded');
    } catch (e) {
      _isModelLoaded = false;
      print('❌ Enhanced ML Model failed to load: $e');
    }
  }

  void _startRealtimeDataListener() {
    _database.child('devices/001/latest_data').onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        try {
          Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
          print('🔥 Firebase data received: ${data['data']}');
          _processSensorData(data);
        } catch (e) {
          print('❌ Error processing Firebase data: $e');
        }
      }
    });
  }

  Future<void> _processSensorData(Map<String, dynamic> data) async {
    try {
      String? dataString = data['data']?.toString();
      if (dataString == null || dataString.isEmpty) {
        print('⚠️ No data string found');
        return;
      }

      List<String> values = dataString.split(',');

      if (values.length < 14) {
        print('⚠️ Insufficient data values: ${values.length}');
        return;
      }

      // Parse sensor data
      Map<String, dynamic> processedData = {
        'device_id': values[0].trim(),
        'timestamp': int.tryParse(values[1].trim()) ?? DateTime.now().millisecondsSinceEpoch,

        'AX1': _parseDouble(values[2]),
        'AY1': _parseDouble(values[3]),
        'AZ1': _parseDouble(values[4]),
        'RX1': _parseDouble(values[5]),
        'RY1': _parseDouble(values[6]),
        'RZ1': _parseDouble(values[7]),

        'AX2': _parseDouble(values[8]),
        'AY2': _parseDouble(values[9]),
        'AZ2': _parseDouble(values[10]),
        'RX2': _parseDouble(values[11]),
        'RY2': _parseDouble(values[12]),
        'RZ2': _parseDouble(values[13]),
      };

      _calculateEnhancedFeatures(processedData);

      print('📊 Processed Data: Device=${processedData['device_id']}, '
          'Mag1=${processedData['magnitude1']?.toStringAsFixed(2)}, '
          'Mag2=${processedData['magnitude2']?.toStringAsFixed(2)}, '
          'TotalAccel=${processedData['total_acceleration']?.toStringAsFixed(2)}');

      _latestSensorData = processedData;
      _sensorDataController?.add(processedData);

      _sensorHistory.add(processedData);
      if (_sensorHistory.length > HISTORY_SIZE) {
        _sensorHistory.removeAt(0);
      }

      await _tieredFallDetection(processedData);

    } catch (e) {
      print('❌ Error processing sensor data: $e');
    }
  }

  void _calculateEnhancedFeatures(Map<String, dynamic> data) {
    double ax1 = data['AX1'] ?? 0.0;
    double ay1 = data['AY1'] ?? 0.0;
    double az1 = data['AZ1'] ?? 0.0;
    double ax2 = data['AX2'] ?? 0.0;
    double ay2 = data['AY2'] ?? 0.0;
    double az2 = data['AZ2'] ?? 0.0;

    data['magnitude1'] = sqrt(ax1*ax1 + ay1*ay1 + az1*az1);
    data['magnitude2'] = sqrt(ax2*ax2 + ay2*ay2 + az2*az2);

    data['total_acceleration'] = sqrt(
        pow(ax1 + ax2, 2) + pow(ay1 + ay2, 2) + pow(az1 + az2, 2)
    );

    double rx1 = data['RX1'] ?? 0.0;
    double ry1 = data['RY1'] ?? 0.0;
    double rz1 = data['RZ1'] ?? 0.0;
    double rx2 = data['RX2'] ?? 0.0;
    double ry2 = data['RY2'] ?? 0.0;
    double rz2 = data['RZ2'] ?? 0.0;

    data['gyro_magnitude1'] = sqrt(rx1*rx1 + ry1*ry1 + rz1*rz1);
    data['gyro_magnitude2'] = sqrt(rx2*rx2 + ry2*ry2 + rz2*rz2);

    data['motion_intensity'] = data['magnitude1'] + data['magnitude2'] +
        data['gyro_magnitude1'] + data['gyro_magnitude2'];
  }

  Future<void> _tieredFallDetection(Map<String, dynamic> sensorData) async {
    try {
      double fallProbability = 0.0;

      if (_isModelLoaded) {
        final result = await _runEnhancedMLInference(sensorData);
        fallProbability = result['probability'] ?? 0.0;
      } else {
        final result = _enhancedRuleBasedDetection(sensorData);
        fallProbability = result['probability'] ?? 0.0;
      }

      // Determine alert level based on probability
      String alertLevel = _determineAlertLevel(fallProbability);

      print('🎯 Tiered Detection: Prob=${(fallProbability * 100).toStringAsFixed(1)}%, Level=$alertLevel');

      // Handle different alert levels
      await _handleTieredAlert(alertLevel, fallProbability, sensorData);

      _currentAlertLevel = alertLevel;
      _alertLevelController?.add(alertLevel);
      _fallDetectionController?.add(alertLevel != 'NONE');

    } catch (e) {
      print('❌ Error in tiered fall detection: $e');
    }
  }

  String _determineAlertLevel(double probability) {
    if (probability >= HIGH_THRESHOLD) {
      return 'HIGH';        // 90%+ - High Alert
    } else if (probability >= BASIC_THRESHOLD) {
      return 'BASIC';       // 80%+ - Basic Alert
    } else if (probability >= MINOR_THRESHOLD) {
      return 'MINOR';       // 75%+ - Minor Alert (Count only)
    } else {
      return 'NONE';        // Below 75% - No alert
    }
  }

  Future<void> _handleTieredAlert(String alertLevel, double probability, Map<String, dynamic> sensorData) async {
    try {
      switch (alertLevel) {
        case 'HIGH':
          _highAlertCount++;
          _basicAlertCount++;
          _minorAlertCount++;
          _fallCount++;
          await _createFallEvent('HIGH', probability, sensorData);
          await _notificationService.showHighAlertNotification();
          print('🚨 HIGH ALERT! Probability: ${(probability * 100).toStringAsFixed(1)}%');
          break;

        case 'BASIC':
          _basicAlertCount++;
          _minorAlertCount++;
          _fallCount++;
          await _createFallEvent('BASIC', probability, sensorData);
          await _notificationService.showBasicAlertNotification();
          print('⚠️ BASIC ALERT! Probability: ${(probability * 100).toStringAsFixed(1)}%');
          break;

        case 'MINOR':
          _minorAlertCount++;
          _fallCount++;
          await _createFallEvent('MINOR', probability, sensorData);
          print('📊 MINOR ALERT (Count Only): ${(probability * 100).toStringAsFixed(1)}%');
          break;

        case 'NONE':
        // No action needed
          break;
      }

      // Update counters
      _fallCountController?.add(_fallCount);

    } catch (e) {
      print('❌ Error handling tiered alert: $e');
    }
  }

  Future<void> _createFallEvent(String alertLevel, double probability, Map<String, dynamic> sensorData) async {
    try {
      FallEvent fallEvent = FallEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        location: 'Device: ${sensorData['device_id']} - $alertLevel Alert',
        probability: probability,
        isFalseAlarm: false,
      );

      _recentFalls.insert(0, fallEvent);
      if (_recentFalls.length > 20) { // Keep more events for tiered system
        _recentFalls.removeLast();
      }

      await _storeTieredFallEvent(fallEvent, alertLevel, sensorData);
      _fallEventsController?.add(List.from(_recentFalls));

    } catch (e) {
      print('❌ Error creating fall event: $e');
    }
  }

  Future<Map<String, dynamic>> _runEnhancedMLInference(Map<String, dynamic> sensorData) async {
    try {
      List<double> inputData = [
        sensorData['AX1'] ?? 0.0, sensorData['AY1'] ?? 0.0, sensorData['AZ1'] ?? 0.0,
        sensorData['RX1'] ?? 0.0, sensorData['RY1'] ?? 0.0, sensorData['RZ1'] ?? 0.0,
        sensorData['AX2'] ?? 0.0, sensorData['AY2'] ?? 0.0, sensorData['AZ2'] ?? 0.0,
        sensorData['RX2'] ?? 0.0, sensorData['RY2'] ?? 0.0, sensorData['RZ2'] ?? 0.0,
        sensorData['magnitude1'] ?? 0.0, sensorData['magnitude2'] ?? 0.0,
        sensorData['total_acceleration'] ?? 0.0, sensorData['gyro_magnitude1'] ?? 0.0,
        sensorData['gyro_magnitude2'] ?? 0.0, sensorData['motion_intensity'] ?? 0.0,
      ];

      final result = await _channel.invokeMethod('runEnhancedInference', {
        'inputData': inputData,
      });

      if (result['success'] == true) {
        double probability = result['probability'] ?? 0.0;
        return {
          'probability': probability,
          'method': 'enhanced_ml_model'
        };
      } else {
        return _enhancedRuleBasedDetection(sensorData);
      }
    } catch (e) {
      return _enhancedRuleBasedDetection(sensorData);
    }
  }

  Map<String, dynamic> _enhancedRuleBasedDetection(Map<String, dynamic> sensorData) {
    try {
      double magnitude1 = sensorData['magnitude1'] ?? 0.0;
      double magnitude2 = sensorData['magnitude2'] ?? 0.0;
      double totalAccel = sensorData['total_acceleration'] ?? 0.0;
      double motionIntensity = sensorData['motion_intensity'] ?? 0.0;
      double gyroMag1 = sensorData['gyro_magnitude1'] ?? 0.0;
      double gyroMag2 = sensorData['gyro_magnitude2'] ?? 0.0;

      // Enhanced criteria for tiered detection
      bool highAcceleration = magnitude1 > 6.0 || magnitude2 > 6.0;  // Lowered for sensitivity
      bool highTotalAccel = totalAccel > 8.0;
      bool highMotionIntensity = motionIntensity > 12.0;
      bool highRotation = gyroMag1 > 4.0 || gyroMag2 > 4.0;

      // Pattern analysis
      bool suddenMovementPattern = false;
      if (_sensorHistory.length >= 2) {
        Map<String, dynamic> prevData = _sensorHistory[_sensorHistory.length - 2];
        double prevMagnitude1 = prevData['magnitude1'] ?? 0.0;
        double prevMagnitude2 = prevData['magnitude2'] ?? 0.0;

        double accelChange1 = (magnitude1 - prevMagnitude1).abs();
        double accelChange2 = (magnitude2 - prevMagnitude2).abs();

        suddenMovementPattern = accelChange1 > 3.0 || accelChange2 > 3.0;
      }

      // Axis-specific analysis
      double ax1 = sensorData['AX1'] ?? 0.0;
      double ay1 = sensorData['AY1'] ?? 0.0;
      double az1 = sensorData['AZ1'] ?? 0.0;
      double ax2 = sensorData['AX2'] ?? 0.0;
      double ay2 = sensorData['AY2'] ?? 0.0;
      double az2 = sensorData['AZ2'] ?? 0.0;

      bool significantAxisMovement = ax1.abs() > 4.0 || ay1.abs() > 4.0 || az1.abs() > 4.0 ||
          ax2.abs() > 4.0 || ay2.abs() > 4.0 || az2.abs() > 4.0;

      // Calculate probability based on multiple factors
      double probability = 0.0;

      if (highAcceleration || highTotalAccel || highMotionIntensity ||
          (highRotation && significantAxisMovement) || suddenMovementPattern) {

        double accelScore = min((max(magnitude1, magnitude2)) / 15.0, 1.0);
        double motionScore = min(motionIntensity / 25.0, 1.0);
        double gyroScore = min((max(gyroMag1, gyroMag2)) / 8.0, 1.0);
        double axisScore = min((max(max(ax1.abs(), ay1.abs()), max(ax2.abs(), ay2.abs()))) / 12.0, 1.0);
        double patternScore = suddenMovementPattern ? 0.3 : 0.0;

        probability = (accelScore + motionScore + gyroScore + axisScore + patternScore) / 5.0;
        probability = max(probability, 0.2); // Minimum probability for detected movement
      }

      print('📏 Tiered Rule Analysis:');
      print('   Mag1=${magnitude1.toStringAsFixed(2)}, Mag2=${magnitude2.toStringAsFixed(2)}');
      print('   Motion=${motionIntensity.toStringAsFixed(2)}, Gyro1=${gyroMag1.toStringAsFixed(2)}');
      print('   Criteria: HighAccel=$highAcceleration, HighMotion=$highMotionIntensity');
      print('   Result: Prob=${(probability * 100).toStringAsFixed(1)}%');

      return {
        'probability': probability,
        'method': 'enhanced_rule_based'
      };
    } catch (e) {
      return {'probability': 0.0, 'method': 'enhanced_rule_based'};
    }
  }

  Future<void> _storeTieredFallEvent(FallEvent fallEvent, String alertLevel, Map<String, dynamic> sensorData) async {
    try {
      await _database.child('fall_events').child(fallEvent.id).set({
        'timestamp': fallEvent.timestamp.millisecondsSinceEpoch,
        'location': fallEvent.location,
        'probability': fallEvent.probability,
        'alert_level': alertLevel,
        'isFalseAlarm': fallEvent.isFalseAlarm,
        'device_id': sensorData['device_id'],
        'detection_method': _isModelLoaded ? 'enhanced_ml_model' : 'enhanced_rule_based',

        'sensor_data': {
          'AX1': sensorData['AX1'], 'AY1': sensorData['AY1'], 'AZ1': sensorData['AZ1'],
          'RX1': sensorData['RX1'], 'RY1': sensorData['RY1'], 'RZ1': sensorData['RZ1'],
          'AX2': sensorData['AX2'], 'AY2': sensorData['AY2'], 'AZ2': sensorData['AZ2'],
          'RX2': sensorData['RX2'], 'RY2': sensorData['RY2'], 'RZ2': sensorData['RZ2'],
          'magnitude1': sensorData['magnitude1'], 'magnitude2': sensorData['magnitude2'],
          'total_acceleration': sensorData['total_acceleration'],
          'motion_intensity': sensorData['motion_intensity'],
        }
      });
    } catch (e) {
      print('❌ Error storing tiered fall event: $e');
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.trim();
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> markFallAsFalseAlarm(String fallId) async {
    try {
      await _database.child('fall_events').child(fallId).update({
        'isFalseAlarm': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      int index = _recentFalls.indexWhere((fall) => fall.id == fallId);
      if (index != -1) {
        _recentFalls[index] = FallEvent(
          id: _recentFalls[index].id,
          timestamp: _recentFalls[index].timestamp,
          location: _recentFalls[index].location,
          probability: _recentFalls[index].probability,
          isFalseAlarm: true,
        );
        _fallEventsController?.add(List.from(_recentFalls));
      }

      await _notificationService.cancelFallAlert();
    } catch (e) {
      print('❌ Error marking fall as false alarm: $e');
    }
  }

  void resetFallCount() {
    _fallCount = 0;
    _minorAlertCount = 0;
    _basicAlertCount = 0;
    _highAlertCount = 0;
    _fallCountController?.add(_fallCount);
  }

  String getTieredStatusSummary() {
    return '''
Total Events: $_fallCount
Minor Alerts (75%+): $_minorAlertCount
Basic Alerts (80%+): $_basicAlertCount  
High Alerts (90%+): $_highAlertCount
Current Level: $_currentAlertLevel
''';
  }

  void dispose() {
    _fallDetectionController?.close();
    _fallCountController?.close();
    _fallEventsController?.close();
    _sensorDataController?.close();
    _alertLevelController?.close();
  }
}

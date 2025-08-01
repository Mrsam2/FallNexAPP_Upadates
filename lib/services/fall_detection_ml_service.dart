import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../models/fall_event.dart';
import '../services/notification_service.dart';

class FallDetectionMLService {
  static final FallDetectionMLService _instance = FallDetectionMLService._internal();
  factory FallDetectionMLService() => _instance;
  FallDetectionMLService._internal() {
    // Initialize stream controllers immediately to prevent null access
    _fallDetectionController = StreamController<bool>.broadcast();
    _fallCountController = StreamController<int>.broadcast();
    _fallEventsController = StreamController<List<FallEvent>>.broadcast();
    _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  }

  static const MethodChannel _channel = MethodChannel('fall_detection_ml');

  late DatabaseReference _database;
  final NotificationService _notificationService = NotificationService();

  bool _isModelLoaded = false;
  bool _isInitialized = false;
  int _fallCount = 0;
  List<FallEvent> _recentFalls = [];
  Map<String, dynamic>? _latestSensorData;

  // Data processing - Store pairs of sensor readings for ML model
  List<Map<String, dynamic>> _sensorDataBuffer = [];
  static const int BUFFER_SIZE = 2; // We need pairs of readings (AX1,AY1,AZ1... and AX2,AY2,AZ2...)
  static const double FALL_THRESHOLD = 0.7;

  // Streams
  StreamController<bool>? _fallDetectionController;
  StreamController<int>? _fallCountController;
  StreamController<List<FallEvent>>? _fallEventsController;
  StreamController<Map<String, dynamic>>? _sensorDataController;

  // Getters - Make them null-safe
  Stream<bool> get fallDetectionStream => _fallDetectionController?.stream ?? Stream.empty();
  Stream<int> get fallCountStream => _fallCountController?.stream ?? Stream.empty();
  Stream<List<FallEvent>> get fallEventsStream => _fallEventsController?.stream ?? Stream.empty();
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController?.stream ?? Stream.empty();
  bool get isModelLoaded => _isModelLoaded;
  int get fallCount => _fallCount;
  List<FallEvent> get recentFalls => _recentFalls;
  Map<String, dynamic>? get latestSensorData => _latestSensorData;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase Database
      _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://fall-detection-1851d-default-rtdb.firebaseio.com/'
      ).ref();

      // Initialize streams
      //_fallDetectionController = StreamController<bool>.broadcast();
      //_fallCountController = StreamController<int>.broadcast();
      //_fallEventsController = StreamController<List<FallEvent>>.broadcast();
      //_sensorDataController = StreamController<Map<String, dynamic>>.broadcast();

      // Initialize notification service
      await _notificationService.initialize();

      // Initialize ML model
      await _initializeMLModel();

      // Start listening to real-time sensor data
      _startRealtimeDataListener();

      _isInitialized = true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _initializeMLModel() async {
    try {

      // Call native Android code to initialize Firebase ML model
      final result = await _channel.invokeMethod('initializeModel', {
        'modelName': 'Fall_Detection', // Your Firebase ML model name
      });

      if (result['success'] == true) {
        _isModelLoaded = true;
      } else {
        _isModelLoaded = false;
      }
    } catch (e) {
      _isModelLoaded = false;
    }
  }

  void _startRealtimeDataListener() {
    // Listen to real-time sensor data from Firebase - updated path
    _database.child('devices/001/latest_data').onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        try {
          Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
          _processSensorData(data);
        } catch (e) {
        }
      }
    });
  }

  Future<void> _processSensorData(Map<String, dynamic> data) async {
    try {
      String? dataString = data['data']?.toString();
      if (dataString == null || dataString.isEmpty) {
        return;
      }

      List<String> values = dataString.split(',');

      if (values.length < 14) {
        return;
      }

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

      processedData['magnitude1'] = sqrt(
          pow(processedData['AX1'], 2) +
              pow(processedData['AY1'], 2) +
              pow(processedData['AZ1'], 2)
      );

      processedData['magnitude2'] = sqrt(
          pow(processedData['AX2'], 2) +
              pow(processedData['AY2'], 2) +
              pow(processedData['AZ2'], 2)
      );

      _latestSensorData = processedData;
      _sensorDataController?.add(processedData);

      _sensorDataBuffer.add(processedData);
      if (_sensorDataBuffer.length > BUFFER_SIZE) {
        _sensorDataBuffer.removeAt(0);
      }

      await _detectFall(processedData);

    } catch (e) {
      // Silent error handling
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

  Future<void> _detectFall(Map<String, dynamic> sensorData) async {
    try {
      bool isFallDetected = false;
      double fallProbability = 0.0;

      if (_isModelLoaded) {
        final result = await _runMLInference(sensorData);
        isFallDetected = result['isFall'] ?? false;
        fallProbability = result['probability'] ?? 0.0;
      } else {
        final result = _ruleBasedFallDetection(sensorData);
        isFallDetected = result['isFall'] ?? false;
        fallProbability = result['probability'] ?? 0.0;
      }

      _fallDetectionController?.add(isFallDetected);

      if (isFallDetected) {
        await _handleFallDetected(fallProbability, sensorData);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<Map<String, dynamic>> _runMLInference(Map<String, dynamic> sensorData) async {
    try {
      List<double> inputData = [
        sensorData['AX1'] ?? 0.0,
        sensorData['AY1'] ?? 0.0,
        sensorData['AZ1'] ?? 0.0,
        sensorData['RX1'] ?? 0.0,
        sensorData['RY1'] ?? 0.0,
        sensorData['RZ1'] ?? 0.0,
        sensorData['AX2'] ?? 0.0,
        sensorData['AY2'] ?? 0.0,
        sensorData['AZ2'] ?? 0.0,
        sensorData['RX2'] ?? 0.0,
        sensorData['RY2'] ?? 0.0,
        sensorData['RZ2'] ?? 0.0,
      ];

      final result = await _channel.invokeMethod('runInference', {
        'inputData': inputData,
      });

      if (result['success'] == true) {
        double probability = result['probability'] ?? 0.0;
        bool isFall = probability > FALL_THRESHOLD;

        return {
          'isFall': isFall,
          'probability': probability,
          'method': 'ml_model'
        };
      } else {
        return _ruleBasedFallDetection(sensorData);
      }
    } catch (e) {
      return _ruleBasedFallDetection(sensorData);
    }
  }

  Map<String, dynamic> _ruleBasedFallDetection(Map<String, dynamic> sensorData) {
    try {
      double magnitude1 = sensorData['magnitude1'] ?? 0.0;
      double magnitude2 = sensorData['magnitude2'] ?? 0.0;

      double ax1 = sensorData['AX1'] ?? 0.0;
      double ay1 = sensorData['AY1'] ?? 0.0;
      double az1 = sensorData['AZ1'] ?? 0.0;
      double ax2 = sensorData['AX2'] ?? 0.0;
      double ay2 = sensorData['AY2'] ?? 0.0;
      double az2 = sensorData['AZ2'] ?? 0.0;

      bool highAccel1 = magnitude1 > 15.0;
      bool highAccel2 = magnitude2 > 15.0;

      double magnitudeDiff = (magnitude1 - magnitude2).abs();
      bool significantChange = magnitudeDiff > 5.0;

      double axDiff = (ax1 - ax2).abs();
      double ayDiff = (ay1 - ay2).abs();
      double azDiff = (az1 - az2).abs();
      bool suddenChange = axDiff > 8.0 || ayDiff > 8.0 || azDiff > 8.0;

      bool isFall = (highAccel1 || highAccel2) || significantChange || suddenChange;
      double probability = 0.0;

      if (isFall) {
        double maxMagnitude = max(magnitude1, magnitude2);
        double maxAxisChange = max(max(axDiff, ayDiff), azDiff);
        probability = min((maxMagnitude + magnitudeDiff + maxAxisChange) / 40.0, 1.0);
      }

      return {
        'isFall': isFall,
        'probability': probability,
        'method': 'rule_based'
      };
    } catch (e) {
      return {'isFall': false, 'probability': 0.0, 'method': 'rule_based'};
    }
  }

  Future<void> _handleFallDetected(double probability, Map<String, dynamic> sensorData) async {
    try {
      _fallCount++;

      FallEvent fallEvent = FallEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        location: 'Device: ${sensorData['device_id']}',
        probability: probability,
        isFalseAlarm: false,
      );

      _recentFalls.insert(0, fallEvent);
      if (_recentFalls.length > 10) {
        _recentFalls.removeLast();
      }

      await _storeFallEvent(fallEvent, sensorData);
      await _notificationService.showFallDetectionNotification();

      _fallCountController?.add(_fallCount);
      _fallEventsController?.add(List.from(_recentFalls));
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _storeFallEvent(FallEvent fallEvent, Map<String, dynamic> sensorData) async {
    try {
      await _database.child('fall_events').child(fallEvent.id).set({
        'timestamp': fallEvent.timestamp.millisecondsSinceEpoch,
        'location': fallEvent.location,
        'probability': fallEvent.probability,
        'isFalseAlarm': fallEvent.isFalseAlarm,
        'device_id': sensorData['device_id'],
        'detection_method': _isModelLoaded ? 'ml_model' : 'rule_based',

        // Store the sensor data that triggered the fall detection
        'sensor_data': {
          'AX1': sensorData['AX1'],
          'AY1': sensorData['AY1'],
          'AZ1': sensorData['AZ1'],
          'RX1': sensorData['RX1'],
          'RY1': sensorData['RY1'],
          'RZ1': sensorData['RZ1'],
          'AX2': sensorData['AX2'],
          'AY2': sensorData['AY2'],
          'AZ2': sensorData['AZ2'],
          'RX2': sensorData['RX2'],
          'RY2': sensorData['RY2'],
          'RZ2': sensorData['RZ2'],
          'magnitude1': sensorData['magnitude1'],
          'magnitude2': sensorData['magnitude2'],
        }
      });
    } catch (e) {
      print('❌ Error storing fall event: $e');
    }
  }

  Future<void> markFallAsFalseAlarm(String fallId) async {
    try {
      // Update in database
      await _database.child('fall_events').child(fallId).update({
        'isFalseAlarm': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local list
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

      // Cancel notification
      await _notificationService.cancelFallAlert();
    } catch (e) {
      print('❌ Error marking fall as false alarm: $e');
    }
  }

  void resetFallCount() {
    _fallCount = 0;
    _fallCountController?.add(_fallCount);
  }

  String getSensorDataSummary() {
    if (_latestSensorData == null) return 'No sensor data received';

    return '''
Device: ${_latestSensorData!['device_id']}
Timestamp: ${_latestSensorData!['timestamp']}

Accelerometer 1: (${_latestSensorData!['AX1']?.toStringAsFixed(2)}, ${_latestSensorData!['AY1']?.toStringAsFixed(2)}, ${_latestSensorData!['AZ1']?.toStringAsFixed(2)})
Gyroscope 1: (${_latestSensorData!['RX1']?.toStringAsFixed(2)}, ${_latestSensorData!['RY1']?.toStringAsFixed(2)}, ${_latestSensorData!['RZ1']?.toStringAsFixed(2)})

Accelerometer 2: (${_latestSensorData!['AX2']?.toStringAsFixed(2)}, ${_latestSensorData!['AY2']?.toStringAsFixed(2)}, ${_latestSensorData!['AZ2']?.toStringAsFixed(2)})
Gyroscope 2: (${_latestSensorData!['RX2']?.toStringAsFixed(2)}, ${_latestSensorData!['RY2']?.toStringAsFixed(2)}, ${_latestSensorData!['RZ2']?.toStringAsFixed(2)})

Magnitude 1: ${_latestSensorData!['magnitude1']?.toStringAsFixed(2)}
Magnitude 2: ${_latestSensorData!['magnitude2']?.toStringAsFixed(2)}
''';
  }

  void dispose() {
    _fallDetectionController?.close();
    _fallCountController?.close();
    _fallEventsController?.close();
    _sensorDataController?.close();
  }
}

// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import '../models/fall_event.dart';
// import '../services/notification_service.dart';
//
// class TensorFlowFallDetectionService {
//   static final TensorFlowFallDetectionService _instance = TensorFlowFallDetectionService._internal();
//   factory TensorFlowFallDetectionService() => _instance;
//   TensorFlowFallDetectionService._internal() {
//     _fallDetectionController = StreamController<bool>.broadcast();
//     _fallCountController = StreamController<int>.broadcast();
//     _fallEventsController = StreamController<List<FallEvent>>.broadcast();
//     _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
//     _alertLevelController = StreamController<String>.broadcast();
//   }
//
//   // TensorFlow Lite Model
//   Interpreter? _interpreter;
//   bool _isModelLoaded = false;
//
//   late DatabaseReference _database;
//   final NotificationService _notificationService = NotificationService();
//
//   bool _isInitialized = false;
//   int _fallCount = 0;
//   int _minorAlertCount = 0;
//   int _basicAlertCount = 0;
//   int _highAlertCount = 0;
//   List<FallEvent> _recentFalls = [];
//   Map<String, dynamic>? _latestSensorData;
//   String _currentAlertLevel = 'NONE';
//
//   // Model configuration - ADJUST THESE BASED ON YOUR MODEL
//   static const int INPUT_SIZE = 12; // AX1,AY1,AZ1,RX1,RY1,RZ1,AX2,AY2,AZ2,RX2,RY2,RZ2
//   static const int SEQUENCE_LENGTH = 1; // Adjust if your model expects sequences
//   static const String MODEL_FILE = 'assets/models/fall_detection_model.tflite';
//
//   // Tiered Alert Thresholds
//   static const double MINOR_THRESHOLD = 0.75;  // 75% - Count only
//   static const double BASIC_THRESHOLD = 0.80;  // 80% - Minor alert
//   static const double HIGH_THRESHOLD = 0.90;   // 90% - High alert
//
//   // Data processing
//   List<Map<String, dynamic>> _sensorHistory = [];
//   static const int HISTORY_SIZE = 10;
//
//   // Streams
//   StreamController<bool>? _fallDetectionController;
//   StreamController<int>? _fallCountController;
//   StreamController<List<FallEvent>>? _fallEventsController;
//   StreamController<Map<String, dynamic>>? _sensorDataController;
//   StreamController<String>? _alertLevelController;
//
//   // Getters
//   Stream<bool> get fallDetectionStream => _fallDetectionController?.stream ?? Stream.empty();
//   Stream<int> get fallCountStream => _fallCountController?.stream ?? Stream.empty();
//   Stream<List<FallEvent>> get fallEventsStream => _fallEventsController?.stream ?? Stream.empty();
//   Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController?.stream ?? Stream.empty();
//   Stream<String> get alertLevelStream => _alertLevelController?.stream ?? Stream.empty();
//
//   bool get isModelLoaded => _isModelLoaded;
//   int get fallCount => _fallCount;
//   int get minorAlertCount => _minorAlertCount;
//   int get basicAlertCount => _basicAlertCount;
//   int get highAlertCount => _highAlertCount;
//   List<FallEvent> get recentFalls => _recentFalls;
//   Map<String, dynamic>? get latestSensorData => _latestSensorData;
//   String get currentAlertLevel => _currentAlertLevel;
//
//   Future<void> initialize() async {
//     if (_isInitialized) return;
//
//     try {
//       _database = FirebaseDatabase.instanceFor(
//         app: Firebase.app(),
//         databaseURL: 'https://fall-detection-1851d-default-rtdb.firebaseio.com/'
//       ).ref();
//
//       await _notificationService.initialize();
//       await _loadTensorFlowModel();
//       _startRealtimeDataListener();
//
//       _isInitialized = true;
//       print('✅ TensorFlow Fall Detection Service initialized - Model loaded: $_isModelLoaded');
//     } catch (e) {
//       print('❌ Error initializing TensorFlow Fall Detection Service: $e');
//       throw e;
//     }
//   }
//
//   Future<void> _loadTensorFlowModel() async {
//     try {
//       print('🤖 Loading TensorFlow Lite model from: $MODEL_FILE');
//
//       // Load the model
//       _interpreter = await Interpreter.fromAsset(MODEL_FILE);
//
//       // Get input and output tensor info
//       var inputTensors = _interpreter!.getInputTensors();
//       var outputTensors = _interpreter!.getOutputTensors();
//
//       print('📊 Model Input Shape: ${inputTensors.first.shape}');
//       print('📊 Model Output Shape: ${outputTensors.first.shape}');
//       print('📊 Model Input Type: ${inputTensors.first.type}');
//       print('📊 Model Output Type: ${outputTensors.first.type}');
//
//       _isModelLoaded = true;
//       print('✅ TensorFlow Lite model loaded successfully!');
//
//     } catch (e) {
//       print('❌ Failed to load TensorFlow Lite model: $e');
//       print('❌ Make sure your model file is in: $MODEL_FILE');
//       _isModelLoaded = false;
//     }
//   }
//
//   void _startRealtimeDataListener() {
//     _database.child('devices/001/latest_data').onValue.listen((DatabaseEvent event) {
//       if (event.snapshot.value != null) {
//         try {
//           Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
//           print('🔥 Firebase data received for TensorFlow processing');
//           _processSensorData(data);
//         } catch (e) {
//           print('❌ Error processing Firebase data: $e');
//         }
//       }
//     });
//   }
//
//   Future<void> _processSensorData(Map<String, dynamic> data) async {
//     try {
//       String? dataString = data['data']?.toString();
//       if (dataString == null || dataString.isEmpty) {
//         print('⚠️ No data string found');
//         return;
//       }
//
//       List<String> values = dataString.split(',');
//
//       if (values.length < 14) {
//         print('⚠️ Insufficient data values: ${values.length}');
//         return;
//       }
//
//       // Parse sensor data
//       Map<String, dynamic> processedData = {
//         'device_id': values[0].trim(),
//         'timestamp': int.tryParse(values[1].trim()) ?? DateTime.now().millisecondsSinceEpoch,
//
//         'AX1': _parseDouble(values[2]),
//         'AY1': _parseDouble(values[3]),
//         'AZ1': _parseDouble(values[4]),
//         'RX1': _parseDouble(values[5]),
//         'RY1': _parseDouble(values[6]),
//         'RZ1': _parseDouble(values[7]),
//
//         'AX2': _parseDouble(values[8]),
//         'AY2': _parseDouble(values[9]),
//         'AZ2': _parseDouble(values[10]),
//         'RX2': _parseDouble(values[11]),
//         'RY2': _parseDouble(values[12]),
//         'RZ2': _parseDouble(values[13]),
//       };
//
//       _calculateEnhancedFeatures(processedData);
//
//       print('📊 TensorFlow Processing: Device=${processedData['device_id']}, '
//             'AX1=${processedData['AX1']?.toStringAsFixed(2)}, '
//             'AY1=${processedData['AY1']?.toStringAsFixed(2)}, '
//             'AZ1=${processedData['AZ1']?.toStringAsFixed(2)}');
//
//       _latestSensorData = processedData;
//       _sensorDataController?.add(processedData);
//
//       _sensorHistory.add(processedData);
//       if (_sensorHistory.length > HISTORY_SIZE) {
//         _sensorHistory.removeAt(0);
//       }
//
//       await _tensorFlowFallDetection(processedData);
//
//     } catch (e) {
//       print('❌ Error processing sensor data: $e');
//     }
//   }
//
//   void _calculateEnhancedFeatures(Map<String, dynamic> data) {
//     double ax1 = data['AX1'] ?? 0.0;
//     double ay1 = data['AY1'] ?? 0.0;
//     double az1 = data['AZ1'] ?? 0.0;
//     double ax2 = data['AX2'] ?? 0.0;
//     double ay2 = data['AY2'] ?? 0.0;
//     double az2 = data['AZ2'] ?? 0.0;
//
//     data['magnitude1'] = sqrt(ax1*ax1 + ay1*ay1 + az1*az1);
//     data['magnitude2'] = sqrt(ax2*ax2 + ay2*ay2 + az2*az2);
//
//     data['total_acceleration'] = sqrt(
//       pow(ax1 + ax2, 2) + pow(ay1 + ay2, 2) + pow(az1 + az2, 2)
//     );
//
//     double rx1 = data['RX1'] ?? 0.0;
//     double ry1 = data['RY1'] ?? 0.0;
//     double rz1 = data['RZ1'] ?? 0.0;
//     double rx2 = data['RX2'] ?? 0.0;
//     double ry2 = data['RY2'] ?? 0.0;
//     double rz2 = data['RZ2'] ?? 0.0;
//
//     data['gyro_magnitude1'] = sqrt(rx1*rx1 + ry1*ry1 + rz1*rz1);
//     data['gyro_magnitude2'] = sqrt(rx2*rx2 + ry2*ry2 + rz2*rz2);
//
//     data['motion_intensity'] = data['magnitude1'] + data['magnitude2'] +
//                               data['gyro_magnitude1'] + data['gyro_magnitude2'];
//   }
//
//   Future<void> _tensorFlowFallDetection(Map<String, dynamic> sensorData) async {
//     try {
//       double fallProbability = 0.0;
//
//       if (_isModelLoaded && _interpreter != null) {
//         fallProbability = await _runTensorFlowInference(sensorData);
//         print('🧠 TensorFlow Model Prediction: ${(fallProbability * 100).toStringAsFixed(1)}%');
//       } else {
//         // Fallback to rule-based detection
//         final result = _ruleBasedFallDetection(sensorData);
//         fallProbability = result['probability'] ?? 0.0;
//         print('📏 Rule-based Fallback: ${(fallProbability * 100).toStringAsFixed(1)}%');
//       }
//
//       // Determine alert level based on probability
//       String alertLevel = _determineAlertLevel(fallProbability);
//
//       print('🎯 TensorFlow Detection: Prob=${(fallProbability * 100).toStringAsFixed(1)}%, Level=$alertLevel');
//
//       // Handle different alert levels
//       await _handleTieredAlert(alertLevel, fallProbability, sensorData);
//
//       _currentAlertLevel = alertLevel;
//       _alertLevelController?.add(alertLevel);
//       _fallDetectionController?.add(alertLevel != 'NONE');
//
//     } catch (e) {
//       print('❌ Error in TensorFlow fall detection: $e');
//     }
//   }
//
//   Future<double> _runTensorFlowInference(Map<String, dynamic> sensorData) async {
//     try {
//       // Prepare input data - ADJUST THIS BASED ON YOUR MODEL'S INPUT FORMAT
//       List<double> inputData = [
//         sensorData['AX1'] ?? 0.0,
//         sensorData['AY1'] ?? 0.0,
//         sensorData['AZ1'] ?? 0.0,
//         sensorData['RX1'] ?? 0.0,
//         sensorData['RY1'] ?? 0.0,
//         sensorData['RZ1'] ?? 0.0,
//         sensorData['AX2'] ?? 0.0,
//         sensorData['AY2'] ?? 0.0,
//         sensorData['AZ2'] ?? 0.0,
//         sensorData['RX2'] ?? 0.0,
//         sensorData['RY2'] ?? 0.0,
//         sensorData['RZ2'] ?? 0.0,
//       ];
//
//       // Normalize data if your model expects it (adjust based on your training)
//       // inputData = _normalizeInput(inputData);
//
//       // Reshape input for the model - ADJUST BASED ON YOUR MODEL'S INPUT SHAPE
//       var input = Float32List.fromList(inputData);
//       var inputTensor = input.reshape([1, INPUT_SIZE]); // [batch_size, features]
//
//       // If your model expects sequences, use this instead:
//       // var inputTensor = input.reshape([1, SEQUENCE_LENGTH, INPUT_SIZE]);
//
//       // Prepare output tensor - ADJUST BASED ON YOUR MODEL'S OUTPUT SHAPE
//       var output = Float32List(1); // Assuming single probability output
//       var outputTensor = output.reshape([1, 1]);
//
//       // Run inference
//       _interpreter!.run(inputTensor, outputTensor);
//
//       // Get probability - ADJUST BASED ON YOUR MODEL'S OUTPUT FORMAT
//       double probability = output[0];
//
//       // If your model outputs logits, apply sigmoid
//       // probability = 1.0 / (1.0 + exp(-probability));
//
//       // If your model outputs multiple classes, get the fall class probability
//       // probability = output[1]; // assuming index 1 is fall class
//
//       print('🔮 TensorFlow Raw Output: $probability');
//
//       // Ensure probability is in valid range
//       probability = probability.clamp(0.0, 1.0);
//
//       return probability;
//
//     } catch (e) {
//       print('❌ TensorFlow inference error: $e');
//       return 0.0;
//     }
//   }
//
//   // Optional: Normalize input data if your model was trained with normalized data
//   List<double> _normalizeInput(List<double> input) {
//     // Example normalization - adjust based on your training data statistics
//     // These are example values - replace with your actual mean/std from training
//     List<double> means = [0.0, 0.0, 9.8, 0.0, 0.0, 0.0, 0.0, 0.0, 9.8, 0.0, 0.0, 0.0];
//     List<double> stds = [5.0, 5.0, 5.0, 2.0, 2.0, 2.0, 5.0, 5.0, 5.0, 2.0, 2.0, 2.0];
//
//     List<double> normalized = [];
//     for (int i = 0; i < input.length; i++) {
//       normalized.add((input[i] - means[i]) / stds[i]);
//     }
//     return normalized;
//   }
//
//   String _determineAlertLevel(double probability) {
//     if (probability >= HIGH_THRESHOLD) {
//       return 'HIGH';        // 90%+ - High Alert
//     } else if (probability >= BASIC_THRESHOLD) {
//       return 'BASIC';       // 80%+ - Basic Alert
//     } else if (probability >= MINOR_THRESHOLD) {
//       return 'MINOR';       // 75%+ - Minor Alert (Count only)
//     } else {
//       return 'NONE';        // Below 75% - No alert
//     }
//   }
//
//   Future<void> _handleTieredAlert(String alertLevel, double probability, Map<String, dynamic> sensorData) async {
//     try {
//       switch (alertLevel) {
//         case 'HIGH':
//           _highAlertCount++;
//           _basicAlertCount++;
//           _minorAlertCount++;
//           _fallCount++;
//           await _createFallEvent('HIGH', probability, sensorData);
//           await _notificationService.showHighAlertNotification();
//           print('🚨 TensorFlow HIGH ALERT! Probability: ${(probability * 100).toStringAsFixed(1)}%');
//           break;
//
//         case 'BASIC':
//           _basicAlertCount++;
//           _minorAlertCount++;
//           _fallCount++;
//           await _createFallEvent('BASIC', probability, sensorData);
//           await _notificationService.showBasicAlertNotification();
//           print('⚠️ TensorFlow BASIC ALERT! Probability: ${(probability * 100).toStringAsFixed(1)}%');
//           break;
//
//         case 'MINOR':
//           _minorAlertCount++;
//           _fallCount++;
//           await _createFallEvent('MINOR', probability, sensorData);
//           print('📊 TensorFlow MINOR ALERT (Count Only): ${(probability * 100).toStringAsFixed(1)}%');
//           break;
//
//         case 'NONE':
//           // No action needed
//           break;
//       }
//
//       // Update counters
//       _fallCountController?.add(_fallCount);
//
//     } catch (e) {
//       print('❌ Error handling TensorFlow tiered alert: $e');
//     }
//   }
//
//   Future<void> _createFallEvent(String alertLevel, double probability, Map<String, dynamic> sensorData) async {
//     try {
//       FallEvent fallEvent = FallEvent(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         timestamp: DateTime.now(),
//         location: 'Device: ${sensorData['device_id']} - TensorFlow $alertLevel Alert',
//         probability: probability,
//         isFalseAlarm: false,
//       );
//
//       _recentFalls.insert(0, fallEvent);
//       if (_recentFalls.length > 20) {
//         _recentFalls.removeLast();
//       }
//
//       await _storeTensorFlowFallEvent(fallEvent, alertLevel, sensorData);
//       _fallEventsController?.add(List.from(_recentFalls));
//
//     } catch (e) {
//       print('❌ Error creating TensorFlow fall event: $e');
//     }
//   }
//
//   Future<void> _storeTensorFlowFallEvent(FallEvent fallEvent, String alertLevel, Map<String, dynamic> sensorData) async {
//     try {
//       await _database.child('fall_events').child(fallEvent.id).set({
//         'timestamp': fallEvent.timestamp.millisecondsSinceEpoch,
//         'location': fallEvent.location,
//         'probability': fallEvent.probability,
//         'alert_level': alertLevel,
//         'isFalseAlarm': fallEvent.isFalseAlarm,
//         'device_id': sensorData['device_id'],
//         'detection_method': 'tensorflow_lite_model',
//
//         'sensor_data': {
//           'AX1': sensorData['AX1'], 'AY1': sensorData['AY1'], 'AZ1': sensorData['AZ1'],
//           'RX1': sensorData['RX1'], 'RY1': sensorData['RY1'], 'RZ1': sensorData['RZ1'],
//           'AX2': sensorData['AX2'], 'AY2': sensorData['AY2'], 'AZ2': sensorData['AZ2'],
//           'RX2': sensorData['RX2'], 'RY2': sensorData['RY2'], 'RZ2': sensorData['RZ2'],
//           'magnitude1': sensorData['magnitude1'], 'magnitude2': sensorData['magnitude2'],
//           'total_acceleration': sensorData['total_acceleration'],
//           'motion_intensity': sensorData['motion_intensity'],
//         }
//       });
//     } catch (e) {
//       print('❌ Error storing TensorFlow fall event: $e');
//     }
//   }
//
//   Map<String, dynamic> _ruleBasedFallDetection(Map<String, dynamic> sensorData) {
//     try {
//       double magnitude1 = sensorData['magnitude1'] ?? 0.0;
//       double magnitude2 = sensorData['magnitude2'] ?? 0.0;
//       double totalAccel = sensorData['total_acceleration'] ?? 0.0;
//       double motionIntensity = sensorData['motion_intensity'] ?? 0.0;
//
//       bool highAcceleration = magnitude1 > 6.0 || magnitude2 > 6.0;
//       bool highTotalAccel = totalAccel > 8.0;
//       bool highMotionIntensity = motionIntensity > 12.0;
//
//       double probability = 0.0;
//
//       if (highAcceleration || highTotalAccel || highMotionIntensity) {
//         double accelScore = min((max(magnitude1, magnitude2)) / 15.0, 1.0);
//         double motionScore = min(motionIntensity / 25.0, 1.0);
//         probability = (accelScore + motionScore) / 2.0;
//         probability = max(probability, 0.2);
//       }
//
//       return {
//         'probability': probability,
//         'method': 'rule_based_fallback'
//       };
//     } catch (e) {
//       return {'probability': 0.0, 'method': 'rule_based_fallback'};
//     }
//   }
//
//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       String cleanValue = value.trim();
//       return double.tryParse(cleanValue) ?? 0.0;
//     }
//     return 0.0;
//   }
//
//   Future<void> markFallAsFalseAlarm(String fallId) async {
//     try {
//       await _database.child('fall_events').child(fallId).update({
//         'isFalseAlarm': true,
//         'updatedAt': DateTime.now().millisecondsSinceEpoch,
//       });
//
//       int index = _recentFalls.indexWhere((fall) => fall.id == fallId);
//       if (index != -1) {
//         _recentFalls[index] = FallEvent(
//           id: _recentFalls[index].id,
//           timestamp: _recentFalls[index].timestamp,
//           location: _recentFalls[index].location,
//           probability: _recentFalls[index].probability,
//           isFalseAlarm: true,
//         );
//         _fallEventsController?.add(List.from(_recentFalls));
//       }
//
//       await _notificationService.cancelFallAlert();
//     } catch (e) {
//       print('❌ Error marking TensorFlow fall as false alarm: $e');
//     }
//   }
//
//   void resetFallCount() {
//     _fallCount = 0;
//     _minorAlertCount = 0;
//     _basicAlertCount = 0;
//     _highAlertCount = 0;
//     _fallCountController?.add(_fallCount);
//   }
//
//   String getTensorFlowStatusSummary() {
//     return '''
// TensorFlow Model: ${_isModelLoaded ? "Loaded" : "Not Loaded"}
// Total Events: $_fallCount
// Minor Alerts (75%+): $_minorAlertCount
// Basic Alerts (80%+): $_basicAlertCount
// High Alerts (90%+): $_highAlertCount
// Current Level: $_currentAlertLevel
// Detection Method: ${_isModelLoaded ? "TensorFlow Lite" : "Rule-based Fallback"}
// ''';
//   }
//
//   void dispose() {
//     _interpreter?.close();
//     _fallDetectionController?.close();
//     _fallCountController?.close();
//     _fallEventsController?.close();
//     _sensorDataController?.close();
//     _alertLevelController?.close();
//   }
// }

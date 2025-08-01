import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MLService {
  static const MethodChannel _channel = MethodChannel('fall_detection_ml');

  bool _isModelLoaded = false;
  bool _isModelDownloading = false;

  // Window size for collecting sensor data
  static const int WINDOW_SIZE = 50;

  // Buffer to store accelerometer data
  List<List<double>> _buffer = List.generate(
    WINDOW_SIZE,
        (_) => List.filled(3, 0.0),
  );

  int _bufferIndex = 0;

  // Callback for fall detection results
  Function(bool, double)? _fallDetectionCallback;

  // Initialize the ML model
  Future<void> initializeModel() async {
    try {
      _isModelDownloading = true;

      // Call native Android code to download and initialize the model
      final result = await _channel.invokeMethod('initializeModel');

      if (result['success'] == true) {
        _isModelLoaded = true;
        print('✅ Firebase ML Kit model loaded successfully');
      } else {
        _isModelLoaded = false;
        print('❌ Failed to load Firebase ML Kit model: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error initializing ML model: $e');
      _isModelLoaded = false;
    } finally {
      _isModelDownloading = false;
    }
  }

  // Set callback for fall detection results
  void setFallDetectionCallback(Function(bool, double) callback) {
    _fallDetectionCallback = callback;
  }

  // Process sensor data for fall detection
  Future<bool> detectFall(double x, double y, double z) async {
    // Add data to buffer
    _buffer[_bufferIndex] = [x, y, z];
    _bufferIndex = (_bufferIndex + 1) % WINDOW_SIZE;

    // Check if we have enough data and model is loaded
    if (_bufferIndex == 0 && _isModelLoaded) {
      try {
        // Prepare input data for the model
        final inputData = _prepareInputData();

        // Call native Android code to run inference
        final result = await _channel.invokeMethod('runInference', {
          'inputData': inputData,
        });

        if (result['success'] == true) {
          final fallProbability = result['probability'] as double;
          final isFallDetected = fallProbability > 0.7; // Threshold

          // Store result in database
          if (isFallDetected) {
            await _storeFallDetectionResult(fallProbability, x, y, z);
          }

          // Notify callback
          _fallDetectionCallback?.call(isFallDetected, fallProbability);

          return isFallDetected;
        } else {
          print('❌ Inference failed: ${result['error']}');
          return _detectFallWithRules(x, y, z);
        }
      } catch (e) {
        print('❌ Error during inference: $e');
        return _detectFallWithRules(x, y, z);
      }
    }

    return false;
  }

  // Prepare input data for the ML model
  List<double> _prepareInputData() {
    List<double> flatData = [];

    // Flatten the buffer data
    for (int i = 0; i < WINDOW_SIZE; i++) {
      int idx = (_bufferIndex + i) % WINDOW_SIZE;
      flatData.addAll(_buffer[idx]);
    }

    // Normalize the data (optional, depends on your model training)
    return _normalizeData(flatData);
  }

  // Normalize sensor data
  List<double> _normalizeData(List<double> data) {
    // Calculate mean and standard deviation
    double mean = data.reduce((a, b) => a + b) / data.length;
    double variance = data.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;
    double stdDev = sqrt(variance);

    // Normalize using z-score
    if (stdDev > 0) {
      return data.map((x) => (x - mean) / stdDev).toList();
    }

    return data;
  }

  // Store fall detection result in Firestore
  Future<void> _storeFallDetectionResult(double probability, double x, double y, double z) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final fallData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'probability': probability,
        'sensorData': {
          'accelerometerX': x,
          'accelerometerY': y,
          'accelerometerZ': z,
        },
        'magnitude': sqrt(x * x + y * y + z * z),
        'modelVersion': 'firebase_ml_kit_v1',
        'isConfirmed': false, // User can confirm if it's a real fall
        'location': null, // Will be updated if location is available
      };

      // Store in falls collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('falls')
          .add(fallData);

      // Update user's fall statistics
      await _updateFallStatistics(user.uid);

      print('✅ Fall detection result stored in database');
    } catch (e) {
      print('❌ Error storing fall detection result: $e');
    }
  }

  // Update user's fall statistics
  Future<void> _updateFallStatistics(String userId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final currentFallCount = data['totalFalls'] ?? 0;
          final todayFalls = data['todayFalls'] ?? 0;

          transaction.update(userRef, {
            'totalFalls': currentFallCount + 1,
            'todayFalls': todayFalls + 1,
            'lastFallDetected': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('❌ Error updating fall statistics: $e');
    }
  }

  // Fallback rule-based detection
  bool _detectFallWithRules(double x, double y, double z) {
    // Calculate acceleration magnitude
    double magnitude = sqrt(x * x + y * y + z * z);

    // Simple threshold-based fall detection
    if (magnitude > 25.0) {
      // Check for post-fall inactivity
      bool isInactive = _checkPostFallInactivity();
      return isInactive;
    }

    return false;
  }

  // Check for post-fall inactivity
  bool _checkPostFallInactivity() {
    // Calculate variance of recent readings
    double sumX = 0, sumY = 0, sumZ = 0;
    double sumSqX = 0, sumSqY = 0, sumSqZ = 0;

    int count = min(20, WINDOW_SIZE);

    for (int i = 0; i < count; i++) {
      int idx = (_bufferIndex - i - 1 + WINDOW_SIZE) % WINDOW_SIZE;

      sumX += _buffer[idx][0];
      sumY += _buffer[idx][1];
      sumZ += _buffer[idx][2];

      sumSqX += _buffer[idx][0] * _buffer[idx][0];
      sumSqY += _buffer[idx][1] * _buffer[idx][1];
      sumSqZ += _buffer[idx][2] * _buffer[idx][2];
    }

    double meanX = sumX / count;
    double meanY = sumY / count;
    double meanZ = sumZ / count;

    double varX = (sumSqX / count) - (meanX * meanX);
    double varY = (sumSqY / count) - (meanY * meanY);
    double varZ = (sumSqZ / count) - (meanZ * meanZ);

    double totalVariance = varX + varY + varZ;

    // Low variance indicates inactivity
    return totalVariance < 1.0;
  }

  // Get model status
  bool get isModelLoaded => _isModelLoaded;
  bool get isModelDownloading => _isModelDownloading;

  // Get recent fall detections from database
  Stream<List<Map<String, dynamic>>> getFallDetections() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('falls')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList());
  }

  // Confirm or dismiss a fall detection
  Future<void> updateFallConfirmation(String fallId, bool isConfirmed) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('falls')
          .doc(fallId)
          .update({
        'isConfirmed': isConfirmed,
        'confirmedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating fall confirmation: $e');
    }
  }

  void dispose() {
    _fallDetectionCallback = null;
  }
}

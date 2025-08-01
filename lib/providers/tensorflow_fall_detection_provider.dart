// import 'package:flutter/material.dart';
// import '../services/tensorflow_fall_detection_service.dart';
// import '../models/fall_event.dart';
//
// class TensorFlowFallDetectionProvider extends ChangeNotifier {
//   final TensorFlowFallDetectionService _tensorFlowService = TensorFlowFallDetectionService();
//
//   bool _isInitialized = false;
//   bool _isFallDetected = false;
//   int _fallCount = 0;
//   List<FallEvent> _recentFalls = [];
//   bool _isMLModelLoaded = false;
//   String _currentAlertLevel = 'NONE';
//
//   // Getters
//   bool get isInitialized => _isInitialized;
//   bool get isFallDetected => _isFallDetected;
//   int get fallCount => _fallCount;
//   List<FallEvent> get recentFalls => _recentFalls;
//   bool get isMLModelLoaded => _isMLModelLoaded;
//   String get currentAlertLevel => _currentAlertLevel;
//
//   // For backward compatibility
//   List<FallEvent> get recentEvents => _recentFalls;
//
//   TensorFlowFallDetectionProvider() {
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     try {
//       await _tensorFlowService.initialize();
//       _isMLModelLoaded = _tensorFlowService.isModelLoaded;
//
//       // Listen to TensorFlow fall detection stream
//       _tensorFlowService.fallDetectionStream.listen((isFall) {
//         _isFallDetected = isFall;
//         notifyListeners();
//       });
//
//       // Listen to fall count stream
//       _tensorFlowService.fallCountStream.listen((count) {
//         _fallCount = count;
//         notifyListeners();
//       });
//
//       // Listen to fall events stream
//       _tensorFlowService.fallEventsStream.listen((events) {
//         _recentFalls = events;
//         notifyListeners();
//       });
//
//       // Listen to alert level stream
//       _tensorFlowService.alertLevelStream.listen((alertLevel) {
//         _currentAlertLevel = alertLevel;
//         notifyListeners();
//       });
//
//       _isInitialized = true;
//       notifyListeners();
//       print('✅ TensorFlow Fall Detection Provider initialized - Model loaded: $_isMLModelLoaded');
//     } catch (e) {
//       print('❌ Error initializing TensorFlow Fall Detection Provider: $e');
//     }
//   }
//
//   void resetFallCount() {
//     _tensorFlowService.resetFallCount();
//     _fallCount = 0;
//     notifyListeners();
//   }
//
//   Future<void> markFallAsFalseAlarm(String fallId) async {
//     await _tensorFlowService.markFallAsFalseAlarm(fallId);
//   }
//
//   String getTensorFlowStatus() {
//     return _tensorFlowService.getTensorFlowStatusSummary();
//   }
//
//   @override
//   void dispose() {
//     _tensorFlowService.dispose();
//     super.dispose();
//   }
// }

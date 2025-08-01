import 'package:flutter/material.dart';
import '../services/enhanced_fall_detection_service.dart';
import '../models/fall_event.dart';

class FallDetectionProvider extends ChangeNotifier {
  final EnhancedFallDetectionService _enhancedService = EnhancedFallDetectionService();

  bool _isInitialized = false;
  bool _isFallDetected = false;
  int _fallCount = 0;
  List<FallEvent> _recentFalls = [];
  bool _isMLModelLoaded = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isFallDetected => _isFallDetected;
  int get fallCount => _fallCount;
  List<FallEvent> get recentFalls => _recentFalls;
  bool get isMLModelLoaded => _isMLModelLoaded;

  // For backward compatibility
  List<FallEvent> get recentEvents => _recentFalls;

  FallDetectionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _enhancedService.initialize();
      _isMLModelLoaded = _enhancedService.isModelLoaded;

      // Listen to enhanced fall detection stream
      _enhancedService.fallDetectionStream.listen((isFall) {
        _isFallDetected = isFall;
        notifyListeners();
      });

      // Listen to fall count stream
      _enhancedService.fallCountStream.listen((count) {
        _fallCount = count;
        notifyListeners();
      });

      // Listen to fall events stream
      _enhancedService.fallEventsStream.listen((events) {
        _recentFalls = events;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
      print('✅ Enhanced Fall Detection Provider initialized');
    } catch (e) {
      print('❌ Error initializing Enhanced Fall Detection Provider: $e');
    }
  }

  void resetFallCount() {
    _enhancedService.resetFallCount();
    _fallCount = 0;
    notifyListeners();
  }

  Future<void> markFallAsFalseAlarm(String fallId) async {
    await _enhancedService.markFallAsFalseAlarm(fallId);
  }

  @override
  void dispose() {
    _enhancedService.dispose();
    super.dispose();
  }
}

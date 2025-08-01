import 'package:flutter/material.dart';

class AIGuidanceProvider with ChangeNotifier {
  final List<AISuggestion> _suggestions = [
    AISuggestion(
      title: 'Improve Hydration',
      description: 'Based on health data, increased water intake is recommended. Aim for 8 glasses daily.',
      icon: Icons.water_drop,
      priority: 'Medium',
    ),
    AISuggestion(
      title: 'Bathroom Fall Risk',
      description: 'Patterns suggest increased bathroom usage at night. Consider installing night lights for safety.',
      icon: Icons.warning_amber_rounded,
      priority: 'High',
    ),
    AISuggestion(
      title: 'Exercise Recommendation',
      description: 'Light stretching exercises would help improve circulation and reduce stiffness.',
      icon: Icons.fitness_center,
      priority: 'Medium',
    ),
    AISuggestion(
      title: 'Medication Reminder',
      description: 'Heart medication should be taken at consistent times. Set up a daily reminder.',
      icon: Icons.medication,
      priority: 'High',
    ),
  ];

  // Getters
  List<AISuggestion> get suggestions => _suggestions;

  // Methods
  void addSuggestion(AISuggestion suggestion) {
    _suggestions.add(suggestion);
    notifyListeners();
  }

  void removeSuggestion(String title) {
    _suggestions.removeWhere((suggestion) => suggestion.title == title);
    notifyListeners();
  }

  // Generate a new suggestion based on detected fall
  void generateFallBasedSuggestion() {
    final newSuggestion = AISuggestion(
      title: 'Post-Fall Safety Review',
      description: 'A recent fall was detected. Consider a home safety assessment to identify and remove hazards.',
      icon: Icons.health_and_safety,
      priority: 'High',
    );
    
    // Check if a similar suggestion already exists
    if (!_suggestions.any((s) => s.title == newSuggestion.title)) {
      _suggestions.insert(0, newSuggestion);
      notifyListeners();
    }
  }
}

class AISuggestion {
  final String title;
  final String description;
  final IconData icon;
  final String priority;

  AISuggestion({
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });
}

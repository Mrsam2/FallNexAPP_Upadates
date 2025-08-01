class FallEvent {
  final String id;
  final DateTime timestamp;
  final String location;
  final double probability;
  final bool isFalseAlarm;

  FallEvent({
    required this.id,
    required this.timestamp,
    required this.location,
    this.probability = 0.0,
    this.isFalseAlarm = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'probability': probability,
      'isFalseAlarm': isFalseAlarm,
    };
  }

  factory FallEvent.fromJson(Map<String, dynamic> json) {
    return FallEvent(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      probability: json['probability']?.toDouble() ?? 0.0,
      isFalseAlarm: json['isFalseAlarm'] ?? false,
    );
  }

  // For backward compatibility with existing code
  bool get isEmergency => !isFalseAlarm;
  String get title => 'Fall Detected';
  String get time => '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}

import 'package:uuid/uuid.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
  final bool? isMedical; // Made nullable for robustness against old data

  EmergencyContact({
    String? id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
    this.isMedical = false, // Still default to false in constructor
  }) : id = id ?? const Uuid().v4();

  // Add getter for address to fix PDF compilation error
  String get address => ''; // Return empty string as default since address is not in your model

  // Add getter for email to fix PDF compilation error
  String get email => ''; // Return empty string as default since email is not in your model

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      relationship: map['relationship'] as String,
      isPrimary: map['isPrimary'] as bool? ?? false,
      isMedical: map['isMedical'] as bool? ?? false, // Still default to false from map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'isPrimary': isPrimary,
      'isMedical': isMedical,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimary,
    bool? isMedical,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      isMedical: isMedical ?? this.isMedical,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmergencyContact &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.relationship == relationship &&
        other.isPrimary == isPrimary &&
        other.isMedical == isMedical;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    phoneNumber.hashCode ^
    relationship.hashCode ^
    isPrimary.hashCode ^
    (isMedical?.hashCode ?? 0); // Handle nullable hashCode
  }

  @override
  String toString() {
    return 'EmergencyContact(id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, isPrimary: $isPrimary, isMedical: $isMedical)';
  }
}

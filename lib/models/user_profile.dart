import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection/models/emergency_contact.dart';

// Personal Information Section
class PersonalInfo {
  final String fullName;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String gender;
  final String address;

  PersonalInfo({
    this.fullName = '',
    this.phoneNumber = '',
    this.dateOfBirth,
    this.gender = '',
    this.address = '',
  });

  PersonalInfo copyWith({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'gender': gender,
      'address': address,
    };
  }

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
          : null,
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
    );
  }
}

// Health Information Section
class HealthInfo {
  final int? height;
  final int? weight;
  final String bloodType;
  final List<String> medicalConditions;
  final List<String> medications;
  final List<String> allergies;
  final String doctorName;
  final String doctorPhone;
  final String insuranceProvider;
  final String insuranceId;

  HealthInfo({
    this.height,
    this.weight,
    this.bloodType = '',
    this.medicalConditions = const [],
    this.medications = const [],
    this.allergies = const [],
    this.doctorName = '',
    this.doctorPhone = '',
    this.insuranceProvider = '',
    this.insuranceId = '',
  });

  HealthInfo copyWith({
    int? height,
    int? weight,
    String? bloodType,
    List<String>? medicalConditions,
    List<String>? medications,
    List<String>? allergies,
    String? doctorName,
    String? doctorPhone,
    String? insuranceProvider,
    String? insuranceId,
  }) {
    return HealthInfo(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceId: insuranceId ?? this.insuranceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceId': insuranceId,
    };
  }

  factory HealthInfo.fromMap(Map<String, dynamic> map) {
    return HealthInfo(
      height: map['height'],
      weight: map['weight'],
      bloodType: map['bloodType'] ?? '',
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      doctorName: map['doctorName'] ?? '',
      doctorPhone: map['doctorPhone'] ?? '',
      insuranceProvider: map['insuranceProvider'] ?? '',
      insuranceId: map['insuranceId'] ?? '',
    );
  }
}

// Location Information Section
class LocationInfo {
  final String homeAddress;
  final String workAddress;
  final bool shareLocation;
  final bool highAccuracyGPS;
  final bool locationHistory;
  final List<String> safeZones;

  LocationInfo({
    this.homeAddress = '',
    this.workAddress = '',
    this.shareLocation = false,
    this.highAccuracyGPS = false,
    this.locationHistory = false,
    this.safeZones = const [],
  });

  LocationInfo copyWith({
    String? homeAddress,
    String? workAddress,
    bool? shareLocation,
    bool? highAccuracyGPS,
    bool? locationHistory,
    List<String>? safeZones,
  }) {
    return LocationInfo(
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
      shareLocation: shareLocation ?? this.shareLocation,
      highAccuracyGPS: highAccuracyGPS ?? this.highAccuracyGPS,
      locationHistory: locationHistory ?? this.locationHistory,
      safeZones: safeZones ?? this.safeZones,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'homeAddress': homeAddress,
      'workAddress': workAddress,
      'shareLocation': shareLocation,
      'highAccuracyGPS': highAccuracyGPS,
      'locationHistory': locationHistory,
      'safeZones': safeZones,
    };
  }

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      homeAddress: map['homeAddress'] ?? '',
      workAddress: map['workAddress'] ?? '',
      shareLocation: map['shareLocation'] ?? false,
      highAccuracyGPS: map['highAccuracyGPS'] ?? false,
      locationHistory: map['locationHistory'] ?? false,
      safeZones: List<String>.from(map['safeZones'] ?? []),
    );
  }
}

// AI Preferences Section
class AIPreferences {
  final bool enableAIAssistance;
  final bool voiceCommands;
  final bool smartNotifications;
  final bool predictiveAlerts;
  final bool learningMode;
  final String sensitivityLevel;

  AIPreferences({
    this.enableAIAssistance = true,
    this.voiceCommands = false,
    this.smartNotifications = true,
    this.predictiveAlerts = true,
    this.learningMode = true,
    this.sensitivityLevel = 'Medium',
  });

  AIPreferences copyWith({
    bool? enableAIAssistance,
    bool? voiceCommands,
    bool? smartNotifications,
    bool? predictiveAlerts,
    bool? learningMode,
    String? sensitivityLevel,
  }) {
    return AIPreferences(
      enableAIAssistance: enableAIAssistance ?? this.enableAIAssistance,
      voiceCommands: voiceCommands ?? this.voiceCommands,
      smartNotifications: smartNotifications ?? this.smartNotifications,
      predictiveAlerts: predictiveAlerts ?? this.predictiveAlerts,
      learningMode: learningMode ?? this.learningMode,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableAIAssistance': enableAIAssistance,
      'voiceCommands': voiceCommands,
      'smartNotifications': smartNotifications,
      'predictiveAlerts': predictiveAlerts,
      'learningMode': learningMode,
      'sensitivityLevel': sensitivityLevel,
    };
  }

  factory AIPreferences.fromMap(Map<String, dynamic> map) {
    return AIPreferences(
      enableAIAssistance: map['enableAIAssistance'] ?? true,
      voiceCommands: map['voiceCommands'] ?? false,
      smartNotifications: map['smartNotifications'] ?? true,
      predictiveAlerts: map['predictiveAlerts'] ?? true,
      learningMode: map['learningMode'] ?? true,
      sensitivityLevel: map['sensitivityLevel'] ?? 'Medium',
    );
  }
}

// App Settings Section
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkMode;
  final String language;
  final bool autoEmergencyCall;
  final int emergencyCallDelay;

  AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.darkMode = false,
    this.language = 'English',
    this.autoEmergencyCall = true,
    this.emergencyCallDelay = 30,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkMode,
    String? language,
    bool? autoEmergencyCall,
    int? emergencyCallDelay,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      autoEmergencyCall: autoEmergencyCall ?? this.autoEmergencyCall,
      emergencyCallDelay: emergencyCallDelay ?? this.emergencyCallDelay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'darkMode': darkMode,
      'language': language,
      'autoEmergencyCall': autoEmergencyCall,
      'emergencyCallDelay': emergencyCallDelay,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'English',
      autoEmergencyCall: map['autoEmergencyCall'] ?? true,
      emergencyCallDelay: map['emergencyCallDelay'] ?? 30,
    );
  }
}

// Main UserProfile Class
class UserProfile {
  final String uid;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? weight;
  final String? height;
  final String? bloodGroup;
  final String? mobilityLevel;
  final String? homeAddress;
  final String? workAddress;
  final String? emergencyAddress;
  final bool? livingAlone;
  final bool? hasCaregiver;
  final String? medicalConditions;
  final String? allergies;
  final String? medications;
  final String? doctorName;
  final String? doctorPhone;
  final String? sleepHours;
  final String? activityLevel;
  final bool? hasPreviousFalls;
  final String? fallDescription;
  final bool? wearsSmartwatch;
  final bool? allowSensorAccess;
  final bool? allowCameraMonitoring;
  final String? preferredAlertMethod;
  final String? language;
  final bool? voiceGuidance;
  final bool? highContrast;
  final bool? largerFonts;
  final bool? hasMedicalConditions;
  final bool? takingMedications;
  final bool? hasAllergies;
  final bool? hasInsurance;
  final String? emergencyMedicalInfo;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final List<EmergencyContact>? emergencyContacts;
  final bool profileComplete;
  final bool? shareLocation;
  final bool? allowGPS;
  final bool? locationHistory;
  final String? currentLocation;
  final String? lastKnownLocation;
  final String? theme;
  final bool? enableNotifications;
  final bool? enableVibration;
  final bool? notificationsEnabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;
  final bool? darkMode;
  final bool? autoBackup;
  final String? backupFrequency;
  final String? dataRetention;
  final String? hasPrevious;

  UserProfile({
    required this.uid,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.height,
    this.bloodGroup,
    this.mobilityLevel,
    this.homeAddress,
    this.workAddress,
    this.emergencyAddress,
    this.livingAlone,
    this.hasCaregiver,
    this.medicalConditions,
    this.allergies,
    this.medications,
    this.doctorName,
    this.doctorPhone,
    this.sleepHours,
    this.activityLevel,
    this.hasPreviousFalls,
    this.fallDescription,
    this.wearsSmartwatch,
    this.allowSensorAccess,
    this.allowCameraMonitoring,
    this.preferredAlertMethod,
    this.language,
    this.voiceGuidance,
    this.highContrast,
    this.largerFonts,
    this.hasMedicalConditions,
    this.takingMedications,
    this.hasAllergies,
    this.hasInsurance,
    this.emergencyMedicalInfo,
    this.insuranceProvider,
    this.insuranceNumber,
    this.emergencyContacts,
    this.profileComplete = false,
    this.shareLocation,
    this.allowGPS,
    this.locationHistory,
    this.currentLocation,
    this.lastKnownLocation,
    this.theme,
    this.enableNotifications,
    this.enableVibration,
    this.notificationsEnabled,
    this.soundEnabled,
    this.vibrationEnabled,
    this.darkMode,
    this.autoBackup,
    this.backupFrequency,
    this.dataRetention,
    this.hasPrevious,
  });

  // Add getter for isComplete to fix compilation error
  bool get isComplete => profileComplete;

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'],
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'],
      gender: data['gender'],
      weight: data['weight']?.toString(),
      height: data['height']?.toString(),
      bloodGroup: data['bloodGroup'],
      mobilityLevel: data['mobilityLevel'],
      homeAddress: data['homeAddress'],
      workAddress: data['workAddress'],
      emergencyAddress: data['emergencyAddress'],
      livingAlone: data['livingAlone'],
      hasCaregiver: data['hasCaregiver'],
      medicalConditions: data['medicalConditions'],
      allergies: data['allergies'],
      medications: data['medications'],
      doctorName: data['doctorName'],
      doctorPhone: data['doctorPhone'],
      sleepHours: data['sleepHours']?.toString(),
      activityLevel: data['activityLevel'],
      hasPreviousFalls: data['hasPreviousFalls'],
      fallDescription: data['fallDescription'],
      wearsSmartwatch: data['wearsSmartwatch'],
      allowSensorAccess: data['allowSensorAccess'],
      allowCameraMonitoring: data['allowCameraMonitoring'],
      preferredAlertMethod: data['preferredAlertMethod'],
      language: data['language'],
      voiceGuidance: data['voiceGuidance'],
      highContrast: data['highContrast'],
      largerFonts: data['largerFonts'],
      hasMedicalConditions: data['hasMedicalConditions'],
      takingMedications: data['takingMedications'],
      hasAllergies: data['hasAllergies'],
      hasInsurance: data['hasInsurance'],
      emergencyMedicalInfo: data['emergencyMedicalInfo'],
      insuranceProvider: data['insuranceProvider'],
      insuranceNumber: data['insuranceNumber'],
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromMap(e as Map<String, dynamic>))
          .toList(),
      profileComplete: data['profileComplete'] ?? false,
      shareLocation: data['shareLocation'],
      allowGPS: data['allowGPS'],
      locationHistory: data['locationHistory'],
      currentLocation: data['currentLocation'],
      lastKnownLocation: data['lastKnownLocation'],
      theme: data['theme'],
      enableNotifications: data['enableNotifications'],
      enableVibration: data['enableVibration'],
      notificationsEnabled: data['notificationsEnabled'],
      soundEnabled: data['soundEnabled'],
      vibrationEnabled: data['vibrationEnabled'],
      darkMode: data['darkMode'],
      autoBackup: data['autoBackup'],
      backupFrequency: data['backupFrequency'],
      dataRetention: data['dataRetention'],
      hasPrevious: data['hasPrevious']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'weight': weight,
      'height': height,
      'bloodGroup': bloodGroup,
      'mobilityLevel': mobilityLevel,
      'homeAddress': homeAddress,
      'workAddress': workAddress,
      'emergencyAddress': emergencyAddress,
      'livingAlone': livingAlone,
      'hasCaregiver': hasCaregiver,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'medications': medications,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'sleepHours': sleepHours,
      'activityLevel': activityLevel,
      'hasPreviousFalls': hasPreviousFalls,
      'fallDescription': fallDescription,
      'wearsSmartwatch': wearsSmartwatch,
      'allowSensorAccess': allowSensorAccess,
      'allowCameraMonitoring': allowCameraMonitoring,
      'preferredAlertMethod': preferredAlertMethod,
      'language': language,
      'voiceGuidance': voiceGuidance,
      'highContrast': highContrast,
      'largerFonts': largerFonts,
      'hasMedicalConditions': hasMedicalConditions,
      'takingMedications': takingMedications,
      'hasAllergies': hasAllergies,
      'hasInsurance': hasInsurance,
      'emergencyMedicalInfo': emergencyMedicalInfo,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'emergencyContacts': emergencyContacts?.map((e) => e.toMap()).toList(),
      'profileComplete': profileComplete,
      'shareLocation': shareLocation,
      'allowGPS': allowGPS,
      'locationHistory': locationHistory,
      'currentLocation': currentLocation,
      'lastKnownLocation': lastKnownLocation,
      'theme': theme,
      'enableNotifications': enableNotifications,
      'enableVibration': enableVibration,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'darkMode': darkMode,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
      'dataRetention': dataRetention,
      'hasPrevious': hasPrevious,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? weight,
    String? height,
    String? bloodGroup,
    String? mobilityLevel,
    String? homeAddress,
    String? workAddress,
    String? emergencyAddress,
    bool? livingAlone,
    bool? hasCaregiver,
    String? medicalConditions,
    String? allergies,
    String? medications,
    String? doctorName,
    String? doctorPhone,
    String? sleepHours,
    String? activityLevel,
    bool? hasPreviousFalls,
    String? fallDescription,
    bool? wearsSmartwatch,
    bool? allowSensorAccess,
    bool? allowCameraMonitoring,
    String? preferredAlertMethod,
    String? language,
    bool? voiceGuidance,
    bool? highContrast,
    bool? largerFonts,
    bool? hasMedicalConditions,
    bool? takingMedications,
    bool? hasAllergies,
    bool? hasInsurance,
    String? emergencyMedicalInfo,
    String? insuranceProvider,
    String? insuranceNumber,
    List<EmergencyContact>? emergencyContacts,
    bool? profileComplete,
    bool? shareLocation,
    bool? allowGPS,
    bool? locationHistory,
    String? currentLocation,
    String? lastKnownLocation,
    String? theme,
    bool? enableNotifications,
    bool? enableVibration,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkMode,
    bool? autoBackup,
    String? backupFrequency,
    String? dataRetention,
    String? hasPrevious,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      mobilityLevel: mobilityLevel ?? this.mobilityLevel,
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
      emergencyAddress: emergencyAddress ?? this.emergencyAddress,
      livingAlone: livingAlone ?? this.livingAlone,
      hasCaregiver: hasCaregiver ?? this.hasCaregiver,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      sleepHours: sleepHours ?? this.sleepHours,
      activityLevel: activityLevel ?? this.activityLevel,
      hasPreviousFalls: hasPreviousFalls ?? this.hasPreviousFalls,
      fallDescription: fallDescription ?? this.fallDescription,
      wearsSmartwatch: wearsSmartwatch ?? this.wearsSmartwatch,
      allowSensorAccess: allowSensorAccess ?? this.allowSensorAccess,
      allowCameraMonitoring: allowCameraMonitoring ?? this.allowCameraMonitoring,
      preferredAlertMethod: preferredAlertMethod ?? this.preferredAlertMethod,
      language: language ?? this.language,
      voiceGuidance: voiceGuidance ?? this.voiceGuidance,
      highContrast: highContrast ?? this.highContrast,
      largerFonts: largerFonts ?? this.largerFonts,
      hasMedicalConditions: hasMedicalConditions ?? this.hasMedicalConditions,
      takingMedications: takingMedications ?? this.takingMedications,
      hasAllergies: hasAllergies ?? this.hasAllergies,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      emergencyMedicalInfo: emergencyMedicalInfo ?? this.emergencyMedicalInfo,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      profileComplete: profileComplete ?? this.profileComplete,
      shareLocation: shareLocation ?? this.shareLocation,
      allowGPS: allowGPS ?? this.allowGPS,
      locationHistory: locationHistory ?? this.locationHistory,
      currentLocation: currentLocation ?? this.currentLocation,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      theme: theme ?? this.theme,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkMode: darkMode ?? this.darkMode,
      autoBackup: autoBackup ?? this.autoBackup,
      dataRetention: dataRetention ?? this.dataRetention,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }
}

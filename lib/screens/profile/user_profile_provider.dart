import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fall_detection/models/user_profile.dart';
import 'package:fall_detection/models/emergency_contact.dart';
import 'package:fall_detection/constants/app_constants.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isProfileLoaded => _userProfile != null && !_isLoading;

  UserProfileProvider() {
    _initUserProfileListener();
  }

  void _initUserProfileListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            _userProfile = UserProfile.fromFirestore(snapshot);
            _userProfile = _userProfile!.copyWith(
              profileComplete: AppConstants.isProfileComplete(_userProfile!),
            );
          } else {
            _userProfile = UserProfile(uid: user.uid, email: user.email);
          }
          notifyListeners();
        }, onError: (error) {
          _errorMessage = 'Failed to load user profile: $error';
          notifyListeners();
        });
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  Future<void> refreshUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await user.reload();
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
        _userProfile = _userProfile!.copyWith(
          profileComplete: AppConstants.isProfileComplete(_userProfile!),
        );
      } else {
        _userProfile = UserProfile(uid: user.uid, email: user.email);
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not logged in.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        data,
        SetOptions(merge: true),
      );
      await refreshUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonalInfo({
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? weight,
    String? height,
    String? bloodGroup,
    String? mobilityLevel,
    String? homeAddress,
    bool? livingAlone,
    bool? hasCaregiver, required String email, required String emergencyContact,
  }) async {
    final updatedProfile = _userProfile?.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      gender: gender,
      weight: weight,
      height: height,
      bloodGroup: bloodGroup,
      mobilityLevel: mobilityLevel,
      homeAddress: homeAddress,
      livingAlone: livingAlone,
      hasCaregiver: hasCaregiver,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  Future<void> updateHealthInfo({
    String? medicalConditions,
    String? medications,
    String? allergies,
    String? doctorName,
    String? doctorPhone,
    String? insuranceProvider,
    String? insuranceNumber,
    String? emergencyMedicalInfo,
    String? activityLevel,
    bool? hasMedicalConditions,
    bool? takingMedications,
    bool? hasAllergies,
    bool? hasInsurance,
    String? sleepHours,
    bool? hasPreviousFalls,
    String? fallDescription,
    String? hasPrevious,
    String? mobilityLevel,
    String? bloodGroup,
    String? height,
    String? weight,
  }) async {
    final updatedProfile = _userProfile?.copyWith(
      medicalConditions: medicalConditions,
      medications: medications,
      allergies: allergies,
      doctorName: doctorName,
      doctorPhone: doctorPhone,
      insuranceProvider: insuranceProvider,
      insuranceNumber: insuranceNumber,
      emergencyMedicalInfo: emergencyMedicalInfo,
      activityLevel: activityLevel,
      hasMedicalConditions: hasMedicalConditions,
      takingMedications: takingMedications,
      hasAllergies: hasAllergies,
      hasInsurance: hasInsurance,
      sleepHours: sleepHours,
      hasPreviousFalls: hasPreviousFalls,
      fallDescription: fallDescription,
      hasPrevious: hasPrevious,
      mobilityLevel: mobilityLevel,
      bloodGroup: bloodGroup,
      height: height,
      weight: weight,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  Future<void> updateLocationInfo({
    String? homeAddress,
    String? workAddress,
    String? emergencyAddress,
    bool? shareLocation,
    bool? allowGPS,
    bool? locationHistory,
    String? currentLocation,
    String? lastKnownLocation,
  }) async {
    final updatedProfile = _userProfile?.copyWith(
      homeAddress: homeAddress,
      workAddress: workAddress,
      emergencyAddress: emergencyAddress,
      shareLocation: shareLocation,
      allowGPS: allowGPS,
      locationHistory: locationHistory,
      currentLocation: currentLocation,
      lastKnownLocation: lastKnownLocation,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  // New method to add a single emergency contact
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    final currentContacts = List<EmergencyContact>.from(_userProfile?.emergencyContacts ?? []);
    currentContacts.add(contact);
    await updateEmergencyContacts(currentContacts);
  }

  // New method to delete a single emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    final currentContacts = List<EmergencyContact>.from(_userProfile?.emergencyContacts ?? []);
    currentContacts.removeWhere((contact) => contact.id == contactId);
    await updateEmergencyContacts(currentContacts);
  }

  // Existing method to update the entire list of emergency contacts
  Future<void> updateEmergencyContacts(List<EmergencyContact> contacts) async {
    final updatedProfile = _userProfile?.copyWith(
      emergencyContacts: contacts,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  Future<void> updatePreferences({
    bool? wearsSmartwatch,
    bool? allowSensorAccess,
    bool? allowCameraMonitoring,
    String? preferredAlertMethod,
    String? language,
    bool? voiceGuidance,
    bool? highContrast,
    bool? largerFonts,
  }) async {
    final updatedProfile = _userProfile?.copyWith(
      wearsSmartwatch: wearsSmartwatch,
      allowSensorAccess: allowSensorAccess,
      allowCameraMonitoring: allowCameraMonitoring,
      preferredAlertMethod: preferredAlertMethod,
      language: language,
      voiceGuidance: voiceGuidance,
      highContrast: highContrast,
      largerFonts: largerFonts,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  Future<void> updateAppSettings({
    String? theme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkMode,
    bool? autoBackup,
    String? backupFrequency,
    String? dataRetention,
    String? language,
    bool? highContrast,
    bool? largerFonts,
    bool? wearsSmartwatch,
  }) async {
    final updatedProfile = _userProfile?.copyWith(
      theme: theme,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      darkMode: darkMode,
      autoBackup: autoBackup,
      backupFrequency: backupFrequency,
      dataRetention: dataRetention,
      language: language,
      highContrast: highContrast,
      largerFonts: largerFonts,
      wearsSmartwatch: wearsSmartwatch,
    );

    if (updatedProfile != null) {
      await updateProfile(updatedProfile.toFirestore());
    }
  }

  Future<void> completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(profileComplete: true);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'profileComplete': true},
        SetOptions(merge: true),
      );
      notifyListeners();
    }
  }

  void clearProfile() {
    _userProfile = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

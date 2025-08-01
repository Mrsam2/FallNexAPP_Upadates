import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userData = {};
  bool _isLoading = false;

  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        _userData = userDoc.data() as Map<String, dynamic>;
      } else {
        // Create user document if it doesn't exist
        await _createUserDocument(currentUser);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserDocument(User user) async {
    try {
      final userData = {
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      _userData = userData;
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String age,
    required String gender,
    required String medicalConditions,
    required String medications,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedData = {
        'name': name,
        'age': age,
        'gender': gender,
        'medicalConditions': medicalConditions,
        'medications': medications,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedData);

      _userData = {..._userData, ...updatedData};
    } catch (e) {
      print('Error updating user profile: $e');
      throw e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to refresh user data - this was missing!
  Future<void> refreshUserData() async {
    await fetchUserData();
  }

  // Method to get user data for PDF generation - this was missing!
  Map<String, dynamic> getUserDataForPDF() {
    return Map<String, dynamic>.from(_userData);
  }

  // Additional helper method to clear user data on logout
  void clearUserData() {
    _userData = {};
    notifyListeners();
  }

  // Method to check if profile is complete
  bool get isProfileComplete => _userData['profileComplete'] == true;

  // Method to get user's display name
  String get displayName => _userData['name'] ?? _auth.currentUser?.displayName ?? 'User';

  // Method to get user's email
  String get userEmail => _userData['email'] ?? _auth.currentUser?.email ?? '';
}

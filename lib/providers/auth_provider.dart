import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true; // Initial state is loading until auth state is determined

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isLoading = false; // Auth state has been determined, so loading is complete
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true; // Indicate loading started
    notifyListeners(); // Notify listeners about loading state
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // The authStateChanges listener will handle setting _currentUser and _isLoading = false
      // upon successful sign-in.
    } on FirebaseAuthException {
      // If an error occurs, ensure loading state is reset
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw the exception so LoginScreen can catch and display it
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } finally {
      // For non-auth state changing operations, reset loading here
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      // The authStateChanges listener will handle setting _currentUser = null and _isLoading = false
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}


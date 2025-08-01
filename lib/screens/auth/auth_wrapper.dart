import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/auth_provider.dart';
import 'package:fall_detection/profile/user_profile_provider.dart';
import 'package:fall_detection/screens/auth/login_screen.dart';
import 'package:fall_detection/screens/home/home_screen.dart';
import 'package:fall_detection/constants/app_constants.dart';

import '../profile/user_profile_provider.dart'; // Import AppConstants

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final firebaseUser = authProvider.currentUser;

    // Debug prints to understand the flow
    debugPrint('AuthWrapper rebuild:');
    debugPrint('  authProvider.isLoading: ${authProvider.isLoading}');
    debugPrint('  profileProvider.isLoading: ${profileProvider.isLoading}');
    debugPrint('  firebaseUser: ${firebaseUser?.email} (UID: ${firebaseUser?.uid})');
    debugPrint('  profileProvider.isProfileLoaded: ${profileProvider.isProfileLoaded}');
    debugPrint('  profileProvider.userProfile?.profileComplete: ${profileProvider.userProfile?.profileComplete}');

    if (authProvider.isLoading || profileProvider.isLoading) {
      debugPrint('  -> Auth or Profile is loading. Showing loading indicator.');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (firebaseUser == null) {
      debugPrint('  -> No firebaseUser. Showing LoginScreen.');
      return const LoginScreen();
    } else {
      // User is logged in. Now check if profile is loaded.
      if (!profileProvider.isProfileLoaded) {
        debugPrint('  -> firebaseUser exists, but profile not loaded. Showing loading indicator.');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        // Profile is loaded.
        // Bypass the profile completion check and always go to HomeScreen
        debugPrint('  -> firebaseUser exists and profile loaded. Showing HomeScreen.');
        return const HomeScreen();
      }
    }
  }
}

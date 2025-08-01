import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Corrected import path
import 'package:fall_detection/screens/onboarding/personal_info_screen.dart';
import 'package:fall_detection/screens/onboarding/health_info_screen.dart';
import 'package:fall_detection/screens/onboarding/emergency_contacts_screen.dart';
import 'package:fall_detection/screens/onboarding/preferences_screen.dart';
import 'package:fall_detection/screens/home/home_screen.dart';

import '../profile/user_profile_provider.dart'; // Import HomeScreen

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Create GlobalKeys to access child screen methods
  final GlobalKey<PersonalInfoScreenState> _personalInfoKey = GlobalKey<PersonalInfoScreenState>();
  final GlobalKey<HealthInfoScreenState> _healthInfoKey = GlobalKey<HealthInfoScreenState>();
  final GlobalKey<EmergencyContactsScreenState> _emergencyContactsKey = GlobalKey<EmergencyContactsScreenState>();
  final GlobalKey<PreferencesScreenState> _preferencesKey = GlobalKey<PreferencesScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PersonalInfoScreen(key: _personalInfoKey),
      HealthInfoScreen(key: _healthInfoKey),
      EmergencyContactsScreen(key: _emergencyContactsKey),
      PreferencesScreen(key: _preferencesKey),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    // Save current page data before moving to next
    bool saved = await _saveCurrentPageData();
    if (!saved) {
      _showErrorSnackBar('Please fill in all required fields before continuing.');
      return;
    }

    if (_currentPage < _pages.length - 1) {
      if (!mounted) return; // Check mounted before setState
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      if (!mounted) return; // Check mounted before setState
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool> _saveCurrentPageData() async {
    try {
      switch (_currentPage) {
        case 0:
          return await _personalInfoKey.currentState?.savePersonalInfo() ?? false;
        case 1:
          return await _healthInfoKey.currentState?.saveHealthInfo() ?? false;
        case 2:
          _emergencyContactsKey.currentState?.saveEmergencyContacts();
          return true;
        case 3:
          _preferencesKey.currentState?.savePreferences();
          return true;
        default:
          return true;
      }
    } catch (e) {
      print('Error saving page data: $e');
      return false;
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // Save final page data
      bool saved = await _saveCurrentPageData();
      if (!saved) {
        _showErrorSnackBar('Please fill in all required fields before completing setup.');
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.completeProfile(); // This sets profileComplete to true in Firestore

      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to HomeScreen after successful onboarding completion
        // This will replace the entire navigation stack, so the user can't go back to onboarding
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        _showErrorSnackBar('Failed to complete profile setup: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return; // Check mounted before showing SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setup Your Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentPage + 1} of ${_pages.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / _pages.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
              onPageChanged: (index) {
                if (!mounted) return; // Check mounted before setState
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? _completeOnboarding
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Complete Setup' : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fall_detection/screens/profile/sections/personal_info_section.dart';
import 'package:fall_detection/screens/profile/sections/health_info_section.dart';
import 'package:fall_detection/screens/profile/sections/emergency_contacts_section.dart';
import 'package:fall_detection/screens/profile/sections/location_info_section.dart';
import 'package:fall_detection/screens/profile/sections/ai_preferences_section.dart';
import 'package:fall_detection/screens/profile/sections/app_settings_section.dart';
import 'package:fall_detection/screens/profile/sections/account_management_section.dart';

import '../onboarding/personal_info_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Health'),
            Tab(text: 'Emergency'),
            Tab(text: 'Location'),
            Tab(text: 'AI & Sensors'),
            Tab(text: 'Settings'),
            Tab(text: 'Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PersonalInfoSection(),
          HealthInfoSection(),
          EmergencyContactsSection(),
          LocationInfoSection(),
          AIPreferencesSection(),
          AppSettingsSection(),
          AccountManagementSection(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/user_profile_provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => PreferencesScreenState();
}

class PreferencesScreenState extends State<PreferencesScreen> {
  bool _wearsSmartwatch = false;
  bool _allowSensorAccess = true;
  bool _allowCameraMonitoring = true;
  String _preferredAlertMethod = 'SMS';
  String _selectedLanguage = 'English';
  bool _voiceGuidance = false;
  bool _highContrast = false;
  bool _largerFonts = false;

  final List<String> _alertMethods = ['SMS', 'Call', 'Notification', 'All'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    _wearsSmartwatch = profile!.wearsSmartwatch ?? false;
    _allowSensorAccess = profile.allowSensorAccess ?? true;
    _allowCameraMonitoring = profile.allowCameraMonitoring ?? true;
    _preferredAlertMethod = profile.preferredAlertMethod ?? 'SMS';
    _selectedLanguage = profile.language ?? 'English';
    _voiceGuidance = profile.voiceGuidance ?? false;
    _highContrast = profile.highContrast ?? false;
    _largerFonts = profile.largerFonts ?? false;
  }

  void savePreferences() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    profileProvider.updatePreferences(
      wearsSmartwatch: _wearsSmartwatch,
      allowSensorAccess: _allowSensorAccess,
      allowCameraMonitoring: _allowCameraMonitoring,
      preferredAlertMethod: _preferredAlertMethod,
      language: _selectedLanguage,
      voiceGuidance: _voiceGuidance,
      highContrast: _highContrast,
      largerFonts: _largerFonts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure how the app works for you.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Device Settings
          _buildSectionTitle('Device & Hardware Settings'),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Wears Smartwatch/Health Band'),
            subtitle: const Text('Do you wear a smartwatch or health monitoring device?'),
            value: _wearsSmartwatch,
            onChanged: (value) {
              setState(() {
                _wearsSmartwatch = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Allow Sensor Access'),
            subtitle: const Text('Allow access to accelerometer and gyroscope for fall detection'),
            value: _allowSensorAccess,
            onChanged: (value) {
              setState(() {
                _allowSensorAccess = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Allow Camera Monitoring'),
            subtitle: const Text('Allow camera access for visual fall detection'),
            value: _allowCameraMonitoring,
            onChanged: (value) {
              setState(() {
                _allowCameraMonitoring = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Alert Preferences
          _buildSectionTitle('Alert Preferences'),
          const SizedBox(height: 16),

          // Preferred Alert Method
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferred Alert Method',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _preferredAlertMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _alertMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _preferredAlertMethod = value ?? 'SMS';
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Preferences
          _buildSectionTitle('Language & Accessibility'),
          const SizedBox(height: 16),

          // Language Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language Preference',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value ?? 'English';
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Accessibility Options
          SwitchListTile(
            title: const Text('Voice Guidance'),
            subtitle: const Text('Enable voice instructions and feedback'),
            value: _voiceGuidance,
            onChanged: (value) {
              setState(() {
                _voiceGuidance = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('High Contrast UI'),
            subtitle: const Text('Use high contrast colors for better visibility'),
            value: _highContrast,
            onChanged: (value) {
              setState(() {
                _highContrast = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Larger Fonts'),
            subtitle: const Text('Use larger text throughout the app'),
            value: _largerFonts,
            onChanged: (value) {
              setState(() {
                _largerFonts = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Privacy Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Security',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All your data is encrypted and stored securely. You can modify these preferences anytime in the app settings.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

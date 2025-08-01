import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/profile/user_profile_provider.dart'; // Corrected import
import 'package:fall_detection/widgets/custom_button.dart';
import 'package:fall_detection/constants/app_constants.dart';

import '../user_profile_provider.dart' show UserProfileProvider;

class AIPreferencesSection extends StatefulWidget {
  const AIPreferencesSection({Key? key}) : super(key: key);

  @override
  State<AIPreferencesSection> createState() => _AIPreferencesSectionState();
}

class _AIPreferencesSectionState extends State<AIPreferencesSection> {
  bool _wearsSmartwatch = false;
  bool _allowSensorAccess = true;
  bool _allowCameraMonitoring = false;
  String _preferredAlertMethod = AppConstants.alertMethods[1]; // Default to Call
  String _language = AppConstants.languages[0]; // Default to English
  bool _voiceGuidance = true;
  bool _highContrast = false;
  bool _largerFonts = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    _wearsSmartwatch = profile?.wearsSmartwatch ?? false;
    _allowSensorAccess = profile?.allowSensorAccess ?? true;
    _allowCameraMonitoring = profile?.allowCameraMonitoring ?? false;

    // Use safe dropdown value validation with legacy mapping
    _preferredAlertMethod = AppConstants.mapLegacyValue(profile?.preferredAlertMethod, 'alert');
    _language = AppConstants.validateDropdownValue(
        profile?.language,
        AppConstants.languages,
        AppConstants.languages[0]
    );

    _voiceGuidance = profile?.voiceGuidance ?? true;
    _highContrast = profile?.highContrast ?? false;
    _largerFonts = profile?.largerFonts ?? false;
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updatePreferences(
        wearsSmartwatch: _wearsSmartwatch,
        allowSensorAccess: _allowSensorAccess,
        allowCameraMonitoring: _allowCameraMonitoring,
        preferredAlertMethod: _preferredAlertMethod,
        language: _language,
        voiceGuidance: _voiceGuidance,
        highContrast: _highContrast,
        largerFonts: _largerFonts,
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI preferences updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating AI preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI & Sensor Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure AI assistance and sensor settings',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Device Integration
          Text(
            'Device Integration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Smartwatch Integration'),
                  subtitle: const Text('Connect with your smartwatch for better monitoring'),
                  value: _wearsSmartwatch,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _wearsSmartwatch = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Sensor Access'),
                  subtitle: const Text('Allow access to device sensors for fall detection'),
                  value: _allowSensorAccess,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _allowSensorAccess = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Camera Monitoring'),
                  subtitle: const Text('Use camera for enhanced fall detection'),
                  value: _allowCameraMonitoring,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _allowCameraMonitoring = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alert Preferences
          Text(
            'Alert Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: AppConstants.getSafeDropdownValue(_preferredAlertMethod, AppConstants.alertMethods),
            decoration: const InputDecoration(
              labelText: 'Preferred Alert Method',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.alertMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: _isEditing ? (value) {
              setState(() {
                _preferredAlertMethod = value ?? AppConstants.alertMethods[1];
              });
            } : null,
          ),
          const SizedBox(height: 24),

          // Language & Accessibility
          Text(
            'Language & Accessibility',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: AppConstants.getSafeDropdownValue(_language, AppConstants.languages),
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.languages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: _isEditing ? (value) {
              setState(() {
                _language = value ?? AppConstants.languages[0];
              });
            } : null,
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Voice Guidance'),
                  subtitle: const Text('Enable voice instructions and feedback'),
                  value: _voiceGuidance,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _voiceGuidance = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('High Contrast'),
                  subtitle: const Text('Use high contrast colors for better visibility'),
                  value: _highContrast,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _highContrast = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Larger Fonts'),
                  subtitle: const Text('Use larger text for better readability'),
                  value: _largerFonts,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _largerFonts = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // AI Information
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Features',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• AI learns your movement patterns for better detection\n'
                        '• Smart alerts reduce false positives\n'
                        '• Personalized recommendations based on your data\n'
                        '• Privacy-first approach - data stays on your device',
                    style: TextStyle(color: Colors.purple[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _isEditing = false;
                        _loadPreferences();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _savePreferences,
                  ),
                ),
              ],
            )
          else
            CustomButton(
              text: 'Edit AI Preferences',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
    );
  }
}

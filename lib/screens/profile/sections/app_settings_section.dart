import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/profile/user_profile_provider.dart'; // Corrected import
import 'package:fall_detection/widgets/custom_button.dart';
import 'package:fall_detection/constants/app_constants.dart';

import '../user_profile_provider.dart' show UserProfileProvider; // Import AppConstants

class AppSettingsSection extends StatefulWidget {
  const AppSettingsSection({Key? key}) : super(key: key);

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  String _language = AppConstants.languages[0]; // Default to English
  String _theme = AppConstants.themes[2]; // Default to System
  bool _highContrast = false;
  bool _largerFonts = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _autoBackup = true;
  String _backupFrequency = AppConstants.backupFrequencies[0]; // Default to Daily
  String _dataRetention = AppConstants.dataRetentionOptions[3]; // Default to 1 Year
  bool _isLoading = false;
  bool _isEditing = false; // Added editing state

  final List<String> _languages = AppConstants.languages;
  final List<String> _themes = AppConstants.themes;
  final List<String> _backupFrequencies = AppConstants.backupFrequencies;
  final List<String> _dataRetentionOptions = AppConstants.dataRetentionOptions;

  @override
  void initState() {
    super.initState();
    _loadAppSettings();
  }

  void _loadAppSettings() {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = provider.userProfile;

    _language = AppConstants.validateDropdownValue(profile?.language, AppConstants.languages, AppConstants.languages[0]);
    _theme = AppConstants.validateDropdownValue(profile?.theme, AppConstants.themes, AppConstants.themes[2]);
    _highContrast = profile?.highContrast ?? false;
    _largerFonts = profile?.largerFonts ?? false;
    _notificationsEnabled = profile?.notificationsEnabled ?? true;
    _soundEnabled = profile?.soundEnabled ?? true;
    _vibrationEnabled = profile?.vibrationEnabled ?? true;
    _darkMode = profile?.darkMode ?? false;
    _autoBackup = profile?.autoBackup ?? true;
    _backupFrequency = AppConstants.validateDropdownValue(profile?.backupFrequency, AppConstants.backupFrequencies, AppConstants.backupFrequencies[0]);
    _dataRetention = AppConstants.validateDropdownValue(profile?.dataRetention, AppConstants.dataRetentionOptions, AppConstants.dataRetentionOptions[3]);
  }

  Future<void> _saveAppSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updateAppSettings(
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        vibrationEnabled: _vibrationEnabled,
        darkMode: _darkMode,
        autoBackup: _autoBackup,
        backupFrequency: _backupFrequency,
        dataRetention: _dataRetention,
        language: _language,
        theme: _theme,
        highContrast: _highContrast,
        largerFonts: _largerFonts,
        // wearsSmartwatch: _wearsSmartwatch, // This field is managed in AI Preferences
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating app settings: $e'),
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
            'App Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure app behavior and preferences',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Notifications
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive app notifications'),
                  value: _notificationsEnabled,
                  onChanged: _isEditing ? (value) { // Only allow changing when editing
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play notification sounds'),
                  value: _soundEnabled,
                  onChanged: _isEditing && _notificationsEnabled ? (value) { // Only allow changing when editing and notifications enabled
                    setState(() {
                      _soundEnabled = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: _vibrationEnabled,
                  onChanged: _isEditing && _notificationsEnabled ? (value) { // Only allow changing when editing and notifications enabled
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: AppConstants.getSafeDropdownValue(_theme, _themes),
                    decoration: const InputDecoration(
                      labelText: 'Theme',
                      border: OutlineInputBorder(),
                    ),
                    items: _themes.map((theme) {
                      return DropdownMenuItem(
                        value: theme,
                        child: Text(theme),
                      );
                    }).toList(),
                    onChanged: _isEditing ? (value) { // Only allow changing when editing
                      setState(() {
                        _theme = value!;
                      });
                    } : null,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('High Contrast'),
                  subtitle: const Text('Increase contrast for better visibility'),
                  value: _highContrast,
                  onChanged: _isEditing ? (value) { // Only allow changing when editing
                    setState(() {
                      _highContrast = value;
                    });
                  } : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Larger Fonts'),
                  subtitle: const Text('Increase font size for better readability'),
                  value: _largerFonts,
                  onChanged: _isEditing ? (value) { // Only allow changing when editing
                    setState(() {
                      _largerFonts = value;
                    });
                  } : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Backup
          Text(
            'Data & Backup',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup your data'),
                  value: _autoBackup,
                  onChanged: _isEditing ? (value) { // Only allow changing when editing
                    setState(() {
                      _autoBackup = value;
                    });
                  } : null,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                if (_autoBackup) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: AppConstants.getSafeDropdownValue(_backupFrequency, _backupFrequencies),
                      decoration: const InputDecoration(
                        labelText: 'Backup Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: _backupFrequencies.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: _isEditing ? (value) { // Only allow changing when editing
                        setState(() {
                          _backupFrequency = value ?? AppConstants.backupFrequencies[0];
                        });
                      } : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: AppConstants.getSafeDropdownValue(_dataRetention, _dataRetentionOptions),
                    decoration: const InputDecoration(
                      labelText: 'Data Retention',
                      border: OutlineInputBorder(),
                    ),
                    items: _dataRetentionOptions.map((retention) {
                      return DropdownMenuItem(
                        value: retention,
                        child: Text(retention),
                      );
                    }).toList(),
                    onChanged: _isEditing ? (value) { // Only allow changing when editing
                      setState(() {
                        _dataRetention = value ?? AppConstants.dataRetentionOptions[3];
                      });
                    } : null,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language & Region
          Text(
            'Language & Region',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: AppConstants.getSafeDropdownValue(_language, _languages),
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    items: _languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: _isEditing ? (value) { // Only allow changing when editing
                      setState(() {
                        _language = value!;
                      });
                    } : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Information
          Text(
            'App Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Version'),
                      Text(
                        '1.0.0',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Build'),
                      Text(
                        '2024.01.15',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
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
                        _loadAppSettings(); // Reload to discard changes
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
                    onPressed: _saveAppSettings,
                  ),
                ),
              ],
            )
          else
            CustomButton(
              text: 'Edit App Settings',
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

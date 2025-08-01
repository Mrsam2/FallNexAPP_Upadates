import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/sensor_data_provider.dart';
import 'package:fall_detection/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _autoSendSMSEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedSensitivity = 'Medium';
  
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your fall detection system',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsCard(
              title: 'Fall Detection',
              children: [
                _buildSettingsTile(
                  title: 'Detection Sensitivity',
                  subtitle: 'Adjust how sensitive the fall detection is',
                  trailing: DropdownButton<String>(
                    value: _selectedSensitivity,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSensitivity = newValue;
                        });
                      }
                    },
                    items: <String>['Low', 'Medium', 'High']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: Container(),
                  ),
                ),
                _buildSwitchTile(
                  title: 'Test Fall Detection',
                  subtitle: 'Trigger a test fall detection alert',
                  value: false,
                  onChanged: (value) {
                    if (value) {
                      sensorProvider.triggerManualSOS();
                      
                      // Reset switch after triggering
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {});
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive alerts when falls are detected',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Auto-send SMS',
                  subtitle: 'Automatically send SMS to emergency contacts',
                  value: _autoSendSMSEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoSendSMSEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              title: 'Location',
              children: [
                _buildSwitchTile(
                  title: 'Location Tracking',
                  subtitle: 'Track location for emergency response',
                  value: _locationTrackingEnabled,
                  onChanged: (value) {
                    setState(() {
                      _locationTrackingEnabled = value;
                    });
                    
                    if (value) {
                      sensorProvider.startMonitoring();
                    } else {
                      sensorProvider.stopMonitoring();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              title: 'Appearance',
              children: [
                _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    // In a real app, this would update the theme
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              title: 'About',
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    // Show app info
                  },
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}

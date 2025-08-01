import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:fall_detection/widgets/custom_button.dart';

import '../user_profile_provider.dart';

class LocationInfoSection extends StatefulWidget {
  const LocationInfoSection({super.key});

  @override
  State<LocationInfoSection> createState() => _LocationInfoSectionState();
}

class _LocationInfoSectionState extends State<LocationInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _homeAddressController = TextEditingController();
  final _workAddressController = TextEditingController();
  final _emergencyAddressController = TextEditingController();

  bool _shareLocation = true;
  bool _allowGPS = true;
  bool _locationHistory = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocationInfo();
  }

  @override
  void dispose() {
    _homeAddressController.dispose();
    _workAddressController.dispose();
    _emergencyAddressController.dispose();
    super.dispose();
  }

  void _loadLocationInfo() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    _homeAddressController.text = profile?.homeAddress ?? '';
    _workAddressController.text = profile?.workAddress ?? '';
    _emergencyAddressController.text = profile?.emergencyAddress ?? '';
    _shareLocation = profile?.shareLocation ?? true;
    _allowGPS = profile?.allowGPS ?? true;
    _locationHistory = profile?.locationHistory ?? false;
  }

  Future<void> _saveLocationInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updateLocationInfo(
        homeAddress: _homeAddressController.text.trim(),
        workAddress: _workAddressController.text.trim(),
        emergencyAddress: _emergencyAddressController.text.trim(),
        shareLocation: _shareLocation,
        allowGPS: _allowGPS,
        locationHistory: _locationHistory,
        currentLocation: '', // Assuming these are not user-editable in this section
        lastKnownLocation: '', // Assuming these are not user-editable in this section
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location info: $e'),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your location settings and addresses',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Addresses Section
            Text(
              'Addresses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _homeAddressController,
              labelText: 'Home Address',
              maxLines: 2,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your home address';
                }
                return null;
              }, label: '',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _workAddressController,
              labelText: 'Work Address (Optional)',
              maxLines: 2,
              enabled: _isEditing, label: '',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emergencyAddressController,
              labelText: 'Emergency Contact Address (Optional)',
              maxLines: 2,
              enabled: _isEditing, label: '',
            ),
            const SizedBox(height: 24),

            // Location Settings
            Text(
              'Location Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Share Location'),
                    subtitle: const Text('Allow sharing location with emergency contacts'),
                    value: _shareLocation,
                    onChanged: _isEditing ? (value) {
                      setState(() {
                        _shareLocation = value;
                      });
                    } : null,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('GPS Access'),
                    subtitle: const Text('Allow app to access GPS for location tracking'),
                    value: _allowGPS,
                    onChanged: _isEditing ? (value) {
                      setState(() {
                        _allowGPS = value;
                      });
                    } : null,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Location History'),
                    subtitle: const Text('Keep history of locations for analysis'),
                    value: _locationHistory,
                    onChanged: _isEditing ? (value) {
                      setState(() {
                        _locationHistory = value;
                      });
                    } : null,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Information
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '? Location data is encrypted and stored securely\n'
                          '? GPS access is only used for fall detection and emergencies\n'
                          '? You can disable location sharing at any time\n'
                          '? Location history helps improve fall detection accuracy',
                      style: TextStyle(color: Colors.blue[600]),
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
                          _loadLocationInfo();
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
                      onPressed: _saveLocationInfo,
                    ),
                  ),
                ],
              )
            else
              CustomButton(
                text: 'Edit Location Information',
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

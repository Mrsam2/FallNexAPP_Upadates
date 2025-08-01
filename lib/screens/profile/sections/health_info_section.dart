import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Corrected import
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:fall_detection/widgets/custom_button.dart';
import 'package:fall_detection/constants/app_constants.dart';

import '../user_profile_provider.dart';

class HealthInfoSection extends StatefulWidget {
  const HealthInfoSection({Key? key}) : super(key: key);

  @override
  State<HealthInfoSection> createState() => _HealthInfoSectionState();
}

class _HealthInfoSectionState extends State<HealthInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _medicalConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _emergencyMedicalInfoController = TextEditingController();

  String _selectedActivityLevel = AppConstants.activityLevels[1];
  bool _hasMedicalConditions = false;
  bool _takingMedications = false;
  bool _hasAllergies = false;
  bool _hasInsurance = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHealthInfo();
  }

  @override
  void dispose() {
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _emergencyMedicalInfoController.dispose();
    super.dispose();
  }

  void _loadHealthInfo() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    _medicalConditionsController.text = profile?.medicalConditions ?? '';
    _medicationsController.text = profile?.medications ?? '';
    _allergiesController.text = profile?.allergies ?? '';
    _doctorNameController.text = profile?.doctorName ?? '';
    _doctorPhoneController.text = profile?.doctorPhone ?? '';
    _insuranceProviderController.text = profile?.insuranceProvider ?? '';
    _insuranceNumberController.text = profile?.insuranceNumber ?? '';
    _emergencyMedicalInfoController.text = profile?.emergencyMedicalInfo ?? '';

    // Use safe dropdown value validation with legacy mapping
    _selectedActivityLevel = AppConstants.mapLegacyValue(profile?.activityLevel, 'activity');

    _hasMedicalConditions = profile?.hasMedicalConditions ?? false;
    _takingMedications = profile?.takingMedications ?? false;
    _hasAllergies = profile?.hasAllergies ?? false;
    _hasInsurance = profile?.hasInsurance ?? false;
  }

  Future<void> _saveHealthInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updateHealthInfo(
        medicalConditions: _medicalConditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
        allergies: _allergiesController.text.trim(),
        doctorName: _doctorNameController.text.trim(),
        doctorPhone: _doctorPhoneController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim(),
        insuranceNumber: _insuranceNumberController.text.trim(),
        emergencyMedicalInfo: _emergencyMedicalInfoController.text.trim(),
        activityLevel: _selectedActivityLevel,
        hasMedicalConditions: _hasMedicalConditions,
        takingMedications: _takingMedications,
        hasAllergies: _hasAllergies,
        hasInsurance: _hasInsurance,
        sleepHours: '',
        hasPreviousFalls: false,
        fallDescription: '',
        hasPrevious: '',
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating health info: $e'),
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
              'Health Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your health details and medical information',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Activity Level
            DropdownButtonFormField<String>(
              value: AppConstants.getSafeDropdownValue(_selectedActivityLevel, AppConstants.activityLevels),
              decoration: const InputDecoration(
                labelText: 'Activity Level',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: _isEditing ? (value) {
                setState(() {
                  _selectedActivityLevel = value ?? AppConstants.activityLevels[1];
                });
              } : null,
            ),
            const SizedBox(height: 24),

            // Medical Conditions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Conditions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Has Medical Conditions'),
                      value: _hasMedicalConditions,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _hasMedicalConditions = value;
                        });
                      } : null,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    if (_hasMedicalConditions) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _medicalConditionsController,
                        labelText: 'Medical Conditions',
                        maxLines: 3,
                        enabled: _isEditing,
                        validator: _hasMedicalConditions ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please list your medical conditions';
                          }
                          return null;
                        } : null, label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Medications Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Taking Medications'),
                      value: _takingMedications,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _takingMedications = value;
                        });
                      } : null,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    if (_takingMedications) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _medicationsController,
                        labelText: 'Current Medications',
                        maxLines: 3,
                        enabled: _isEditing,
                        validator: _takingMedications ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please list your medications';
                          }
                          return null;
                        } : null, label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Allergies Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allergies',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Has Allergies'),
                      value: _hasAllergies,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _hasAllergies = value;
                        });
                      } : null,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    if (_hasAllergies) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _allergiesController,
                        labelText: 'Allergies',
                        maxLines: 2,
                        enabled: _isEditing,
                        validator: _hasAllergies ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please list your allergies';
                          }
                          return null;
                        } : null, label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Doctor Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Doctor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _doctorNameController,
                      labelText: 'Doctor Name',
                      enabled: _isEditing, label: '', initialValue: '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _doctorPhoneController,
                      labelText: 'Doctor Phone',
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !AppConstants.isValidPhoneNumber(value)) {
                          return AppConstants.phoneErrorMessage;
                        }
                        return null;
                      }, label: '',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Insurance Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insurance Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Has Insurance'),
                      value: _hasInsurance,
                      onChanged: _isEditing ? (value) {
                        setState(() {
                          _hasInsurance = value;
                        });
                      } : null,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    if (_hasInsurance) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _insuranceProviderController,
                        labelText: 'Insurance Provider',
                        enabled: _isEditing, label: '',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _insuranceNumberController,
                        labelText: 'Insurance Number',
                        enabled: _isEditing, label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Medical Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Medical Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Important medical information for emergency responders',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emergencyMedicalInfoController,
                      labelText: 'Emergency Medical Info',
                      maxLines: 3,
                      enabled: _isEditing, label: '',
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
                          _loadHealthInfo();
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
                      onPressed: _saveHealthInfo,
                    ),
                  ),
                ],
              )
            else
              CustomButton(
                text: 'Edit Health Information',
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

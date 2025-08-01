import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fall_detection/profile/user_profile_provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:fall_detection/widgets/custom_button.dart';
import 'package:fall_detection/constants/app_constants.dart';
import 'package:fall_detection/widgets/profile_completion_dialog.dart';

import '../user_profile_provider.dart';

class PersonalInfoSection extends StatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _homeAddressController = TextEditingController();

  String _selectedGender = AppConstants.genderOptions[0];
  String _selectedBloodGroup = AppConstants.bloodGroups[0];
  String _selectedMobilityLevel = AppConstants.mobilityLevels[0];
  bool _livingAlone = false;
  bool _hasCaregiver = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersonalInfo();
      // Only show completion dialog if not already editing
      if (!_isEditing) {
        _checkProfileCompleteness();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _homeAddressController.dispose();
    super.dispose();
  }

  void _loadPersonalInfo() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;
    final user = FirebaseAuth.instance.currentUser;

    // Load data from both Firebase Auth and Firestore
    _fullNameController.text = profile?.fullName ?? user?.displayName ?? '';
    _phoneNumberController.text = profile?.phoneNumber ?? '';
    _emailController.text = user?.email ?? profile?.email ?? '';
    _dateOfBirthController.text = profile?.dateOfBirth ?? '';
    _weightController.text = profile?.weight ?? '';
    _heightController.text = profile?.height ?? '';
    _homeAddressController.text = profile?.homeAddress ?? '';

    // Use safe dropdown value validation
    _selectedGender = AppConstants.getSafeDropdownValue(profile?.gender, AppConstants.genderOptions) ?? AppConstants.genderOptions[0];
    _selectedBloodGroup = AppConstants.getSafeDropdownValue(profile?.bloodGroup, AppConstants.bloodGroups) ?? AppConstants.bloodGroups[0];
    _selectedMobilityLevel = AppConstants.getSafeDropdownValue(profile?.mobilityLevel, AppConstants.mobilityLevels) ?? AppConstants.mobilityLevels[0];

    _livingAlone = profile?.livingAlone ?? false;
    _hasCaregiver = profile?.hasCaregiver ?? false;

    // Trigger a rebuild to show the loaded data
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updatePersonalInfo(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        gender: _selectedGender,
        weight: _weightController.text.trim(),
        height: _heightController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        mobilityLevel: _selectedMobilityLevel,
        homeAddress: _homeAddressController.text.trim(),
        livingAlone: _livingAlone,
        hasCaregiver: _hasCaregiver, email: '', emergencyContact: '',
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating personal info: $e'),
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

  void _checkProfileCompleteness() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    if (profile != null && !AppConstants.isProfileComplete(profile)) {
      final incompleteFields = AppConstants.getIncompleteFields(profile);
      final totalRequiredFields = AppConstants.requiredProfileFields.length;
      final completedFields = totalRequiredFields - incompleteFields.length;
      final completionPercentage = ((completedFields / totalRequiredFields) * 100).roundToDouble();

      // Show the dialog after a short delay to ensure the page is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isEditing) {
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withAlpha((255 * 0.8).round()),
            builder: (context) => ModernProfileCompletionDialog(
              userProfile: profile,
              onCompleteProfile: () {
                setState(() {
                  _isEditing = true;
                });
                Navigator.of(context).pop();
              },
              onDismiss: () {
                Navigator.of(context).pop();
              },
              missingFields: incompleteFields,
              completionPercentage: completionPercentage,
            ),
          );
        }
      });
    }
  }

  Widget _buildCompletionStatus() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final incompleteFields = AppConstants.getIncompleteFields(profile);
    final totalRequiredFields = AppConstants.requiredProfileFields.length;
    final completedFields = totalRequiredFields - incompleteFields.length;
    final completionPercentage = ((completedFields / totalRequiredFields) * 100).round();

    if (incompleteFields.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profile Complete! All required information has been provided.',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profile $completionPercentage% Complete',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!_isEditing)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  child: const Text('Complete Now'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.orange[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
          ),
          if (incompleteFields.length <= 3) ...[
            const SizedBox(height: 8),
            Text(
              'Missing: ${incompleteFields.join(', ')}',
              style: TextStyle(
                color: Colors.orange[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        // Reload data when provider updates, but only if not currently editing or loading
        if (!_isEditing && !_isLoading && profileProvider.userProfile != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadPersonalInfo();
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_isEditing)
                      IconButton(
                        onPressed: () {
                          profileProvider.refreshUserProfile();
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This information helps us provide better care and emergency response.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Only build completion status if profile is available
                if (profileProvider.userProfile != null)
                  _buildCompletionStatus(),

                // Full Name
                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppConstants.requiredFieldMessage;
                    }
                    return null;
                  }, label: '',
                ),
                const SizedBox(height: 16),

                // Phone Number
                CustomTextField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppConstants.requiredFieldMessage;
                    }
                    if (!AppConstants.isValidPhoneNumber(value)) {
                      return AppConstants.phoneErrorMessage;
                    }
                    return null;
                  }, label: '',
                ),
                const SizedBox(height: 16),

                // Email (read-only)
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  enabled: false, label: '', // Email is always read-only as it's from Firebase Auth
                ),
                const SizedBox(height: 16),

                // Date of Birth
                GestureDetector(
                  onTap: _isEditing ? () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dateOfBirthController.text = '${date.day}/${date.month}/${date.year}';
                    }
                  } : null,
                  child: AbsorbPointer(
                    absorbing: !_isEditing, // Absorb pointer events if not editing
                    child: CustomTextField(
                      controller: _dateOfBirthController,
                      labelText: 'Date of Birth',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select your date of birth';
                        }
                        return null;
                      },
                      readOnly: true, label: '', // Make it read-only to prevent manual text input
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  value: AppConstants.getSafeDropdownValue(_selectedGender, AppConstants.genderOptions),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.genderOptions.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _selectedGender = value ?? AppConstants.genderOptions[0];
                    });
                  } : null,
                ),
                const SizedBox(height: 16),

                // Weight and Height
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _weightController,
                        labelText: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!AppConstants.isValidWeight(value)) {
                            return AppConstants.weightErrorMessage;
                          }
                          return null;
                        }, label: '',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _heightController,
                        labelText: 'Height (cm)',
                        keyboardType: TextInputType.number,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!AppConstants.isValidHeight(value)) {
                            return AppConstants.heightErrorMessage;
                          }
                          return null;
                        }, label: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Blood Group
                DropdownButtonFormField<String>(
                  value: AppConstants.getSafeDropdownValue(_selectedBloodGroup, AppConstants.bloodGroups),
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.bloodGroups.map((bloodGroup) {
                    return DropdownMenuItem(
                      value: bloodGroup,
                      child: Text(bloodGroup),
                    );
                  }).toList(),
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _selectedBloodGroup = value ?? AppConstants.bloodGroups[0];
                    });
                  } : null,
                ),
                const SizedBox(height: 16),

                // Mobility Level
                DropdownButtonFormField<String>(
                  value: AppConstants.getSafeDropdownValue(_selectedMobilityLevel, AppConstants.mobilityLevels),
                  decoration: const InputDecoration(
                    labelText: 'Mobility Level',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.mobilityLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _selectedMobilityLevel = value ?? AppConstants.mobilityLevels[0];
                    });
                  } : null,
                ),
                const SizedBox(height: 16),

                // Home Address
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
                const SizedBox(height: 24),

                // Living Situation
                Text(
                  'Living Situation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Living Alone'),
                        subtitle: const Text('Do you live alone?'),
                        value: _livingAlone,
                        onChanged: _isEditing ? (value) {
                          setState(() {
                            _livingAlone = value;
                          });
                        } : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Has Caregiver'),
                        subtitle: const Text('Do you have a regular caregiver?'),
                        value: _hasCaregiver,
                        onChanged: _isEditing ? (value) {
                          setState(() {
                            _hasCaregiver = value;
                          });
                        } : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
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
                              _loadPersonalInfo();
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
                          onPressed: _savePersonalInfo,
                        ),
                      ),
                    ],
                  )
                else
                  CustomButton(
                    text: 'Edit Personal Information',
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
      },
    );
  }
}

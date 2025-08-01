import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/profile/user_profile_provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';

import '../profile/user_profile_provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => PersonalInfoScreenState();
}

class PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = '';
  String _selectedBloodGroup = '';
  String _selectedMobilityLevel = '';
  bool _livingAlone = false;
  bool _hasCaregiver = false;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _mobilityLevels = [
    'Fully mobile',
    'Walking aid (cane/walker)',
    'Wheelchair-bound',
    'Limited mobility'
  ];

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;

    _fullNameController.text = profile!.fullName ?? '';
    _phoneNumberController.text = profile.phoneNumber ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
    _weightController.text = profile.weight ?? '';
    _heightController.text = profile.height ?? '';
    _addressController.text = profile.homeAddress ?? '';

    // Safely initialize dropdown values
    _selectedGender = _genders.contains(profile.gender) ? profile.gender! : '';
    _selectedBloodGroup = _bloodGroups.contains(profile.bloodGroup) ? profile.bloodGroup! : '';
    _selectedMobilityLevel = _mobilityLevels.contains(profile.mobilityLevel) ? profile.mobilityLevel! : '';

    _livingAlone = profile.livingAlone ?? false;
    _hasCaregiver = profile.hasCaregiver ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<bool> savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) {
      print('Validation failed for PersonalInfoScreen.');
      return false;
    }

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updatePersonalInfo(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        dateOfBirth: _dobController.text,
        gender: _selectedGender,
        weight: _weightController.text,
        height: _heightController.text,
        bloodGroup: _selectedBloodGroup,
        mobilityLevel: _selectedMobilityLevel,
        homeAddress: _addressController.text,
        livingAlone: _livingAlone,
        hasCaregiver: _hasCaregiver, email: '', emergencyContact: '',
      );
      print('Personal info saved successfully.');
      return true;
    } catch (e) {
      print('Error saving personal info: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This information helps us provide better care and emergency response.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Full Name Field
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              }, label: '',
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            CustomTextField(
              controller: _phoneNumberController,
              labelText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              }, label: '',
            ),
            const SizedBox(height: 16),

            // Date of Birth
            CustomTextField(
              controller: _dobController,
              labelText: 'Date of Birth',
              prefixIcon: Icons.calendar_today,
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }
                return null;
              },
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _dobController.text = '${date.day}/${date.month}/${date.year}';
                }
              }, label: '',
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              value: _selectedGender.isEmpty ? null : _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Weight and Height
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _weightController,
                    labelText: 'Weight (kg)',
                    prefixIcon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
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
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
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
              value: _selectedBloodGroup.isEmpty ? null : _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: Icon(Icons.bloodtype),
                border: OutlineInputBorder(),
              ),
              items: _bloodGroups.map((bloodGroup) {
                return DropdownMenuItem(
                  value: bloodGroup,
                  child: Text(bloodGroup),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),

            // Mobility Level
            DropdownButtonFormField<String>(
              value: _selectedMobilityLevel.isEmpty ? null : _selectedMobilityLevel,
              decoration: const InputDecoration(
                labelText: 'Mobility Level',
                prefixIcon: Icon(Icons.accessibility),
                border: OutlineInputBorder(),
              ),
              items: _mobilityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMobilityLevel = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your mobility level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Home Address
            CustomTextField(
              controller: _addressController,
              labelText: 'Home Address',
              prefixIcon: Icons.home,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
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

            SwitchListTile(
              title: const Text('Living Alone'),
              subtitle: const Text('Do you live alone?'),
              value: _livingAlone,
              onChanged: (value) {
                setState(() {
                  _livingAlone = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Has Caregiver'),
              subtitle: const Text('Do you have a regular caregiver?'),
              value: _hasCaregiver,
              onChanged: (value) {
                setState(() {
                  _hasCaregiver = value;
                });
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

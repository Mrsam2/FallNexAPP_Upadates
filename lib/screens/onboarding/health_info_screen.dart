import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';

import '../profile/user_profile_provider.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  State<HealthInfoScreen> createState() => HealthInfoScreenState();
}

class HealthInfoScreenState extends State<HealthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _emergencyMedicalInfoController = TextEditingController();

  String _selectedActivityLevel = '';
  String _selectedBloodGroup = '';
  String _selectedMobilityLevel = '';
  bool _hasPreviousFalls = false;
  bool _hasMedicalConditions = false;
  bool _takingMedications = false;
  bool _hasAllergies = false;
  bool _hasInsurance = false;
  String _fallDescription = '';

  final List<String> _activityLevels = [
    'Sedentary (little to no exercise)',
    'Light (light exercise 1-3 days/week)',
    'Moderate (moderate exercise 3-5 days/week)',
    'Active (hard exercise 6-7 days/week)',
  ];

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

    _medicalConditionsController.text = profile!.medicalConditions ?? '';
    _allergiesController.text = profile.allergies ?? '';
    _medicationsController.text = profile.medications ?? '';
    _doctorNameController.text = profile.doctorName ?? '';
    _doctorPhoneController.text = profile.doctorPhone ?? '';
    _sleepHoursController.text = profile.sleepHours ?? '';
    _insuranceProviderController.text = profile.insuranceProvider ?? '';
    _insuranceNumberController.text = profile.insuranceNumber ?? '';
    _emergencyMedicalInfoController.text = profile.emergencyMedicalInfo ?? '';

    // Safely initialize dropdown values
    _selectedActivityLevel = _activityLevels.contains(profile.activityLevel) ? profile.activityLevel! : '';
    _selectedBloodGroup = _bloodGroups.contains(profile.bloodGroup) ? profile.bloodGroup! : ''; // Assuming _bloodGroups is defined here
    _selectedMobilityLevel = _mobilityLevels.contains(profile.mobilityLevel) ? profile.mobilityLevel! : '';

    _hasPreviousFalls = profile.hasPreviousFalls ?? false;
    _hasMedicalConditions = profile.hasMedicalConditions ?? false;
    _takingMedications = profile.takingMedications ?? false;
    _hasAllergies = profile.hasAllergies ?? false;
    _hasInsurance = profile.hasInsurance ?? false;
    _fallDescription = profile.fallDescription ?? '';
  }

  @override
  void dispose() {
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _sleepHoursController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    _emergencyMedicalInfoController.dispose();
    super.dispose();
  }

  Future<bool> saveHealthInfo() async {
    if (!_formKey.currentState!.validate()) {
      print('Validation failed for HealthInfoScreen.');
      return false;
    }

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await profileProvider.updateHealthInfo(
        medicalConditions: _medicalConditionsController.text,
        allergies: _allergiesController.text,
        medications: _medicationsController.text,
        doctorName: _doctorNameController.text,
        doctorPhone: _doctorPhoneController.text,
        sleepHours: _sleepHoursController.text,
        activityLevel: _selectedActivityLevel,
        hasPreviousFalls: _hasPreviousFalls,
        fallDescription: _fallDescription,
        bloodGroup: _selectedBloodGroup,
        mobilityLevel: _selectedMobilityLevel,
        hasMedicalConditions: _hasMedicalConditions,
        takingMedications: _takingMedications,
        hasAllergies: _hasAllergies,
        hasInsurance: _hasInsurance,
        emergencyMedicalInfo: _emergencyMedicalInfoController.text,
        insuranceProvider: _insuranceProviderController.text,
        insuranceNumber: _insuranceNumberController.text,
        hasPrevious: _hasPreviousFalls.toString(), // Ensure this is handled correctly in your UserProfile model
      );
      print('Health info saved successfully.');
      return true;
    } catch (e) {
      print('Error saving health info: $e');
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
              'Health Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This information helps emergency responders provide appropriate care.',
              style: TextStyle(color: Colors.grey[600]),
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
                      onChanged: (value) {
                        setState(() {
                          _hasMedicalConditions = value;
                        });
                      },
                    ),
                    if (_hasMedicalConditions) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _medicalConditionsController,
                        labelText: 'Medical Conditions',
                        maxLines: 3,
                        hintText: 'e.g., Diabetes, Heart disease, Arthritis', label: '',
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
                      onChanged: (value) {
                        setState(() {
                          _takingMedications = value;
                        });
                      },
                    ),
                    if (_takingMedications) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _medicationsController,
                        labelText: 'Current Medications',
                        maxLines: 3,
                        hintText: 'Include name, dosage, and timing', label: '',
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
                      onChanged: (value) {
                        setState(() {
                          _hasAllergies = value;
                        });
                      },
                    ),
                    if (_hasAllergies) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _allergiesController,
                        labelText: 'Known Allergies',
                        maxLines: 2,
                        hintText: 'e.g., Penicillin, Nuts, Latex', label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Doctor Information
            Text(
              'Primary Doctor Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _doctorNameController,
              labelText: 'Doctor Name', label: '',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _doctorPhoneController,
              labelText: 'Doctor Phone Number',
              keyboardType: TextInputType.phone, label: '',
            ),
            const SizedBox(height: 24),

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
                      onChanged: (value) {
                        setState(() {
                          _hasInsurance = value;
                        });
                      },
                    ),
                    if (_hasInsurance) ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _insuranceProviderController,
                        labelText: 'Insurance Provider', label: '',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _insuranceNumberController,
                        labelText: 'Insurance Number', label: '',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lifestyle Information
            Text(
              'Lifestyle Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Activity Level
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel.isEmpty ? null : _selectedActivityLevel,
              decoration: const InputDecoration(
                labelText: 'Daily Activity Level',
                border: OutlineInputBorder(),
              ),
              items: _activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your activity level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sleep Hours
            CustomTextField(
              controller: _sleepHoursController,
              labelText: 'Average Sleep Hours',
              keyboardType: TextInputType.number,
              hintText: 'e.g., 7-8 hours',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your average sleep hours';
                }
                return null;
              }, label: '',
            ),
            const SizedBox(height: 24),

            // Fall History
            Text(
              'Fall History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Previous Falls'),
              subtitle: const Text('Have you experienced falls in the past year?'),
              value: _hasPreviousFalls,
              onChanged: (value) {
                setState(() {
                  _hasPreviousFalls = value;
                });
              },
            ),

            if (_hasPreviousFalls) ...[
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Fall Description',
                maxLines: 3,
                hintText: 'Please describe when and how the falls occurred',
                onChanged: (value) {
                  _fallDescription = value;
                },
                initialValue: _fallDescription, label: '', controller: null,
              ),
            ],

            const SizedBox(height: 24),

            // Emergency Medical Information
            CustomTextField(
              controller: _emergencyMedicalInfoController,
              labelText: 'Emergency Medical Information',
              maxLines: 3,
              hintText: 'Important medical information for emergency responders', label: '',
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

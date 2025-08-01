import 'package:fall_detection/screens/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Assuming this is the correct AuthProvider
import 'package:fall_detection/widgets/custom_button.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
// Import UserProfileProvider
import 'package:fall_detection/models/user_profile.dart'; // Import UserProfile model

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    await userProfileProvider.refreshUserProfile(); // Ensure latest data is fetched

    final UserProfile? userData = userProfileProvider.userProfile;

    setState(() {
      _fullNameController.text = userData?.fullName ?? '';
      _dateOfBirthController.text = userData?.dateOfBirth ?? '';
      _genderController.text = userData?.gender ?? '';
      _medicalConditionsController.text = userData?.medicalConditions ?? '';
      _medicationsController.text = userData?.medications ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      await userProfileProvider.updatePersonalInfo(
        fullName: _fullNameController.text,
        dateOfBirth: _dateOfBirthController.text,
        gender: _genderController.text,
        // Assuming these fields are part of updateHealthInfo or a combined update
        // For simplicity, I'm mapping them to updatePersonalInfo for now.
        // In a real app, you'd call the appropriate update method (e.g., updateHealthInfo)
        // or have a single comprehensive update method.
        // medicalConditions: _medicalConditionsController.text,
        // medications: _medicationsController.text,
        phoneNumber: userProfileProvider.userProfile?.phoneNumber, email: '', emergencyContact: '', // Keep existing phone number
      );

      // If medical conditions/medications are separate, call updateHealthInfo
      await userProfileProvider.updateHealthInfo(
        medicalConditions: _medicalConditionsController.text,
        medications: _medicationsController.text,
        // Pass other required health info fields if any, or make them nullable in updateHealthInfo
        mobilityLevel: userProfileProvider.userProfile?.mobilityLevel,
        bloodGroup: userProfileProvider.userProfile?.bloodGroup,
        height: userProfileProvider.userProfile?.height,
        weight: userProfileProvider.userProfile?.weight,
      );

      if (!mounted) return;

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your medical information helps emergency responders',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    // Removed prefixIcon as CustomTextField doesn't have it
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    }, label: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _dateOfBirthController, // Changed from _ageController
                    labelText: 'Date of Birth', // Changed from Age
                    // Removed prefixIcon
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your date of birth';
                      }
                      return null;
                    }, label: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _genderController,
                    labelText: 'Gender',
                    // Removed prefixIcon
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your gender';
                      }
                      return null;
                    }, label: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _medicalConditionsController,
                    labelText: 'Medical Conditions',
                    // Removed prefixIcon
                    maxLines: 3,
                    enabled: _isEditing, label: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _medicationsController,
                    labelText: 'Current Medications',
                    // Removed prefixIcon
                    maxLines: 3,
                    enabled: _isEditing, label: '',
                  ),
                  const SizedBox(height: 32),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            isLoading: _isLoading,
                            onPressed: _saveProfile,
                          ),
                        ),
                      ],
                    )
                  else
                    CustomButton(
                      text: 'Edit Profile',
                      // Removed icon as CustomButton doesn't have it
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

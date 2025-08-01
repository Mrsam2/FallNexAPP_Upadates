import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fall_detection/models/emergency_contact.dart';
import 'package:fall_detection/profile/user_profile_provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
import 'package:fall_detection/constants/app_constants.dart';

import '../profile/user_profile_provider.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => EmergencyContactsScreenState();
}

class EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  // No TextEditingControllers here, they are managed by the dialog's state

  @override
  void dispose() {
    super.dispose();
  }

  // This method is called by OnboardingWrapper to ensure validation before proceeding
  Future<bool> saveEmergencyContacts() async {
    // Since emergency contacts are added/deleted via dialogs,
    // this method can simply return true if the screen itself doesn't have
    // a "save" button for its main content.
    return true;
  }

  void _showAddContactDialog(UserProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => _AddEmergencyContactDialog(
        profileProvider: profileProvider,
      ),
    );
  }

  Future<void> _deleteContact(UserProfileProvider profileProvider, String contactId) async {
    await profileProvider.deleteEmergencyContact(contactId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final List<EmergencyContact> contacts = profileProvider.userProfile?.emergencyContacts ?? [];
        final String? doctorName = profileProvider.userProfile?.doctorName;
        final String? doctorPhone = profileProvider.userProfile?.doctorPhone;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Contacts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage contacts for emergency situations',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_hospital,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Emergency Services',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'In case of life-threatening emergency, call emergency services immediately.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _callEmergency('911');
                          },
                          icon: const Icon(Icons.call),
                          label: const Text('Call 911'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Doctor's Contact Information
                if (doctorName != null && doctorName.isNotEmpty && doctorPhone != null && doctorPhone.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doctor\'s Contact',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    EmergencyContact(
                      id: 'doctor', // Unique ID for doctor
                      name: doctorName,
                      phoneNumber: doctorPhone,
                      relationship: 'Doctor',
                      isMedical: true,
                    ),
                    isDeletable: false, // Doctor's contact is not deletable from here
                    profileProvider: profileProvider,
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Contacts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddContactDialog(profileProvider),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (contacts.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contact_phone,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No emergency contacts added yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add contacts who should be notified in case of emergency',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...contacts.map((contact) => _buildContactCard(context, contact, profileProvider: profileProvider)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(BuildContext context, EmergencyContact contact, {bool isDeletable = true, required UserProfileProvider profileProvider}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (contact.isMedical ?? false)
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                (contact.isMedical ?? false) ? Icons.medical_services : Icons.person,
                color: (contact.isMedical ?? false)
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phoneNumber,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    contact.relationship,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call),
              color: Colors.green,
              onPressed: () {
                _callEmergency(contact.phoneNumber);
              },
            ),
            if (isDeletable)
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () {
                  _deleteContact(profileProvider, contact.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _callEmergency(String phoneNumber) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// New Stateful Widget for the Add Emergency Contact Dialog
class _AddEmergencyContactDialog extends StatefulWidget {
  final UserProfileProvider profileProvider;

  const _AddEmergencyContactDialog({
    Key? key,
    required this.profileProvider,
  }) : super(key: key);

  @override
  State<_AddEmergencyContactDialog> createState() => _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<_AddEmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isMedical = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _relationshipController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Emergency Contact'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                }, label: '',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!AppConstants.isValidPhoneNumber(value)) {
                    return AppConstants.phoneErrorMessage;
                  }
                  return null;
                }, label: '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: AppConstants.getSafeDropdownValue(_relationshipController.text, AppConstants.relationshipTypes),
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.relationshipTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _relationshipController.text = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isMedical,
                    onChanged: (value) {
                      setState(() {
                        _isMedical = value!;
                      });
                    },
                  ),
                  const Text('Medical Professional'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newContact = EmergencyContact(
                id: const Uuid().v4(),
                name: _nameController.text,
                phoneNumber: _phoneController.text,
                relationship: _relationshipController.text,
                isMedical: _isMedical,
              );
              await widget.profileProvider.addEmergencyContact(newContact);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

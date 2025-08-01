import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/profile/user_profile_provider.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:fall_detection/models/emergency_contact.dart';

import '../profile/user_profile_provider.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => EmergencyContactsScreenState();
}

class EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    _contacts.addAll(profileProvider.userProfile!.emergencyContacts ?? []);

    // Ensure at least one contact form is available
    if (_contacts.isEmpty) {
      _contacts.add(EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        phoneNumber: '',
        relationship: '',
      ));
    }
  }

  void _addContact() {
    setState(() {
      _contacts.add(EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        phoneNumber: '',
        relationship: '',
      ));
    });
  }

  void _removeContact(int index) {
    if (_contacts.length > 1) {
      setState(() {
        _contacts.removeAt(index);
      });
    }
  }

  void saveEmergencyContacts() {
    // Filter out empty contacts
    final validContacts = _contacts.where((contact) =>
    contact.name.isNotEmpty &&
        contact.phoneNumber.isNotEmpty &&
        contact.relationship.isNotEmpty).toList();

    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    profileProvider.updateEmergencyContacts(validContacts);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add people who should be contacted in case of emergency.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Emergency Contacts List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              return _buildContactForm(index);
            },
          ),

          const SizedBox(height: 16),

          // Add Contact Button
          OutlinedButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.add),
            label: const Text('Add Another Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          // Important Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'These contacts will be automatically notified if a fall is detected. Make sure to inform them about this system.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactForm(int index) {
    final contact = _contacts[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_contacts.length > 1)
                  IconButton(
                    onPressed: () => _removeContact(index),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            CustomTextField(
              labelText: 'Full Name',
              prefixIcon: Icons.person,
              initialValue: contact.name,
              onChanged: (value) {
                _contacts[index] = EmergencyContact(
                  id: contact.id,
                  name: value,
                  phoneNumber: contact.phoneNumber,
                  relationship: contact.relationship,
                );
              }, label: '',
            ),
            const SizedBox(height: 16),

            // Phone Number
            CustomTextField(
              labelText: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              initialValue: contact.phoneNumber,
              onChanged: (value) {
                _contacts[index] = EmergencyContact(
                  id: contact.id,
                  name: contact.name,
                  phoneNumber: value,
                  relationship: contact.relationship,
                );
              }, label: '',
            ),
            const SizedBox(height: 16),

            // Relationship
            CustomTextField(
              labelText: 'Relationship',
              prefixIcon: Icons.family_restroom,
              hintText: 'e.g., Daughter, Son, Neighbor, Friend',
              initialValue: contact.relationship,
              onChanged: (value) {
                _contacts[index] = EmergencyContact(
                  id: contact.id,
                  name: contact.name,
                  phoneNumber: contact.phoneNumber,
                  relationship: value,
                );
              }, label: '',
            ),
          ],
        ),
      ),
    );
  }
}

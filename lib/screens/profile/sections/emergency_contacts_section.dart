import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fall_detection/models/emergency_contact.dart';
import 'package:fall_detection/widgets/custom_text_field.dart';
import 'package:fall_detection/widgets/custom_button.dart';

import '../user_profile_provider.dart';


class EmergencyContactsSection extends StatefulWidget {
  const EmergencyContactsSection({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsSection> createState() => _EmergencyContactsSectionState();
}

class _EmergencyContactsSectionState extends State<EmergencyContactsSection> {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  bool _isEditing = false; // Added editing state

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  void _loadEmergencyContacts() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.userProfile;
    setState(() {
      _contacts = profile?.emergencyContacts ?? [];
    });
  }

  Future<void> _saveEmergencyContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      // Filter out empty contacts before saving
      final validContacts = _contacts.where((contact) =>
      contact.name.isNotEmpty &&
          contact.phoneNumber.isNotEmpty &&
          contact.relationship.isNotEmpty).toList();
      await profileProvider.updateEmergencyContacts(validContacts);

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contacts updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating emergency contacts: $e'),
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

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        onAdd: (contact) {
          setState(() {
            _contacts.add(contact);
          });
          _saveEmergencyContacts();
        },
      ),
    );
  }

  void _editContact(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddContactDialog(
        contact: _contacts[index],
        onAdd: (contact) {
          setState(() {
            _contacts[index] = contact;
          });
          _saveEmergencyContacts();
        },
      ),
    );
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${_contacts[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              _saveEmergencyContacts();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _callContact(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make phone call'),
            backgroundColor: Colors.red,
          ),
        );
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
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your emergency contacts for quick access during emergencies',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Add Contact Button
          CustomButton(
            text: 'Add Emergency Contact',
            onPressed: _isEditing ? _addContact : null, // Only allow adding when editing
          ),
          const SizedBox(height: 24),

          // Contacts List
          if (_contacts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.contacts,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Emergency Contacts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add emergency contacts to quickly reach help when needed',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.phoneNumber),
                        Text(
                          contact.relationship,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: _isEditing ? Row( // Only show edit/delete when editing
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _callContact(contact.phoneNumber),
                          icon: const Icon(Icons.call),
                          color: Colors.green,
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editContact(index);
                            } else if (value == 'delete') {
                              _deleteContact(index);
                            }
                          },
                        ),
                      ],
                    ) : null, // Hide trailing actions when not editing
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Emergency Instructions
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• In case of emergency, contacts will be called in order\n'
                        '• Make sure phone numbers are correct and active\n'
                        '• Consider adding at least 2-3 emergency contacts\n'
                        '• Include local emergency services if needed',
                    style: TextStyle(color: Colors.red[600]),
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
                        _loadEmergencyContacts(); // Reload to discard changes
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
                    onPressed: _saveEmergencyContacts,
                  ),
                ),
              ],
            )
          else
            CustomButton(
              text: 'Edit Emergency Contacts',
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

class _AddContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onAdd;

  const _AddContactDialog({
    this.contact,
    required this.onAdd,
  });

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      _relationshipController.text = widget.contact!.relationship;
    }
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
      title: Text(widget.contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              label: '',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
              label: '',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _relationshipController,
              labelText: 'Relationship',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the relationship';
                }
                return null;
              },
              label: '',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final contact = EmergencyContact(
                id: widget.contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                relationship: _relationshipController.text.trim(),
              );
              widget.onAdd(contact);
              Navigator.pop(context);
            }
          },
          child: Text(widget.contact == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

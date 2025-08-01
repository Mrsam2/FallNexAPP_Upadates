import 'package:flutter/material.dart';
import 'package:fall_detection/models/emergency_contact.dart';

class EmergencyContactsProvider with ChangeNotifier {
  List<EmergencyContact> _contacts = [];

  List<EmergencyContact> get contacts => _contacts;

  void addContact(EmergencyContact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void removeContact(String id) {
    _contacts.removeWhere((contact) => contact.id == id);
    notifyListeners();
  }

  void updateContact(EmergencyContact updatedContact) {
    final index = _contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      notifyListeners();
    }
  }
}

import '../models/user_profile.dart';
// Import EmergencyContact

class AppConstants {
  // Required fields for overall profile completeness
  static final List<String> requiredProfileFields = [
    'fullName', 'phoneNumber', 'dateOfBirth', 'gender', 'weight', 'height',
    'bloodGroup', 'mobilityLevel', 'homeAddress', 'livingAlone', 'hasCaregiver',
    'activityLevel', // From HealthInfo
    'emergencyContacts', // At least one contact
  ];
  // Gender options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  // Blood group options
  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown'
  ];

  // Mobility levels - standardized across all screens
  static const List<String> mobilityLevels = [
    'Fully mobile',
    'Walking aid (cane/walker)',
    'Wheelchair user',
    'Limited mobility',
    'Bed-bound'
  ];

  // Activity levels - standardized across all screens
  static const List<String> activityLevels = [
    'Sedentary (little to no exercise)',
    'Light (light exercise 1-3 days/week)',
    'Moderate (moderate exercise 3-5 days/week)',
    'Active (hard exercise 6-7 days/week)',
    'Very Active (very hard exercise, physical job)'
  ];

  // Alert methods - standardized across all screens
  static const List<String> alertMethods = [
    'SMS',
    'Call',
    'App Notification',
    'Email',
    'All Methods'
  ];

  // Languages
  static const List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Arabic'
  ];

  // Themes
  static const List<String> themes = [
    'Light',
    'Dark',
    'System'
  ];

  // Backup frequencies
  static const List<String> backupFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Never'
  ];

  // Data retention options
  static const List<String> dataRetentionOptions = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
    'Forever'
  ];

  // Relationship types for emergency contacts
  static const List<String> relationshipTypes = [
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Friend',
    'Neighbor',
    'Doctor',
    'Caregiver',
    'Other'
  ];

  // Sleep hours options
  static const List<String> sleepHours = [
    'Less than 4 hours',
    '4-5 hours',
    '6-7 hours',
    '8-9 hours',
    'More than 9 hours'
  ];

  // Validation helper methods

  /// Validates if a dropdown value exists in the given list
  /// Returns the value if valid, otherwise returns the default value
  static String validateDropdownValue(
      String? value,
      List<String> validOptions,
      String defaultValue,
      ) {
    if (value == null || value.isEmpty) {
      return defaultValue;
    }

    // Check for exact match first
    if (validOptions.contains(value)) {
      return value;
    }

    // Check for partial matches (case insensitive)
    final lowerValue = value.toLowerCase();
    for (String option in validOptions) {
      if (option.toLowerCase().contains(lowerValue) ||
          lowerValue.contains(option.toLowerCase())) {
        return option;
      }
    }

    // If no match found, return default
    return defaultValue;
  }

  /// Returns a safe dropdown value for DropdownButtonFormField
  /// Returns null if the value is not in the valid options list
  static String? getSafeDropdownValue(String? value, List<String> validOptions) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (validOptions.contains(value)) {
      return value;
    }

    // Check for partial matches
    final lowerValue = value.toLowerCase();
    for (String option in validOptions) {
      if (option.toLowerCase().contains(lowerValue) ||
          lowerValue.contains(option.toLowerCase())) {
        return option;
      }
    }

    return null;
  }

  /// Maps old values to new standardized values
  static String mapLegacyValue(String? oldValue, String category) {
    if (oldValue == null || oldValue.isEmpty) {
      return _getDefaultValue(category);
    }

    switch (category) {
      case 'mobility':
        return _mapMobilityLevel(oldValue);
      case 'activity':
        return _mapActivityLevel(oldValue);
      case 'alert':
        return _mapAlertMethod(oldValue);
      default:
        return oldValue;
    }
  }

  static String _mapMobilityLevel(String oldValue) {
    final lowerValue = oldValue.toLowerCase();

    if (lowerValue.contains('independent') || lowerValue.contains('fully')) {
      return mobilityLevels[0]; // 'Fully mobile'
    } else if (lowerValue.contains('walking aid') || lowerValue.contains('cane') || lowerValue.contains('walker')) {
      return mobilityLevels[1]; // 'Walking aid (cane/walker)'
    } else if (lowerValue.contains('wheelchair')) {
      return mobilityLevels[2]; // 'Wheelchair user'
    } else if (lowerValue.contains('limited')) {
      return mobilityLevels[3]; // 'Limited mobility'
    } else if (lowerValue.contains('bed') || lowerValue.contains('bound')) {
      return mobilityLevels[4]; // 'Bed-bound'
    }

    return mobilityLevels[0]; // Default to fully mobile
  }

  static String _mapActivityLevel(String oldValue) {
    final lowerValue = oldValue.toLowerCase();

    if (lowerValue.contains('sedentary') || lowerValue.contains('no exercise')) {
      return activityLevels[0];
    } else if (lowerValue.contains('light') || lowerValue.contains('1-3')) {
      return activityLevels[1];
    } else if (lowerValue.contains('moderate') || lowerValue.contains('3-5')) {
      return activityLevels[2];
    } else if (lowerValue.contains('active') || lowerValue.contains('6-7')) {
      return activityLevels[3];
    } else if (lowerValue.contains('very active') || lowerValue.contains('physical job')) {
      return activityLevels[4];
    }

    return activityLevels[1]; // Default to light
  }

  static String _mapAlertMethod(String oldValue) {
    final lowerValue = oldValue.toLowerCase();

    if (lowerValue.contains('phone call') || lowerValue == 'call') {
      return alertMethods[1]; // 'Call'
    } else if (lowerValue.contains('sms') || lowerValue.contains('text')) {
      return alertMethods[0]; // 'SMS'
    } else if (lowerValue.contains('app') || lowerValue.contains('notification')) {
      return alertMethods[2]; // 'App Notification'
    } else if (lowerValue.contains('email')) {
      return alertMethods[3]; // 'Email'
    } else if (lowerValue.contains('all')) {
      return alertMethods[4]; // 'All Methods'
    }

    return alertMethods[1]; // Default to Call
  }

  static String _getDefaultValue(String category) {
    switch (category) {
      case 'gender':
        return genderOptions[0];
      case 'bloodGroup':
        return bloodGroups[0];
      case 'mobility':
        return mobilityLevels[0];
      case 'activity':
        return activityLevels[1];
      case 'alert':
        return alertMethods[1];
      case 'language':
        return languages[0];
      case 'theme':
        return themes[2]; // System
      case 'backup':
        return backupFrequencies[0]; // Daily
      case 'retention':
        return dataRetentionOptions[3]; // 1 Year
      case 'relationship':
        return relationshipTypes[0];
      case 'sleep':
        return sleepHours[2]; // 6-7 hours
      default:
        return '';
    }
  }

  // Utility methods for common validations

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has 10-15 digits (international format)
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  static bool isValidAge(String age) {
    final ageInt = int.tryParse(age);
    return ageInt != null && ageInt > 0 && ageInt < 150;
  }

  static bool isValidWeight(String weight) {
    final weightDouble = double.tryParse(weight);
    return weightDouble != null && weightDouble > 0 && weightDouble < 1000;
  }

  static bool isValidHeight(String height) {
    final heightDouble = double.tryParse(height);
    return heightDouble != null && heightDouble > 0 && heightDouble < 300;
  }

  // Profile completeness validation
  static List<String> getIncompleteFields(UserProfile profile) {
    List<String> incompleteFields = [];

    if (profile.fullName == null || profile.fullName!.trim().isEmpty) {
      incompleteFields.add('Full Name');
    }
    if (profile.phoneNumber == null || profile.phoneNumber!.trim().isEmpty) {
      incompleteFields.add('Phone Number');
    }
    // Check if emergencyContacts list is null or empty
    if (profile.emergencyContacts == null || profile.emergencyContacts!.isEmpty) {
      incompleteFields.add('Emergency Contacts');
    } else {
      // Check if any contact in the list has empty fields
      bool hasIncompleteContact = false;
      for (var contact in profile.emergencyContacts!) {
        if (contact.name.trim().isEmpty || contact.phoneNumber.trim().isEmpty || contact.relationship.trim().isEmpty) {
          hasIncompleteContact = true;
          break;
        }
      }
      if (hasIncompleteContact) {
        incompleteFields.add('Emergency Contacts (details missing)');
      }
    }

    if (profile.dateOfBirth == null || profile.dateOfBirth!.trim().isEmpty) {
      incompleteFields.add('Date of Birth');
    }
    if (profile.gender == null || profile.gender!.trim().isEmpty) {
      incompleteFields.add('Gender');
    }
    if (profile.weight == null || profile.weight!.trim().isEmpty) {
      incompleteFields.add('Weight');
    }
    if (profile.height == null || profile.height!.trim().isEmpty) {
      incompleteFields.add('Height');
    }
    if (profile.homeAddress == null || profile.homeAddress!.trim().isEmpty) {
      incompleteFields.add('Home Address');
    }
    if (profile.activityLevel == null || profile.activityLevel!.trim().isEmpty) {
      incompleteFields.add('Activity Level');
    }

    return incompleteFields;
  }

  static bool isProfileComplete(UserProfile profile) {
    return getIncompleteFields(profile).isEmpty;
  }

  static String getProfileCompletionMessage(List<String> incompleteFields) {
    if (incompleteFields.isEmpty) {
      return 'Your profile is complete!';
    }

    if (incompleteFields.length == 1) {
      return 'Please complete your ${incompleteFields.first} to finish your profile.';
    }

    if (incompleteFields.length <= 3) {
      return 'Please complete the following fields: ${incompleteFields.join(', ')}.';
    }

    // Adjusted calculation for completion percentage based on 9 core fields
    final totalRequiredFields = 9; // Full Name, Phone, Emergency Contacts, DOB, Gender, Weight, Height, Home Address, Activity Level
    final completedFields = totalRequiredFields - incompleteFields.length;
    final completionPercentage = ((completedFields / totalRequiredFields) * 100).round();

    return 'Your profile is $completionPercentage% complete. Please fill in the remaining ${incompleteFields.length} required fields.';
  }

  // Error messages
  static const String emailErrorMessage = 'Please enter a valid email address';
  static const String phoneErrorMessage = 'Please enter a valid phone number';
  static const String requiredFieldMessage = 'This field is required';
  static const String ageErrorMessage = 'Please enter a valid age (1-149)';
  static const String weightErrorMessage = 'Please enter a valid weight in kg';
  static const String heightErrorMessage = 'Please enter a valid height in cm';

  // Re-added getProfileCompletionPercentage method
  static double getProfileCompletionPercentage(UserProfile profile) {
    final totalFields = 9; // Total number of fields considered for completion
    int completedFields = totalFields - getIncompleteFields(profile).length;
    return (completedFields / totalFields) * 100;
  }
}

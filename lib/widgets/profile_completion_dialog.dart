import 'package:flutter/material.dart';
import 'package:fall_detection/models/user_profile.dart';
import 'package:fall_detection/widgets/custom_button.dart'; // Ensure CustomButton is imported

class ModernProfileCompletionDialog extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onCompleteProfile;
  final VoidCallback onDismiss;
  final List<String> missingFields;
  final double completionPercentage;

  const ModernProfileCompletionDialog({
    super.key,
    required this.userProfile,
    required this.onCompleteProfile,
    required this.onDismiss,
    required this.missingFields,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 60),
          const SizedBox(height: 16),
          Text(
            'Complete Your Profile!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your profile is ${completionPercentage.round()}% complete.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 12),
          if (missingFields.isNotEmpty)
            Column(
              children: [
                Text(
                  'Missing information:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: missingFields.map((field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              field,
                              style: TextStyle(color: Colors.red.shade700, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Complete Profile Now',
            onPressed: onCompleteProfile,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onDismiss,
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

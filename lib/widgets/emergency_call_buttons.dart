import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallButtons extends StatelessWidget {
  const EmergencyCallButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Emergency: Fall Detected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A fall has been detected in the living room at 3:42 PM. The system has verified this through health monitoring data. Please take immediate action:',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyButton(
                    context,
                    'Call Ambulance',
                    Icons.local_hospital,
                    Colors.red,
                    () => _callEmergency('911'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEmergencyButton(
                    context,
                    'Call Doctor',
                    Icons.medical_services,
                    Colors.blue,
                    () => _callEmergency('800-123-4567'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // False alarm button
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('False Alarm'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
    }
  }
}

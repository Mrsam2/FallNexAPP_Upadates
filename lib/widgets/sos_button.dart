// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:provider/provider.dart';
// import 'package:fall_detection/providers/emergency_contacts_provider.dart';
// import 'package:fall_detection/services/notification_service.dart';
//
// class SOSButton extends StatelessWidget {
//   const SOSButton({Key? key}) : super(key: key);
//
//   Future<void> _makeEmergencyCall(BuildContext context) async {
//     final contactsProvider = Provider.of<EmergencyContactsProvider>(context, listen: false);
//     final notificationService = Provider.of<NotificationService>(context, listen: false);
//
//     if (contactsProvider.emergencyContacts.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No emergency contacts set up. Please add contacts in settings.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     // For simplicity, we'll call the first contact. In a real app, you might iterate or choose.
//     final contact = contactsProvider.emergencyContacts.first;
//     final Uri launchUri = Uri(
//       scheme: 'tel',
//       path: contact.phoneNumber,
//     );
//
//     try {
//       if (await canLaunchUrl(launchUri)) {
//         await launchUrl(launchUri);
//         notificationService.showNotification(
//           'Emergency Call Initiated',
//           'Calling ${contact.name} at ${contact.phoneNumber}',
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not launch call to ${contact.phoneNumber}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error making call: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _sendEmergencySMS(BuildContext context) async {
//     final contactsProvider = Provider.of<EmergencyContactsProvider>(context, listen: false);
//     final notificationService = Provider.of<NotificationService>(context, listen: false);
//
//     if (contactsProvider.emergencyContacts.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No emergency contacts set up. Cannot send SMS.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final List<String> recipients = contactsProvider.emergencyContacts.map((c) => c.phoneNumber).toList();
//     final String message = 'Emergency! A fall has been detected. Please check on me immediately.';
//
//     final Uri smsLaunchUri = Uri(
//       scheme: 'sms',
//       path: recipients.join(';'), // Use ';' for multiple recipients on Android, ',' for iOS
//       queryParameters: <String, String>{
//         'body': message,
//       },
//     );
//
//     try {
//       if (await canLaunchUrl(smsLaunchUri)) {
//         await launchUrl(smsLaunchUri);
//         notificationService.showNotification(
//           'Emergency SMS Sent',
//           'Message sent to emergency contacts.',
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not launch SMS application.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error sending SMS: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Emergency Alert!',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'A fall has been detected. Please confirm your status or initiate an emergency call.',
//               style: TextStyle(
//                 color: Colors.grey[700],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _makeEmergencyCall(context),
//                     icon: const Icon(Icons.call),
//                     label: const Text('Call Emergency'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _sendEmergencySMS(context),
//                     icon: const Icon(Icons.message),
//                     label: const Text('Send SMS'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:fall_detection/widgets/modern_profile_completion_dialog.dart'; // Corrected import to modern dialog
// import 'package:fall_detection/widgets/profile_completion_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fall_detection/constants/app_constants.dart';
//
// import '../profile/user_profile_provider.dart';
// import '../screens/profile/user_profile_provider.dart'; // Import AppConstants
//
// class ProfileCompletionBanner extends StatelessWidget {
//   const ProfileCompletionBanner({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProfileProvider>(
//       builder: (context, profileProvider, child) {
//         // Corrected: Add null check for userProfile and use the boolean getter for isProfileLoaded
//         if (!profileProvider.isProfileLoaded || profileProvider.userProfile == null || profileProvider.userProfile!.profileComplete != true) {
//           return const SizedBox.shrink(); // Hide banner if profile is complete or not loaded
//         }
//
//         final userProfile = profileProvider.userProfile!; // Now safe to use !
//         final missingFields = AppConstants.getIncompleteFields(userProfile); // Corrected method name
//         final completionPercentage = AppConstants.getProfileCompletionPercentage(userProfile);
//
//         if (missingFields.isEmpty) {
//           return const SizedBox.shrink(); // Hide banner if no missing fields
//         }
//
//         return Container(
//           margin: const EdgeInsets.all(16.0),
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.orange.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.orange.shade200),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Profile Incomplete',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Your profile is ${completionPercentage.toStringAsFixed(0)}% complete. Please fill in the remaining fields to enable all features.',
//                 style: TextStyle(color: Colors.orange.shade700),
//               ),
//               const SizedBox(height: 12),
//               LinearProgressIndicator(
//                 value: completionPercentage / 100,
//                 backgroundColor: Colors.orange.shade100,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
//               ),
//               const SizedBox(height: 16),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       barrierDismissible: true,
//                       barrierColor: Colors.black.withOpacity(0.7), // Dark overlay
//                       builder: (BuildContext context) {
//                         return ModernProfileCompletionDialog(
//                           userProfile: userProfile, // Pass the non-nullable userProfile
//                           missingFields: missingFields,
//                           completionPercentage: completionPercentage,
//                           onCompleteProfile: () {
//                             Navigator.of(context).pop(); // Dismiss dialog
//                             // Navigate to the first onboarding screen
//                             // This assumes you have a way to navigate to OnboardingWrapper
//                             // For example, if AuthWrapper handles it, you might just need to pop
//                             // or trigger a state change that leads to OnboardingWrapper.
//                             // For now, we'll assume the user will be redirected by AuthWrapper
//                             // if profile is still incomplete.
//                           },
//                           onDismiss: () {
//                             Navigator.of(context).pop();
//                           },
//                         );
//                       },
//                     );
//                   },
//                   child: const Text(
//                     'Complete Profile',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

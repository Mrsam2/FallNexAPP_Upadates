import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fall_detection/models/user_profile.dart';

class PDFService {
  static Future<void> generateDailyHealthReport({
    required UserProfile? userProfile,
    required Map<String, dynamic>? healthData,
    required Map<String, dynamic>? sensorData,
    required BuildContext context,
  }) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateFormatter = DateFormat('MMMM dd, yyyy');
      final timeFormatter = DateFormat('HH:mm');
      final user = FirebaseAuth.instance.currentUser;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildHeader(dateFormatter.format(now)),
          footer: (context) => _buildFooter(context),
          build: (context) => [
            // Title
            pw.Center(
              child: pw.Text(
                'Daily Health & Fall Detection Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Report Info
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Report Date: ${dateFormatter.format(now)}'),
                  pw.Text('Generated: ${timeFormatter.format(now)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Personal Information Section
            _buildSection(
              'Personal Information',
              [
                _buildInfoRow('Full Name', userProfile?.fullName ?? user?.displayName ?? 'Not provided'),
                _buildInfoRow('Email', user?.email ?? userProfile?.email ?? 'Not provided'),
                _buildInfoRow('Phone Number', userProfile?.phoneNumber ?? 'Not provided'),
                _buildInfoRow('Date of Birth', userProfile?.dateOfBirth ?? 'Not provided'),
                _buildInfoRow('Gender', userProfile?.gender ?? 'Not provided'),
                _buildInfoRow('Blood Group', userProfile?.bloodGroup ?? 'Not provided'),
                _buildInfoRow('Height', userProfile?.height ?? 'Not provided'),
                _buildInfoRow('Weight', userProfile?.weight ?? 'Not provided'),
                _buildInfoRow('Account Created', user?.metadata.creationTime != null
                    ? DateFormat('MMM dd, yyyy').format(user!.metadata.creationTime!)
                    : 'Not available'),
                _buildInfoRow('Profile Complete', userProfile?.profileComplete == true ? 'Yes' : 'No'),
              ],
            ),

            pw.SizedBox(height: 20),

            // Health Information Section
            _buildSection(
              'Health Information',
              [
                _buildInfoRow('Medical Conditions', userProfile?.medicalConditions ?? 'None reported'),
                _buildInfoRow('Current Medications', userProfile?.medications ?? 'None reported'),
                _buildInfoRow('Allergies', userProfile?.allergies ?? 'None reported'),
                _buildInfoRow('Activity Level', userProfile?.activityLevel ?? 'Not specified'),
                _buildInfoRow('Mobility Level', userProfile?.mobilityLevel ?? 'Not specified'),
                _buildInfoRow('Sleep Hours', userProfile?.sleepHours ?? 'Not specified'),
                _buildInfoRow('Previous Falls', userProfile?.hasPreviousFalls == true ? 'Yes' : 'No'),
                if (userProfile?.fallDescription?.isNotEmpty == true)
                  _buildInfoRow('Fall Description', userProfile!.fallDescription!),
                if (healthData != null) ...[
                  _buildInfoRow('Heart Rate', '${healthData['heartRate'] ?? 'N/A'} BPM'),
                  _buildInfoRow('Blood Pressure', healthData['bloodPressure'] ?? 'N/A'),
                  _buildInfoRow('Temperature', '${healthData['temperature'] ?? 'N/A'}°C'),
                  _buildInfoRow('Overall Health', healthData['overallHealth'] ?? 'N/A'),
                ],
              ],
            ),

            pw.SizedBox(height: 20),

            // Medical Contacts Section
            _buildSection(
              'Medical Contacts',
              [
                _buildInfoRow('Primary Doctor', userProfile?.doctorName ?? 'Not provided'),
                _buildInfoRow('Doctor Phone', userProfile?.doctorPhone ?? 'Not provided'),
                _buildInfoRow('Insurance Provider', userProfile?.insuranceProvider ?? 'Not provided'),
                _buildInfoRow('Insurance Number', userProfile?.insuranceNumber ?? 'Not provided'),
              ],
            ),

            pw.SizedBox(height: 20),

            // Emergency Contacts Section
            if (userProfile?.emergencyContacts?.isNotEmpty == true) ...[
              _buildSection(
                'Emergency Contacts',
                userProfile!.emergencyContacts!.map((contact) =>
                    _buildInfoRow('${contact.name} (${contact.relationship})',
                        '${contact.phoneNumber}${contact.isPrimary ? ' - Primary' : ''}')).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Fall Detection Summary
            _buildSection(
              'Fall Detection Summary (Today)',
              [
                if (sensorData != null) ...[
                  _buildInfoRow('Monitoring Status', sensorData['isMonitoring'] == true ? 'Active' : 'Inactive'),
                  _buildInfoRow('Device Connected', sensorData['isDeviceConnected'] == true ? 'Yes' : 'No'),
                  _buildInfoRow('Falls Detected Today', sensorData['fallsToday']?.toString() ?? '0'),
                  _buildInfoRow('False Alarms', sensorData['falseAlarmsToday']?.toString() ?? '0'),
                  if (sensorData['monitoringStartTime'] != null)
                    _buildInfoRow('Monitoring Since', sensorData['monitoringStartTime']),
                ] else ...[
                  _buildInfoRow('Monitoring Status', 'Data not available'),
                  _buildInfoRow('Falls Detected Today', '0'),
                  _buildInfoRow('False Alarms', '0'),
                ],
              ],
            ),

            pw.SizedBox(height: 20),

            // Sensor Status
            if (sensorData != null) ...[
              _buildSection(
                'Sensor Status',
                [
                  _buildInfoRow('Accelerometer', sensorData['accelerometerAvailable'] == true ? 'Available' : 'Not Available'),
                  _buildInfoRow('Gyroscope', sensorData['gyroscopeAvailable'] == true ? 'Available' : 'Not Available'),
                  _buildInfoRow('Location Services', sensorData['locationAvailable'] == true ? 'Available' : 'Not Available'),
                  if (sensorData['accelerometerData'] != null)
                    _buildInfoRow('Current Accelerometer', sensorData['accelerometerData']),
                  if (sensorData['gyroscopeData'] != null)
                    _buildInfoRow('Current Gyroscope', sensorData['gyroscopeData']),
                  if (sensorData['locationData'] != null)
                    _buildInfoRow('Current Location', sensorData['locationData']),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Location Information
            if (userProfile?.homeAddress?.isNotEmpty == true ||
                userProfile?.workAddress?.isNotEmpty == true) ...[
              _buildSection(
                'Location Information',
                [
                  if (userProfile?.homeAddress?.isNotEmpty == true)
                    _buildInfoRow('Home Address', userProfile!.homeAddress!),
                  if (userProfile?.workAddress?.isNotEmpty == true)
                    _buildInfoRow('Work Address', userProfile!.workAddress!),
                  if (userProfile?.emergencyAddress?.isNotEmpty == true)
                    _buildInfoRow('Emergency Address', userProfile!.emergencyAddress!),
                  _buildInfoRow('Location Sharing', userProfile?.shareLocation == true ? 'Enabled' : 'Disabled'),
                  _buildInfoRow('GPS Access', userProfile?.allowGPS == true ? 'Allowed' : 'Not Allowed'),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // App Settings & Preferences
            _buildSection(
              'App Settings & Preferences',
              [
                _buildInfoRow('Wears Smartwatch', userProfile?.wearsSmartwatch == true ? 'Yes' : 'No'),
                _buildInfoRow('Sensor Access', userProfile?.allowSensorAccess == true ? 'Allowed' : 'Not Allowed'),
                _buildInfoRow('Camera Monitoring', userProfile?.allowCameraMonitoring == true ? 'Allowed' : 'Not Allowed'),
                _buildInfoRow('Preferred Alert Method', userProfile?.preferredAlertMethod ?? 'Not specified'),
                _buildInfoRow('Language', userProfile?.language ?? 'Default'),
                _buildInfoRow('Voice Guidance', userProfile?.voiceGuidance == true ? 'Enabled' : 'Disabled'),
                _buildInfoRow('High Contrast', userProfile?.highContrast == true ? 'Enabled' : 'Disabled'),
                _buildInfoRow('Larger Fonts', userProfile?.largerFonts == true ? 'Enabled' : 'Disabled'),
                _buildInfoRow('Dark Mode', userProfile?.darkMode == true ? 'Enabled' : 'Disabled'),
                _buildInfoRow('Notifications', userProfile?.notificationsEnabled == true ? 'Enabled' : 'Disabled'),
              ],
            ),

            pw.SizedBox(height: 20),

            // Important Notes
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                border: pw.Border.all(color: PdfColors.red200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Important Notes',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '• This report contains sensitive health information',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                  pw.Text(
                    '• Share only with authorized healthcare providers',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                  pw.Text(
                    '• In case of emergency, contact emergency services immediately',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                  pw.Text(
                    '• This data is automatically generated and should be verified',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                  pw.Text(
                    '• Keep this document secure and dispose of it properly',
                    style: const pw.TextStyle(color: PdfColors.red700),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'This report is generated by the Fall Detection App and is intended for informational purposes only. '
                    'It should not replace professional medical advice, diagnosis, or treatment. '
                    'Always consult with qualified healthcare providers regarding your health.',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      );

      // Save and share the PDF
      final output = await getTemporaryDirectory();
      final fileName = 'Fall_Detection_Report_${DateFormat('yyyy_MM_dd').format(now)}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Daily Fall Detection & Health Report - ${dateFormatter.format(now)}',
        subject: 'Health Report',
      );

    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }

  static pw.Widget _buildHeader(String date) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Text(
        'Fall Detection App - $date',
        style: pw.TextStyle(
          fontSize: 12,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 12,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';

class EmailService {
  static const String _organizationEmail = 'fallnex2025@gmail.com';
  static const String _organizationName = 'FallNex Fall Detection';

  // You'll need to set up an app password for Gmail
  // Go to Google Account Settings > Security > 2-Step Verification > App passwords
  static const String _appPassword = 'your_app_password_here'; // Replace with actual app password

  static Future<void> sendHealthReportEmail({
    required Uint8List pdfBytes,
    required String fileName,
    required String recipientEmail,
    required String recipientName,
    required BuildContext context,
  }) async {
    try {
      // Configure Gmail SMTP with timeout and connection settings
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: _organizationEmail,
        password: _appPassword,
        allowInsecure: false,
        ssl: false,
      );

      // Create the email message
      final message = Message()
        ..from = Address(_organizationEmail, _organizationName)
        ..recipients.add(recipientEmail)
        ..subject = 'Your Daily Health & Fall Detection Report - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'
        ..html = _buildEmailHtml(recipientName)
        ..attachments = [
          FileAttachment(
            pdfBytes as File,
            fileName: fileName,
            contentType: 'application/pdf',
          )
        ];

      // Send the email with timeout
      await send(message, smtpServer).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Email sending timed out. Please check your internet connection.');
        },
      );

      // Check if email was sent successfully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health report sent successfully to $recipientEmail'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to send email: ${e.toString()}';

      // Provide more specific error messages
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Network error: Please check your internet connection and try again.';
      } else if (e.toString().contains('Authentication failed')) {
        errorMessage = 'Email authentication failed. Please check email configuration.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Email sending timed out. Please check your internet connection.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry functionality can be added here
              },
            ),
          ),
        );
      }
      throw Exception(errorMessage);
    }
  }

  static String _buildEmailHtml(String recipientName) {
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Health Report</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f4f4f4;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
            }
            .header {
                text-align: center;
                border-bottom: 3px solid #2196F3;
                padding-bottom: 20px;
                margin-bottom: 30px;
            }
            .logo {
                font-size: 28px;
                font-weight: bold;
                color: #2196F3;
                margin-bottom: 10px;
            }
            .subtitle {
                color: #666;
                font-size: 16px;
            }
            .content {
                margin-bottom: 30px;
            }
            .greeting {
                font-size: 18px;
                margin-bottom: 20px;
                color: #333;
            }
            .info-box {
                background-color: #e3f2fd;
                border-left: 4px solid #2196F3;
                padding: 15px;
                margin: 20px 0;
                border-radius: 5px;
            }
            .warning-box {
                background-color: #fff3e0;
                border-left: 4px solid #ff9800;
                padding: 15px;
                margin: 20px 0;
                border-radius: 5px;
            }
            .footer {
                border-top: 1px solid #ddd;
                padding-top: 20px;
                text-align: center;
                color: #666;
                font-size: 14px;
            }
            .contact-info {
                margin-top: 15px;
                padding: 15px;
                background-color: #f8f9fa;
                border-radius: 5px;
            }
            ul {
                padding-left: 20px;
            }
            li {
                margin-bottom: 8px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="logo">🛡️ $_organizationName</div>
                <div class="subtitle">Your Health & Safety Partner</div>
            </div>
            
            <div class="content">
                <div class="greeting">
                    Dear ${recipientName.isNotEmpty ? recipientName : 'Valued User'},
                </div>
                
                <p>We hope this message finds you in good health and safety.</p>
                
                <p>Please find attached your comprehensive Daily Health & Fall Detection Report for <strong>$currentDate</strong>. This report contains important information about your health status, fall detection monitoring, and safety settings.</p>
                
                <div class="info-box">
                    <strong>📋 Report Contents:</strong>
                    <ul>
                        <li>Personal and contact information</li>
                        <li>Current health status and medical conditions</li>
                        <li>Emergency contacts and medical contacts</li>
                        <li>Fall detection monitoring summary</li>
                        <li>Sensor status and device connectivity</li>
                        <li>Location and safety preferences</li>
                        <li>App settings and accessibility options</li>
                    </ul>
                </div>
                
                <div class="warning-box">
                    <strong>🔒 Important Privacy Notice:</strong>
                    <ul>
                        <li>This report contains sensitive personal health information</li>
                        <li>Please store this document securely</li>
                        <li>Only share with authorized healthcare providers</li>
                        <li>Delete this email and attachment when no longer needed</li>
                    </ul>
                </div>
                
                <p>If you have any questions about your report or need assistance with your fall detection system, please don't hesitate to contact our support team.</p>
                
                <p><strong>In case of emergency, always contact emergency services immediately (911 or your local emergency number).</strong></p>
                
                <div class="contact-info">
                    <strong>📞 Support Information:</strong><br>
                    Email: $_organizationEmail<br>
                    Available: 24/7 for emergency support<br>
                    Response Time: Within 24 hours for non-emergency inquiries
                </div>
            </div>
            
            <div class="footer">
                <p>This is an automated message from $_organizationName Fall Detection System.</p>
                <p>Generated on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(DateTime.now())}</p>
                <p style="margin-top: 15px; font-size: 12px; color: #999;">
                    This email and any attachments are confidential and intended solely for the addressee. 
                    If you have received this email in error, please notify the sender and delete it immediately.
                </p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  static Future<void> sendTestEmail({
    required String recipientEmail,
    required BuildContext context,
  }) async {
    try {
      // Configure Gmail SMTP with timeout
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: _organizationEmail,
        password: _appPassword,
        allowInsecure: false,
        ssl: false,
      );

      final message = Message()
        ..from = Address(_organizationEmail, _organizationName)
        ..recipients.add(recipientEmail)
        ..subject = 'Test Email from $_organizationName'
        ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #2196F3;">🛡️ Test Email from $_organizationName</h2>
          <p>This is a test email to verify the email configuration.</p>
          <p>If you receive this email, the email service is working correctly!</p>
          <div style="background-color: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <strong>✅ Email Service Status: Working</strong>
          </div>
          <p>Best regards,<br>$_organizationName Team</p>
          <hr style="margin-top: 30px;">
          <p style="font-size: 12px; color: #666;">
            This is an automated test message from $_organizationName Fall Detection System.
          </p>
        </div>
        ''';

      await send(message, smtpServer).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Test email timed out. Please check your internet connection.');
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test email sent successfully! Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to send test email: ${e.toString()}';

      // Provide more specific error messages
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Network error: Cannot connect to email server. Please check your internet connection.';
      } else if (e.toString().contains('Authentication failed')) {
        errorMessage = 'Email authentication failed. Please check the app password configuration.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Test email timed out. Please check your internet connection.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
      throw Exception(errorMessage);
    }
  }
}

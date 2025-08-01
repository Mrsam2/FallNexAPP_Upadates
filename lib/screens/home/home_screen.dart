import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/fall_detection_provider.dart';
import 'package:fall_detection/providers/bluetooth_provider.dart';
import 'package:fall_detection/providers/firebase_system_provider.dart';
import 'package:fall_detection/screens/camera_setup/camera_setup_screen.dart';
import 'package:fall_detection/screens/health_monitor/health_monitor_screen.dart';
import 'package:fall_detection/screens/ai_guidance/ai_guidance_screen.dart';
import 'package:fall_detection/screens/emergency/emergency_contacts_screen.dart';
import 'package:fall_detection/screens/profile/user_profile_screen.dart';
import 'package:fall_detection/screens/bluetooth/bluetooth_screen.dart';
import 'package:fall_detection/widgets/modern_status_row.dart';
import 'package:fall_detection/widgets/tiered_fall_detection_card.dart';
import 'package:fall_detection/widgets/realtime_sensor_data_card.dart';
import 'package:fall_detection/widgets/camera_feed_card.dart';
import 'package:fall_detection/widgets/health_status_card.dart';
import 'package:fall_detection/widgets/ai_suggestion_card.dart';
import 'package:fall_detection/widgets/emergency_call_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CameraSetupScreen(),
    const HealthMonitorScreen(),
    const AIGuidanceScreen(),
    const EmergencyContactsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothStatus();
    });
  }

  void _checkBluetoothStatus() {
    final bluetoothProvider = context.read<BluetoothProvider>();
    if (!bluetoothProvider.isBluetoothOn) {
      _showBluetoothOffDialog();
    }
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bluetooth_disabled,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bluetooth Required',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please turn on Bluetooth to connect with your ESP fall detection device.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bluetooth is required for real-time fall detection monitoring.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final bluetoothProvider = context.read<BluetoothProvider>();
                await bluetoothProvider.turnOnBluetooth();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Turn On Bluetooth'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        // Remove back button completely
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // App Logo with fallback
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF2196F3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildAppLogo(),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'FallNex AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        actions: [
          // Fall Detection Status Icon
          Consumer<FallDetectionProvider>(
            builder: (context, fallProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: IconButton(
                  onPressed: () {
                    _showFallDetectionStatus(context, fallProvider);
                  },
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: fallProvider.fallCount > 0
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: fallProvider.fallCount > 0
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            fallProvider.fallCount > 0 ? Icons.warning : Icons.shield,
                            color: fallProvider.fallCount > 0 ? Colors.red : Colors.green,
                            size: 18,
                          ),
                        ),
                        if (fallProvider.fallCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '${fallProvider.fallCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Firebase System Status Icon
          Consumer<FirebaseSystemProvider>(
            builder: (context, firebaseProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: IconButton(
                  onPressed: () {
                    _showFirebaseStatusDialog(context, firebaseProvider);
                  },
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: firebaseProvider.isSystemActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: firebaseProvider.isSystemActive
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      firebaseProvider.isSystemActive
                          ? Icons.cloud_sync
                          : Icons.cloud_off,
                      color: firebaseProvider.isSystemActive
                          ? Colors.green
                          : Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              );
            },
          ),
          // Bluetooth Status Icon
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BluetoothScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bluetoothProvider.isConnected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: bluetoothProvider.isConnected
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      bluetoothProvider.isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: bluetoothProvider.isConnected
                          ? Colors.blue
                          : Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              );
            },
          ),
          // Profile Icon Button
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_selectedTabIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam_rounded),
              label: 'Cameras',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_rounded),
              label: 'AI Guide',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_rounded),
              label: 'Emergency',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    try {
      return Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackLogo();
        },
      );
    } catch (e) {
      return _buildFallbackLogo();
    }
  }

  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF2196F3),
          ],
        ),
      ),
      child: const Icon(
        Icons.security,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _showFallDetectionStatus(BuildContext context, FallDetectionProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF2196F3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Fall Detection Status',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: provider.fallCount > 0
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Falls Detected: ${provider.fallCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: provider.fallCount > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Model: ${provider.isMLModelLoaded ? "AI Model Active" : "Rule-based Active"}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tiered System: 75% Minor | 80% Basic | 90% High',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (provider.recentFalls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Falls:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: provider.recentFalls.length,
                      itemBuilder: (context, index) {
                        final fall = provider.recentFalls[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            fall.isFalseAlarm ? Icons.info : Icons.warning,
                            color: fall.isFalseAlarm ? Colors.orange : Colors.red,
                            size: 20,
                          ),
                          title: Text(
                            '${fall.timestamp.hour.toString().padLeft(2, '0')}:${fall.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '${(fall.probability * 100).toStringAsFixed(0)}% confidence',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (provider.fallCount > 0)
              TextButton(
                onPressed: () {
                  provider.resetFallCount();
                  Navigator.of(context).pop();
                },
                child: const Text('Reset Count'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFirebaseStatusDialog(BuildContext context, FirebaseSystemProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF2196F3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.cloud_sync,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Firebase Status',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: provider.isSystemActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'System Status: ${provider.isSystemActive ? "ACTIVE" : "OFFLINE"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: provider.isSystemActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(provider.getSystemStatusMessage()),
                const SizedBox(height: 16),
                const Text(
                  'Latest Data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    provider.getLatestDataInfo(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fallDetectionProvider = Provider.of<FallDetectionProvider>(context);
    final isFallDetected = fallDetectionProvider.isFallDetected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50),
                        const Color(0xFF2196F3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to FallNex AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Advanced fall detection with tiered alerts',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Modern Horizontal Status Cards
          const ModernStatusRow(),

          const SizedBox(height: 20),

          // Real-time Sensor Data Card
          const RealtimeSensorDataCard(),

          const SizedBox(height: 20),

          // Tiered Fall Detection Card (Updated)
          const TieredFallDetectionCard(),

          const SizedBox(height: 20),

          // Latest Camera Feed
          const CameraFeedCard(),

          const SizedBox(height: 20),

          // Health Status Summary
          const HealthStatusCard(),

          const SizedBox(height: 20),

          // AI Suggestions
          const AISuggestionCard(),

          const SizedBox(height: 20),

          // Emergency Call Buttons (only shown if fall is detected)
          if (isFallDetected)
            const EmergencyCallButtons(),

          // Recent Events List
          if (!isFallDetected) ...[
            const SizedBox(height: 20),
            Text(
              'Recent Events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentEventsList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentEventsList(BuildContext context) {
    final fallDetectionProvider = Provider.of<FallDetectionProvider>(context);
    final events = fallDetectionProvider.recentEvents;

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No incidents detected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The AI system is monitoring sensor data in real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: event.isFalseAlarm
                      ? [Colors.orange, Colors.orange.shade400]
                      : [Colors.red, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                event.isFalseAlarm ? Icons.info_outline : Icons.warning_amber,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Fall Detected by AI',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}'),
                const SizedBox(height: 4),
                Text(
                  'AI Confidence: ${(event.probability * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
            onTap: () {
              // Navigate to event details
            },
          ),
        );
      },
    );
  }
}

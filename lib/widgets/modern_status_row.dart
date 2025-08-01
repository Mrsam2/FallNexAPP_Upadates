import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/firebase_system_provider.dart';
import '../screens/bluetooth/bluetooth_screen.dart';

class ModernStatusRow extends StatelessWidget {
  const ModernStatusRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<BluetoothProvider, FirebaseSystemProvider>(
      builder: (context, bluetoothProvider, firebaseProvider, child) {
        return Container(
          height: 140,
          child: Row(
            children: [
              // ESP Device Status Card (Left)
              Expanded(
                flex: 1,
                child: _buildESPStatusCard(context, bluetoothProvider),
              ),
              const SizedBox(width: 12),
              // System Status Card (Right)
              Expanded(
                flex: 1,
                child: _buildSystemStatusCard(context, firebaseProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildESPStatusCard(BuildContext context, BluetoothProvider bluetoothProvider) {
    final bool isConnected = bluetoothProvider.isConnected;
    final bool isScanning = bluetoothProvider.isScanning;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isConnected
              ? [
            const Color(0xFF4CAF50),
            const Color(0xFF45A049),
          ]
              : [
            const Color(0xFFFFB74D),
            const Color(0xFFFF9800),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BluetoothScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon - reduced spacing
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isConnected ? Icons.memory : Icons.search,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    if (isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'CONNECTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title - reduced font size
                Text(
                  'ESP Device',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                // Status text - flexible and constrained
                Flexible(
                  child: Text(
                    isConnected
                        ? bluetoothProvider.connectedDeviceName ?? 'Connected'
                        : bluetoothProvider.isBluetoothOn
                        ? 'No ESP devices found'
                        : 'Bluetooth is off',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Action button - only if not connected and space available
                if (!isConnected) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: isScanning ? null : () async {
                        if (!bluetoothProvider.isBluetoothOn) {
                          await bluetoothProvider.turnOnBluetooth();
                        } else {
                          await bluetoothProvider.scanForESPDevices();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isConnected ? Colors.green : Colors.orange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: isScanning
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Scanning...',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            bluetoothProvider.isBluetoothOn
                                ? Icons.search
                                : Icons.bluetooth,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bluetoothProvider.isBluetoothOn
                                ? 'Find Device'
                                : 'Turn On BT',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(BuildContext context, FirebaseSystemProvider firebaseProvider) {
    final bool isActive = firebaseProvider.isSystemActive;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
            const Color(0xFF4CAF50),
            const Color(0xFF45A049),
          ]
              : [
            const Color(0xFFE57373),
            const Color(0xFFEF5350),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            firebaseProvider.forceStatusCheck();
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and status indicator - reduced spacing
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    // Animated status dot - smaller
                    _buildAnimatedStatusDot(isActive),
                  ],
                ),

                const SizedBox(height: 8),

                // Title - reduced font size
                const Text(
                  'System Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                // Status text - flexible and constrained
                Flexible(
                  child: Text(
                    isActive
                        ? 'Fall detection system is active'
                        : firebaseProvider.lastFirebaseDataReceived == null
                        ? 'Waiting for sensor data...'
                        : 'System offline',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Status badge - smaller and at bottom
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_sync,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isActive ? 'ACTIVE' : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatusDot(bool isActive) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.white.withOpacity(value * 0.5),
                blurRadius: 3 * value,
                spreadRadius: 0.5 * value,
              ),
            ] : null,
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../screens/bluetooth/bluetooth_screen.dart';

class BluetoothStatusCard extends StatelessWidget {
  const BluetoothStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: bluetoothProvider.isConnected
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.red.shade50, Colors.red.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bluetoothProvider.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.memory, // ESP chip icon
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESP Fall Detection Device',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getESPStatusText(bluetoothProvider),
                                style: TextStyle(
                                  color: bluetoothProvider.isConnected
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BluetoothScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ESP Connection Details
                  if (bluetoothProvider.isConnected) ...[
                    _buildESPConnectionDetails(context, bluetoothProvider),
                  ] else ...[
                    _buildESPDisconnectedActions(context, bluetoothProvider),
                  ],

                  // Latest ESP Data Indicator
                  if (bluetoothProvider.latestData != null) ...[
                    const SizedBox(height: 12),
                    _buildLatestESPDataIndicator(context, bluetoothProvider),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getESPStatusText(BluetoothProvider provider) {
    if (!provider.isBluetoothOn) {
      return 'Bluetooth Off';
    } else if (provider.isConnected) {
      return 'ESP Connected & Monitoring';
    } else if (provider.isScanning) {
      return 'Scanning for ESP devices...';
    } else {
      return 'ESP Device Not Connected';
    }
  }

  Widget _buildESPConnectionDetails(BuildContext context, BluetoothProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory,
                size: 16,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'ESP Device: ${provider.connectedDeviceName ?? 'Unknown'}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Address: ${provider.connectedDeviceId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildESPDisconnectedActions(BuildContext context, BluetoothProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.connectionStatus,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!provider.isBluetoothOn) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await provider.turnOnBluetooth();
                    },
                    icon: const Icon(Icons.bluetooth, size: 16),
                    label: const Text('Turn On Bluetooth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isScanning
                        ? null
                        : () async {
                      await provider.scanForESPDevices();
                    },
                    icon: provider.isScanning
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.memory, size: 16),
                    label: Text(provider.isScanning ? 'Scanning...' : 'Find ESP Device'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestESPDataIndicator(BuildContext context, BluetoothProvider provider) {
    final data = provider.latestData!;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0);
    final timeAgo = DateTime.now().difference(timestamp);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sensors,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ESP data: ${timeAgo.inSeconds < 60 ? "${timeAgo.inSeconds}s ago" : "${timeAgo.inMinutes}m ago"}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

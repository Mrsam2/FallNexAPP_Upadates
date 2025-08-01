import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fall_detection_provider.dart';
import '../services/fall_detection_ml_service.dart';

class RealtimeSensorDataCard extends StatelessWidget {
  const RealtimeSensorDataCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FallDetectionMLService().sensorDataStream,
      initialData: null, // Explicitly set initial data as null
      builder: (context, snapshot) {
        // Handle different connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        final sensorData = snapshot.data;
        final hasData = sensorData != null && sensorData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hasData
                  ? [
                const Color(0xFF4CAF50),
                const Color(0xFF81C784),
              ]
                  : [
                const Color(0xFF9E9E9E),
                const Color(0xFFBDBDBD),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (hasData ? Colors.green : Colors.grey).withOpacity(0.3),
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
                if (hasData) {
                  _showDetailedSensorData(context, sensorData);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            hasData ? Icons.sensors : Icons.sensors_off,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Real-time Sensor Data',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                hasData ? 'Live Data Stream' : 'Waiting for data...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: hasData ? Colors.white : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            boxShadow: hasData ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ] : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (hasData) ...[
                      // Device info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.device_hub,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Device: ${sensorData['device_id']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTimestamp(sensorData['timestamp']),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sensor readings summary
                      Row(
                        children: [
                          Expanded(
                            child: _buildSensorGroup(
                              'Set 1',
                              'AX1: ${(sensorData?['AX1'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'AY1: ${(sensorData?['AY1'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'AZ1: ${(sensorData?['AZ1'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'Mag: ${(sensorData?['magnitude1'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSensorGroup(
                              'Set 2',
                              'AX2: ${(sensorData?['AX2'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'AY2: ${(sensorData?['AY2'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'AZ2: ${(sensorData?['AZ2'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              'Mag: ${(sensorData?['magnitude2'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // View details button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDetailedSensorData(context, sensorData);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View All Parameters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // No data state
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Waiting for sensor data...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Make sure your ESP device is connected and sending data',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9E9E9E),
            const Color(0xFFBDBDBD),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Real-time Sensor Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Initializing...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Setting up enhanced fall detection system...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGroup(String title, String line1, String line2, String line3, String line4) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            line1,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
          Text(
            line2,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
          Text(
            line3,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            line4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime dateTime;
      if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else {
        dateTime = DateTime.now();
      }

      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid';
    }
  }

  void _showDetailedSensorData(BuildContext context, Map<String, dynamic> sensorData) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sensors,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Detailed Sensor Data'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device info
                  _buildInfoCard('Device Information', [
                    'Device ID: ${sensorData['device_id']}',
                    'Timestamp: ${sensorData['timestamp']}',
                    'Time: ${_formatTimestamp(sensorData['timestamp'])}',
                  ]),

                  const SizedBox(height: 16),

                  // First sensor set
                  _buildInfoCard('Sensor Set 1 (Accelerometer)', [
                    'AX1: ${sensorData['AX1']?.toStringAsFixed(4) ?? '0.0000'}',
                    'AY1: ${sensorData['AY1']?.toStringAsFixed(4) ?? '0.0000'}',
                    'AZ1: ${sensorData['AZ1']?.toStringAsFixed(4) ?? '0.0000'}',
                    'Magnitude: ${sensorData['magnitude1']?.toStringAsFixed(4) ?? '0.0000'}',
                  ]),

                  const SizedBox(height: 16),

                  // First gyroscope set
                  _buildInfoCard('Sensor Set 1 (Gyroscope)', [
                    'RX1: ${sensorData['RX1']?.toStringAsFixed(4) ?? '0.0000'}',
                    'RY1: ${sensorData['RY1']?.toStringAsFixed(4) ?? '0.0000'}',
                    'RZ1: ${sensorData['RZ1']?.toStringAsFixed(4) ?? '0.0000'}',
                  ]),

                  const SizedBox(height: 16),

                  // Second sensor set
                  _buildInfoCard('Sensor Set 2 (Accelerometer)', [
                    'AX2: ${sensorData['AX2']?.toStringAsFixed(4) ?? '0.0000'}',
                    'AY2: ${sensorData['AY2']?.toStringAsFixed(4) ?? '0.0000'}',
                    'AZ2: ${sensorData['AZ2']?.toStringAsFixed(4) ?? '0.0000'}',
                    'Magnitude: ${sensorData['magnitude2']?.toStringAsFixed(4) ?? '0.0000'}',
                  ]),

                  const SizedBox(height: 16),

                  // Second gyroscope set
                  _buildInfoCard('Sensor Set 2 (Gyroscope)', [
                    'RX2: ${sensorData['RX2']?.toStringAsFixed(4) ?? '0.0000'}',
                    'RY2: ${sensorData['RY2']?.toStringAsFixed(4) ?? '0.0000'}',
                    'RZ2: ${sensorData['RZ2']?.toStringAsFixed(4) ?? '0.0000'}',
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

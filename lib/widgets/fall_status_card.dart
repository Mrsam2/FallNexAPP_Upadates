import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/sensor_data_provider.dart';

class FallStatusCard extends StatelessWidget {
  const FallStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    final bool isFallDetected = sensorProvider.isFallDetected;
    final bool isMonitoring = sensorProvider.isMonitoring;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isFallDetected
                ? [Colors.red.shade400, Colors.red.shade700]
                : isMonitoring
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.grey.shade400, Colors.grey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFallDetected
                      ? Icons.warning_amber_rounded
                      : isMonitoring
                          ? Icons.check_circle
                          : Icons.error,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isFallDetected
                        ? 'Fall Detected!'
                        : isMonitoring
                            ? 'Monitoring Active'
                            : 'Monitoring Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isFallDetected
                  ? 'A fall has been detected. Emergency contacts are being notified.'
                  : isMonitoring
                      ? 'The system is actively monitoring for falls.'
                      : 'Please connect your wearable device to start monitoring.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (isFallDetected)
              ElevatedButton(
                onPressed: () {
                  sensorProvider.resetFallDetection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                child: const Text('I\'m OK - False Alarm'),
              )
            else if (!isMonitoring)
              ElevatedButton(
                onPressed: () {
                  sensorProvider.startMonitoring();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
                child: const Text('Start Monitoring'),
              )
            else
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Monitoring since ${sensorProvider.monitoringStartTime}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

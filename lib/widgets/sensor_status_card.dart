import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/sensor_data_provider.dart';

class SensorStatusCard extends StatelessWidget {
  const SensorStatusCard({Key? key, required bool isMonitoring, required SensorDataProvider sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSensorStatusRow(
              context,
              'Accelerometer',
              sensorProvider.isAccelerometerAvailable,
              sensorProvider.accelerometerData,
            ),
            const Divider(),
            _buildSensorStatusRow(
              context,
              'Gyroscope',
              sensorProvider.isGyroscopeAvailable,
              sensorProvider.gyroscopeData,
            ),
            const Divider(),
            _buildSensorStatusRow(
              context,
              'GPS',
              sensorProvider.isLocationAvailable,
              sensorProvider.locationData,
            ),
            const SizedBox(height: 16),
            if (!sensorProvider.isDeviceConnected)
              OutlinedButton.icon(
                onPressed: () {
                  sensorProvider.connectDevice();
                },
                icon: const Icon(Icons.bluetooth),
                label: const Text('Connect Wearable Device'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatusRow(
    BuildContext context,
    String sensorName,
    bool isAvailable,
    String data,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.error,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sensorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable ? data : 'Not available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

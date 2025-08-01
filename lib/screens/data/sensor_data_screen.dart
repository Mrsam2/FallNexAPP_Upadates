import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/firebase_service.dart';

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({Key? key}) : super(key: key);

  @override
  State<SensorDataScreen> createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _sensorData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await _firebaseService.initialize();
    _listenToSensorData();
  }

  void _listenToSensorData() {
    _firebaseService.getSensorDataStream().listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> dataList = [];
        
        data.forEach((key, value) {
          Map<String, dynamic> item = Map<String, dynamic>.from(value);
          item['id'] = key;
          dataList.add(item);
        });
        
        // Sort by timestamp (newest first)
        dataList.sort((a, b) {
          int timestampA = a['timestamp'] ?? 0;
          int timestampB = b['timestamp'] ?? 0;
          return timestampB.compareTo(timestampA);
        });

        setState(() {
          _sensorData = dataList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _sensorData = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sensorData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No sensor data available'),
                      Text('Connect your ESP device to start receiving data'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sensorData.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = _sensorData[index];
                    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                      data['timestamp'] ?? 0,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sensor Reading',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (data['deviceAddress'] != null)
                              Text(
                                'Device: ${data['deviceAddress']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...data.entries
                                      .where((entry) => !['id', 'timestamp', 'deviceAddress', 'uploadedAt'].contains(entry.key))
                                      .map((entry) => Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${entry.key}: ',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(entry.value.toString()),
                                                ),
                                              ],
                                            ),
                                          )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

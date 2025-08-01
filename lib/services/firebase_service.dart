import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late DatabaseReference _database;
  bool _initialized = false;
  StreamController<Map<String, dynamic>>? _realtimeDataController;
  StreamSubscription<DatabaseEvent>? _realtimeDataSubscription;

  Stream<Map<String, dynamic>> get realtimeDataStream => _realtimeDataController!.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Database with your specific URL
      _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://fall-detection-1851d-default-rtdb.firebaseio.com/'
      ).ref();

      _realtimeDataController = StreamController<Map<String, dynamic>>.broadcast();
      _initialized = true;
      print('Firebase service initialized successfully');

      // Start listening to real-time data
      _startRealtimeDataListener();
    } catch (e) {
      print('Error initializing Firebase service: $e');
      throw e;
    }
  }

  void _startRealtimeDataListener() {
    // Listen to the latest_data path for real-time updates with immediate response
    _realtimeDataSubscription = _database
        .child('devices/001/latest_data')
        .onValue
        .listen(
          (DatabaseEvent event) {
        if (event.snapshot.value != null) {
          try {
            Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);

            // Add reception timestamp
            data['receivedAt'] = DateTime.now().millisecondsSinceEpoch;
            data['source'] = 'firebase_realtime';

            print('Firebase real-time data received: $data');
            _realtimeDataController?.add(data);
          } catch (e) {
            print('Error processing Firebase real-time data: $e');
          }
        }
      },
      onError: (error) {
        print('Firebase listener error: $error');
      },
      cancelOnError: false,
    );
  }

  Future<bool> sendSensorData(Map<String, dynamic> data) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Create a unique key for this data entry
      String key = DateTime.now().millisecondsSinceEpoch.toString();

      // Send data to Firebase Realtime Database
      await _database.child('sensor_data').child(key).set({
        ...data,
        'uploadedAt': ServerValue.timestamp,
      });

      print('Data sent to Firebase successfully: $data');
      return true;
    } catch (e) {
      print('Error sending data to Firebase: $e');
      return false;
    }
  }

  Future<bool> sendFallAlert(Map<String, dynamic> alertData) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      String alertKey = DateTime.now().millisecondsSinceEpoch.toString();

      await _database.child('fall_alerts').child(alertKey).set({
        ...alertData,
        'alertTime': ServerValue.timestamp,
        'status': 'active',
      });

      print('Fall alert sent to Firebase: $alertData');
      return true;
    } catch (e) {
      print('Error sending fall alert to Firebase: $e');
      return false;
    }
  }

  Stream<DatabaseEvent> getSensorDataStream() {
    if (!_initialized) {
      throw Exception('Firebase service not initialized');
    }
    return _database.child('sensor_data').limitToLast(50).onValue;
  }

  Stream<DatabaseEvent> getFallAlertsStream() {
    if (!_initialized) {
      throw Exception('Firebase service not initialized');
    }
    return _database.child('fall_alerts').onValue;
  }

  Future<void> updateAlertStatus(String alertId, String status) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      await _database.child('fall_alerts').child(alertId).update({
        'status': status,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error updating alert status: $e');
    }
  }

  void dispose() {
    _realtimeDataSubscription?.cancel();
    _realtimeDataController?.close();
  }

// Add this method to check for immediate disconnection
  void checkConnectionStatus() {
    _database.child('devices/001/latest_data/timestamp').get().then((snapshot) {
      if (snapshot.exists) {
        int lastTimestamp = snapshot.value as int? ?? 0;
        int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // If timestamp is older than 15 seconds, system might be offline
        if (currentTime - lastTimestamp > 15) {
          print('System appears offline - last timestamp: $lastTimestamp, current: $currentTime');
        }
      }
    }).catchError((error) {
      print('Error checking connection status: $error');
    });
  }
}

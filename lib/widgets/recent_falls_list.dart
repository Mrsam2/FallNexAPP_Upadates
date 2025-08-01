import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/sensor_data_provider.dart';
import 'package:fall_detection/models/fall_event.dart';
import 'package:intl/intl.dart';

class RecentFallsList extends StatelessWidget {
  const RecentFallsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    final fallEvents = sensorProvider.recentFallEvents;

    if (fallEvents.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'No falls detected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Great! No fall events have been detected recently.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fallEvents.length,
      itemBuilder: (context, index) {
        final fallEvent = fallEvents[index];
        return _buildFallEventCard(context, fallEvent);
      },
    );
  }

  Widget _buildFallEventCard(BuildContext context, FallEvent fallEvent) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    final formattedDate = dateFormat.format(fallEvent.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: fallEvent.isFalseAlarm ? Colors.orange : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            fallEvent.isFalseAlarm
                ? Icons.info_outline
                : Icons.warning_amber_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          fallEvent.isFalseAlarm ? 'False Alarm' : 'Fall Detected',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formattedDate),
            const SizedBox(height: 4),
            Text(
              'Location: ${fallEvent.location}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Navigate to fall event details
          },
        ),
      ),
    );
  }
}

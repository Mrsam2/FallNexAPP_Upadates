import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fall_detection_provider.dart';
import '../services/enhanced_fall_detection_service.dart';
import '../models/fall_event.dart';

class TieredFallDetectionCard extends StatelessWidget {
  const TieredFallDetectionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: EnhancedFallDetectionService().alertLevelStream,
      initialData: 'NONE',
      builder: (context, alertSnapshot) {
        final alertLevel = alertSnapshot.data ?? 'NONE';

        return Consumer<FallDetectionProvider>(
          builder: (context, provider, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(alertLevel),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getAlertColor(alertLevel).withOpacity(0.3),
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
                    _showTieredDetailsDialog(context, provider, alertLevel);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with alert level indicator - Fixed overflow
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getAlertIcon(alertLevel),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tiered Fall Detection',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    provider.isMLModelLoaded ? 'AI Model Active' : 'Rule-based Active',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Current alert level badge - Fixed size
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                alertLevel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Alert level status
                        Text(
                          _getAlertMessage(alertLevel, provider.fallCount),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tiered counters - Fixed layout
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildCounterRow('Total Events', provider.fallCount, Colors.white),
                              const SizedBox(height: 6),
                              _buildCounterRow('Minor (75%+)', EnhancedFallDetectionService().minorAlertCount, Colors.blue[200]!),
                              const SizedBox(height: 6),
                              _buildCounterRow('Basic (80%+)', EnhancedFallDetectionService().basicAlertCount, Colors.orange[200]!),
                              const SizedBox(height: 6),
                              _buildCounterRow('High (90%+)', EnhancedFallDetectionService().highAlertCount, Colors.red[200]!),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Recent event info
                        if (provider.recentFalls.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Last: ${_formatTime(provider.recentFalls.first.timestamp)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${(provider.recentFalls.first.probability * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Action buttons - Fixed layout
                        if (provider.fallCount > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    provider.resetFallCount();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _getAlertColor(alertLevel),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text(
                                    'Reset All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showTieredDetailsDialog(context, provider, alertLevel);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  List<Color> _getGradientColors(String alertLevel) {
    switch (alertLevel) {
      case 'HIGH':
        return [const Color(0xFFE53E3E), const Color(0xFFFC8181)];
      case 'BASIC':
        return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
      case 'MINOR':
        return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      default:
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
    }
  }

  Color _getAlertColor(String alertLevel) {
    switch (alertLevel) {
      case 'HIGH':
        return Colors.red;
      case 'BASIC':
        return Colors.orange;
      case 'MINOR':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _getAlertIcon(String alertLevel) {
    switch (alertLevel) {
      case 'HIGH':
        return Icons.warning;
      case 'BASIC':
        return Icons.info;
      case 'MINOR':
        return Icons.notifications;
      default:
        return Icons.shield;
    }
  }

  String _getAlertMessage(String alertLevel, int totalCount) {
    switch (alertLevel) {
      case 'HIGH':
        return 'HIGH ALERT ACTIVE - Immediate attention required!';
      case 'BASIC':
        return 'Basic alert triggered - Please check the situation';
      case 'MINOR':
        return 'Minor movement detected - Monitoring continues';
      default:
        return totalCount > 0
            ? '$totalCount total events detected today'
            : 'System monitoring - No alerts detected';
    }
  }

  Widget _buildCounterRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showTieredDetailsDialog(BuildContext context, FallDetectionProvider provider, String currentAlertLevel) {
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
                  color: _getAlertColor(currentAlertLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAlertIcon(currentAlertLevel),
                  color: _getAlertColor(currentAlertLevel),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tiered Detection History',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert level explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alert Levels:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildLevelInfo('🔴 HIGH (90%+)', 'Critical alerts with notifications'),
                        _buildLevelInfo('🟠 BASIC (80%+)', 'Standard alerts with notifications'),
                        _buildLevelInfo('🔵 MINOR (75%+)', 'Count only, no notifications'),
                        _buildLevelInfo('🟢 NONE (<75%)', 'Normal movement, no action'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Recent Events:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  provider.recentFalls.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No events detected yet'),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.recentFalls.length,
                    itemBuilder: (context, index) {
                      FallEvent fall = provider.recentFalls[index];
                      String eventLevel = _getEventLevel(fall.probability);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getAlertColor(eventLevel).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getAlertIcon(eventLevel),
                              color: _getAlertColor(eventLevel),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${_formatTime(fall.timestamp)} - $eventLevel',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Confidence: ${(fall.probability * 100).toStringAsFixed(1)}%'),
                              Text('Location: ${fall.location}'),
                              if (fall.isFalseAlarm)
                                const Text(
                                  'Marked as false alarm',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: !fall.isFalseAlarm
                              ? TextButton(
                            onPressed: () {
                              provider.markFallAsFalseAlarm(fall.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('False Alarm'),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (provider.fallCount > 0)
              ElevatedButton(
                onPressed: () {
                  provider.resetFallCount();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAlertColor(currentAlertLevel),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset All'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLevelInfo(String level, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            level,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventLevel(double probability) {
    if (probability >= 0.90) return 'HIGH';
    if (probability >= 0.80) return 'BASIC';
    if (probability >= 0.75) return 'MINOR';
    return 'NONE';
  }
}

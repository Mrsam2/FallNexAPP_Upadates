import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fall_detection/providers/ai_guidance_provider.dart';
import 'package:fall_detection/providers/health_data_provider.dart';

class AIGuidanceScreen extends StatefulWidget {
  const AIGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<AIGuidanceScreen> createState() => _AIGuidanceScreenState();
}

class _AIGuidanceScreenState extends State<AIGuidanceScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      sender: 'AI',
      message: 'Hello! I\'m your AI health assistant. I can provide guidance based on health monitoring data and fall detection analysis. How can I help you today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    if (_questionController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      sender: 'You',
      message: _questionController.text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatMessages.add(userMessage);
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final aiMessage = getAIResponse(_questionController.text);
      setState(() {
        _chatMessages.add(aiMessage);
      });
    });

    _questionController.clear();
  }

  ChatMessage getAIResponse(String userQuestion) {
    // This is a simple mock response generator
    // In a real application, this would connect to an actual AI service
    final lowercaseQuestion = userQuestion.toLowerCase();
    String response;

    if (lowercaseQuestion.contains('fall') || lowercaseQuestion.contains('fell')) {
      response = 'Based on our monitoring, we haven\'t detected any falls in the past 24 hours. The system is actively monitoring all camera feeds. Would you like to see the fall prevention tips?';
    } else if (lowercaseQuestion.contains('health') || lowercaseQuestion.contains('status')) {
      final healthProvider = Provider.of<HealthDataProvider>(context, listen: false);
      response = 'The current health status is ${healthProvider.overallHealth}. Heart rate is ${healthProvider.heartRate} BPM, blood pressure is ${healthProvider.bloodPressure}, and temperature is ${healthProvider.temperature}°C. All vital signs are within normal ranges.';
    } else if (lowercaseQuestion.contains('camera') || lowercaseQuestion.contains('monitor')) {
      response = 'The monitoring system is active with 3 cameras currently online. OpenCV processing is running for fall detection with 98.2% accuracy. Would you like me to show you the camera feeds?';
    } else if (lowercaseQuestion.contains('help') || lowercaseQuestion.contains('emergency')) {
      response = 'In case of emergency, you can use the SOS button on the dashboard to quickly call for medical assistance. You can also set up emergency contacts in the settings menu.';
    } else if (lowercaseQuestion.contains('advice') || lowercaseQuestion.contains('suggest')) {
      response = 'Based on the recent health data, I suggest increasing daily physical activity. A short 15-minute walk would be beneficial. Also, the sleep pattern shows some irregularities - try to maintain a consistent sleep schedule.';
    } else {
      response = 'I\'m here to help with fall detection monitoring and health guidance. You can ask me about recent health status, fall detection system, or request advice based on the monitored data.';
    }

    return ChatMessage(
      sender: 'AI',
      message: response,
      timestamp: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIGuidanceProvider>(context);
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Guidance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get personalized health and care recommendations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Recommendations'),
                        Tab(text: 'Ask AI'),
                      ],
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRecommendationsTab(context, aiProvider),
                        _buildAskAITab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(BuildContext context, AIGuidanceProvider aiProvider) {
    final suggestions = aiProvider.suggestions;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI Health Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Based on continuous monitoring of health data and activity patterns, our AI has generated personalized recommendations to improve wellbeing and safety.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Personalized Recommendations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            suggestions.length,
            (index) => _buildSuggestionCard(
              context,
              suggestions[index].title,
              suggestions[index].description,
              suggestions[index].icon,
              suggestions[index].priority,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fall Prevention Tips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildFallPreventionTips(context),
        ],
      ),
    );
  }

  Widget _buildAskAITab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              return _buildChatMessage(context, message);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Ask a question about health or fall detection...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 1,
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _handleSendMessage,
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String priority,
  ) {
    Color priorityColor;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.blue;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: priorityColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: priorityColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // View more details about this recommendation
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Learn More'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallPreventionTips(BuildContext context) {
    final tips = [
      {
        'title': 'Remove Trip Hazards',
        'description': 'Keep floors clear of clutter, secure loose rugs, and arrange furniture to create clear pathways.',
        'icon': Icons.home,
      },
      {
        'title': 'Improve Lighting',
        'description': 'Ensure all areas of the home are well-lit, especially stairways and bathrooms. Consider motion-activated lights.',
        'icon': Icons.lightbulb,
      },
      {
        'title': 'Install Grab Bars',
        'description': 'Add grab bars in the bathroom near the toilet and in the shower for additional stability.',
        'icon': Icons.handyman,
      },
    ];
    
    return Column(
      children: tips.map((tip) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tip['icon'] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['description'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatMessage(BuildContext context, ChatMessage message) {
    final isUserMessage = message.sender == 'You';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUserMessage ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
  });
}

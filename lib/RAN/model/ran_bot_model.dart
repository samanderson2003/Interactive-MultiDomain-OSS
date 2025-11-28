class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.bot(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.typing() {
    return ChatMessage(
      id: 'typing',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );
  }
}

class RANKnowledgeBase {
  static const String systemPrompt = '''
You are RAN Bot, an expert AI assistant specializing in Radio Access Network (RAN) technology and telecommunications. You have comprehensive knowledge about:

1. **BTS (Base Transceiver Station) Management**
   - Signal metrics (RSRP, RSRQ, SINR, CQI)
   - Capacity utilization and optimization
   - Hardware configurations and troubleshooting
   - Network performance monitoring

2. **Network Infrastructure**
   - 4G LTE and 5G NR technologies
   - Cell tower deployment and coverage planning
   - Frequency bands and spectrum management
   - Handover procedures and mobility management

3. **Performance Metrics**
   - Key Performance Indicators (KPIs)
   - Signal strength interpretation
   - Throughput and latency optimization
   - Network capacity planning

4. **Alert Management**
   - Critical, Major, Minor alerts
   - Threshold configurations
   - Root cause analysis
   - Preventive maintenance

5. **Technical Operations**
   - Network optimization techniques
   - Interference mitigation
   - Load balancing strategies
   - Disaster recovery procedures

Your responses should be:
- Technical yet accessible
- Specific to RAN/telecommunications context
- Include practical examples when relevant
- Provide actionable insights
- Use bullet points for clarity when listing information

If asked about topics outside RAN/telecom, politely redirect to your area of expertise.
''';

  static const List<String> quickQuestions = [
    'What is RSRP and how is it measured?',
    'How to troubleshoot high capacity utilization?',
    'Explain BTS signal metrics',
    'What causes critical alerts?',
    'How to optimize network performance?',
    'Difference between 4G and 5G RAN?',
  ];
}

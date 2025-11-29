import 'package:flutter/material.dart';
import '../model/core_bot_model.dart';

class CoreBotController with ChangeNotifier {
  final List<CoreBotMessage> _messages = [];
  bool _isTyping = false;

  List<CoreBotMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  CoreBotController() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      CoreBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Hello! I\'m your CORE Network AI Assistant. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    _messages.add(
      CoreBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
    notifyListeners();

    // Show typing indicator
    _isTyping = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate bot response
    final response = _generateResponse(content);
    _messages.add(
      CoreBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );

    _isTyping = false;
    notifyListeners();
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('status') || lowerMessage.contains('health')) {
      return 'All CORE network elements are operational. Voice Service: 99.8% uptime, Data Service: 99.9% uptime, SMS Service: 99.8% uptime. Location Service is currently degraded at 98.5% uptime.';
    } else if (lowerMessage.contains('kpi') ||
        lowerMessage.contains('performance')) {
      return 'Current CORE KPIs:\n• Attach Success Rate: 97.8%\n• Detach Rate: 42.5/s\n• Average Latency: 85ms\n• Total Throughput: 625.8 Gbps';
    } else if (lowerMessage.contains('hlr') ||
        lowerMessage.contains('home location register')) {
      return 'The Home Location Register (HLR) is operational with 2 active instances. It stores subscriber information and authentication data for the network.';
    } else if (lowerMessage.contains('mme') ||
        lowerMessage.contains('mobility management')) {
      return 'The Mobility Management Entity (MME) has 2 active instances handling subscriber mobility, authentication, and bearer management for LTE networks.';
    } else if (lowerMessage.contains('sgw') ||
        lowerMessage.contains('serving gateway')) {
      return 'The Serving Gateway (SGW) has 2 instances managing user plane data routing between the eNodeB and PGW.';
    } else if (lowerMessage.contains('pgw') ||
        lowerMessage.contains('packet gateway')) {
      return 'The Packet Data Network Gateway (PGW) has 2 instances providing connectivity between the LTE network and external packet data networks.';
    } else if (lowerMessage.contains('alert') ||
        lowerMessage.contains('issue')) {
      return 'Currently tracking 1 issue: Location Service is experiencing degraded performance. The engineering team has been notified and is investigating.';
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('command')) {
      return 'I can help you with:\n• Network status and health checks\n• KPI and performance metrics\n• Element information (HLR, MME, SGW, PGW, HSS)\n• Service health monitoring\n• Alert and issue tracking\n\nJust ask me anything about the CORE network!';
    } else {
      return 'I understand you\'re asking about "${userMessage}". I\'m here to help with CORE network operations, monitoring, and troubleshooting. Try asking about network status, KPIs, or specific elements like HLR, MME, SGW, or PGW.';
    }
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }
}

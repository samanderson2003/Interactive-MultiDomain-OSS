import 'package:flutter/material.dart';
import '../model/ip_bot_model.dart';

class IPBotController with ChangeNotifier {
  final List<IPBotMessage> _messages = [];
  bool _isTyping = false;

  List<IPBotMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  IPBotController() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      IPBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Hello! I\'m your IP Transport AI Assistant. How can I help you today?',
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
      IPBotMessage(
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
      IPBotMessage(
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
      return 'All IP Transport routers are operational. Network status: 8 routers active (2 Core, 4 Edge, 2 Access), 7 links monitored. Total network capacity: 320 Gbps.';
    } else if (lowerMessage.contains('bandwidth') ||
        lowerMessage.contains('utilization')) {
      return 'Current bandwidth utilization:\n• Average: 68.5%\n• Peak: 85.3%\n• Current: 72.1%\n• Total Capacity: 320 Gbps\n• Available: 89.3 Gbps';
    } else if (lowerMessage.contains('latency')) {
      return 'Network latency status:\n• Core-Router links: 1.8-5.9ms\n• Edge-Router links: 3.4-9.5ms\n• Access links: 1.6-3.4ms\n• Average latency: 4.2ms';
    } else if (lowerMessage.contains('packet loss')) {
      return 'Packet loss statistics:\n• Critical links (>1%): 0\n• Warning links (0.5-1%): 0\n• Healthy links (<0.5%): 7\n• Network packet loss: 0.23%';
    } else if (lowerMessage.contains('link') ||
        lowerMessage.contains('connection')) {
      return 'Network has 7 active links:\n• Core-to-Core: 1 link\n• Core-to-Edge: 4 links\n• Edge-to-Access: 2 links\nAll links operational with varying utilization levels.';
    } else if (lowerMessage.contains('router') ||
        lowerMessage.contains('node')) {
      return 'Router inventory:\n• Core Routers: 2 (Core-Router-01, Core-Router-02)\n• Edge Routers: 4 (Edge-Router-01 to 04)\n• Access Switches: 2 (Access-SW-01, Access-SW-02)\nAll devices operational and reachable.';
    } else if (lowerMessage.contains('alert') ||
        lowerMessage.contains('issue') ||
        lowerMessage.contains('problem')) {
      return 'Current alerts: 3 active alerts detected. High utilization threshold exceeded on multiple links. Engineering team monitoring. Check the alerts section for detailed information.';
    } else if (lowerMessage.contains('topology')) {
      return 'Network topology overview: Hierarchical design with 2 core routers providing redundancy, 4 edge routers for distribution, and 2 access switches. Mesh connectivity between core routers, dual-homed edge routers for high availability.';
    } else if (lowerMessage.contains('help') ||
        lowerMessage.contains('command')) {
      return 'I can help you with:\n• Network status and health checks\n• Bandwidth and utilization metrics\n• Latency monitoring\n• Packet loss statistics\n• Link and router information\n• Topology overview\n• Alert and issue tracking\n\nJust ask me anything about the IP Transport network!';
    } else {
      return 'I understand you\'re asking about "${userMessage}". I\'m here to help with IP Transport network operations, monitoring, and troubleshooting. Try asking about network status, bandwidth, latency, links, or routers.';
    }
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }
}

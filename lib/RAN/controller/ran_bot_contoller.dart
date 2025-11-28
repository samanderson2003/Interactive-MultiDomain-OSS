import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import '../model/ran_bot_model.dart';

class RANBotController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // Initialize OpenAI with API key
  void initialize(String apiKey) {
    if (apiKey.isEmpty) {
      _errorMessage = 'OpenAI API key is required';
      notifyListeners();
      return;
    }

    try {
      OpenAI.apiKey = apiKey;
      _isInitialized = true;

      // Add welcome message
      _messages.add(
        ChatMessage.bot(
          'Hello! 👋 I\'m RAN Bot, your AI assistant for Radio Access Network queries. '
          'Ask me anything about BTS management, network performance, signal metrics, or troubleshooting!',
        ),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Send message and get AI response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;
    if (!_isInitialized) {
      _errorMessage = 'Bot not initialized. Please check your API key.';
      notifyListeners();
      return;
    }

    // Add user message
    final userMsg = ChatMessage.user(userMessage.trim());
    _messages.add(userMsg);

    // Add typing indicator
    _messages.add(ChatMessage.typing());
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Prepare conversation history
      final List<OpenAIChatCompletionChoiceMessageModel> chatMessages = [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              RANKnowledgeBase.systemPrompt,
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      ];

      // Add recent conversation history (last 10 messages)
      final recentMessages = _messages
          .where((m) => !m.isTyping)
          .toList()
          .reversed
          .take(10)
          .toList()
          .reversed;

      for (var msg in recentMessages) {
        chatMessages.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                msg.content,
              ),
            ],
            role: msg.isUser
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
          ),
        );
      }

      // Get response from OpenAI
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: chatMessages,
        temperature: 0.7,
        maxTokens: 800,
      );

      // Remove typing indicator
      _messages.removeWhere((m) => m.isTyping);

      // Add bot response
      final botResponse =
          response.choices.first.message.content?.first.text ??
          'I apologize, but I couldn\'t generate a response. Please try again.';

      _messages.add(ChatMessage.bot(botResponse));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Remove typing indicator
      _messages.removeWhere((m) => m.isTyping);

      _errorMessage = 'Failed to get response: ${e.toString()}';
      _isLoading = false;

      // Add error message
      _messages.add(
        ChatMessage.bot(
          'I encountered an error processing your request. Please try again or rephrase your question.',
        ),
      );

      notifyListeners();
    }
  }

  // Send quick question
  void sendQuickQuestion(String question) {
    sendMessage(question);
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    _messages.add(
      ChatMessage.bot(
        'Chat cleared! How can I assist you with RAN topics today?',
      ),
    );
    _errorMessage = '';
    notifyListeners();
  }

  // Retry last message if there was an error
  void retryLastMessage() {
    if (_messages.length >= 2) {
      final lastUserMessage = _messages.reversed.firstWhere(
        (m) => m.isUser,
        orElse: () => _messages.first,
      );

      if (lastUserMessage.isUser) {
        // Remove last bot error message
        if (!_messages.last.isUser) {
          _messages.removeLast();
        }
        sendMessage(lastUserMessage.content);
      }
    }
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}

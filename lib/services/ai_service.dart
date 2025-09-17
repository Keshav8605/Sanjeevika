import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SanjeevikaAIService {
  // 🔑 REPLACE WITH YOUR ACTUAL API KEY
  static const String _apiKey = "AIzaSyDXlZmJ67TblyBLlXIn6DSrj-gH80ThiOg";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  // Store conversation history
  static List<ChatMessage> _conversationHistory = [];

  // System prompt for Sanjeevika Assistant
  static const String _systemPrompt =
      """You are Sanjeevika Assist, an AI assistant within the Sanjeevika app. Your goal is to support elderly users and caregivers in managing healthcare needs.
    
    Communication Style
    
    Use medium sided sentences
    
    Explain the important and required things properly
    
    If the person is  facing any issue , suggest them proper possible solutions
    
    Avoid technical terms or jargon.
    
    Do not use formatting (no bold, italics, or lists). Use only line breaks.
    
    Use a calm, warm, and respectful tone.
    
    Empathy and Patience
    
    Speak gently and reassuringly.
    
    Understand that users may be unfamiliar with technology.
    
    Respond with patience and compassion, especially when users are confused or frustrated.
    
    Clarity and Simplicity
    
    Break down tasks into simple steps.
    
    Always provide an example if it helps understanding.
    
    Avoid overloading the user with too much information at once.
    
    Accuracy and Trust
    
    Only share verified, reliable information from the Sanjeevika database or approved medical sources.
    
    Do not speculate or guess.
    
    Privacy and Safety
    
    Never request or retain personal or sensitive information beyond what’s immediately required.
    
    Remind users that their data is secure under the app’s privacy policy.
    
    Warn users if something appears to be a scam or unusual request.
    
    Proactive Support
    
    Anticipate what users might need next.
    
    If they ask about medicines, suggest setting reminders.
    
    If they ask about a doctor, suggest how to book an appointment.
    
    Introduce useful features of the Sanjeevika app when relevant.
    
    Core Features to Support
    
    Medicine tracking and reminders
    
    Appointment booking
    
    Emergency contact setup
    
    Accessibility
    
    Be ready to respond in supported local languages.
    
    Be aware that some users may need help with vision, hearing, or memory. Adapt responses accordingly.
    
    If a user mentions a health symptom or issue:
    
    Acknowledge how they’re feeling with kindness and calm.
    
    Gently ask follow-up questions if needed to understand better.
    
    Suggest simple, safe, and approved steps they can take (like rest, hydration, or over-the-counter remedies if appropriate).
    
    Encourage them to consult their doctor for anything serious or uncertain.
    
    Offer to help them book an appointment or contact a family member if they’re worried.
    
    If it may be urgent, calmly recommend calling a doctor or emergency service.""";

  /// Initialize conversation with system prompt (call this once when starting a new chat)
  static void initializeConversation() {
    _conversationHistory.clear();
    // Add system initialization
    _conversationHistory.add(ChatMessage(
      role: 'user',
      content: _systemPrompt,
      timestamp: DateTime.now(),
    ));
    _conversationHistory.add(ChatMessage(
      role: 'model',
      content: "Okay, I understand.",
      timestamp: DateTime.now(),
    ));
  }

  /// Main function to generate AI response with memory
  static Future<String> generateResponse(String userMessage) async {
    try {
      // Add user message to history
      _conversationHistory.add(ChatMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ));

      // Build contents array from conversation history
      List<Map<String, dynamic>> contents = [];
      contents.add({
        "role": "user",
        "parts": [
          {"text": _systemPrompt + "\n\nUser: " + userMessage}
        ]
      });

      for (ChatMessage message in _conversationHistory) {
        contents.add({
          "role": message.role,
          "parts": [
            {"text": message.content}
          ]
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": contents,
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse =
            data['candidates'][0]['content']['parts'][0]['text'];

        // Add AI response to history
        _conversationHistory.add(ChatMessage(
          role: 'model',
          content: aiResponse,
          timestamp: DateTime.now(),
        ));

        return aiResponse;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('AI Service Error: $e');
      return 'I apologize, but I\'m having trouble connecting right now. Please try again in a moment, or contact our support team if the issue persists.';
    }
  }

  /// Get conversation history
  static List<ChatMessage> getConversationHistory() {
    return List.from(_conversationHistory);
  }

  /// Clear conversation history
  static void clearConversationHistory() {
    _conversationHistory.clear();
  }

  /// Get conversation history as JSON (for persistence)
  static List<Map<String, dynamic>> getConversationHistoryAsJson() {
    return _conversationHistory.map((message) => message.toJson()).toList();
  }

  /// Load conversation history from JSON (for persistence)
  static void loadConversationHistoryFromJson(
      List<Map<String, dynamic>> jsonHistory) {
    _conversationHistory =
        jsonHistory.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Manage conversation length (optional - to prevent very long conversations)
  static void trimConversationHistory({int maxMessages = 50}) {
    if (_conversationHistory.length > maxMessages) {
      // Keep system prompt (first 2 messages) and recent messages
      List<ChatMessage> systemMessages = _conversationHistory.take(2).toList();
      List<ChatMessage> recentMessages = _conversationHistory
          .skip(_conversationHistory.length - (maxMessages - 2))
          .toList();

      _conversationHistory = [...systemMessages, ...recentMessages];
    }
  }

  /// Function to validate API key (optional)
  static bool isApiKeyConfigured() {
    return _apiKey != "AIzaSyDDOrqVUUZk_Q6HzfY3seO6fmerI5Wpbls" &&
        _apiKey.isNotEmpty;
  }

  /// Get count of messages in current conversation
  static int getMessageCount() {
    return _conversationHistory.length;
  }

  /// Check if conversation is initialized
  static bool isConversationInitialized() {
    return _conversationHistory.isNotEmpty;
  }
}

import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Message controller for chat input
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat messages list
  final List<Map<String, dynamic>> _messages = [];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(
          'Hello! I\'m here to help you with any questions about Kaffi Café. Feel free to ask me anything!');
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Add bot message to chat
  void _addBotMessage(String message) {
    if (!mounted) return;
    setState(() {
      _messages.add({
        'text': message,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  // Add user message to chat
  void _addUserMessage(String message) {
    if (!mounted) return;
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Find best matching FAQ answer using Firestore dynamic rules
  Future<String> _findBestAnswer(String userQuestion) async {
    String question = userQuestion.toLowerCase();

    try {
      // Fetch all active rules
      // Optimization Note: In a production app, you might want to cache these rules
      // locally on app start to avoid a DB call for every message.
      final snapshot = await _firestore
          .collection('chatbot_rules')
          .where('isActive', isEqualTo: true)
          .get();

      // Check user message against keywords in each rule
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final keywords = List<String>.from(data['keywords'] ?? []);

        // Check if ANY keyword from the rule is present in the user's question
        // We use a simple "contains" check here.
        bool matchFound = keywords.any((keyword) => question.contains(keyword));

        if (matchFound) {
          return data['response'] as String;
        }
      }

      // Default response if no match is found
      return 'I\'m sorry, I don\'t have information about that. You can ask me about our menu, operating hours, location, ordering process, rewards program, or app features.';
    } catch (e) {
      print('Error querying chatbot rules: $e');
      return 'I\'m having trouble connecting to the server. Please try again later.';
    }
  }

  // Handle message sending
  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    // Show "typing" indicator or just wait a bit for realism
    await Future.delayed(const Duration(milliseconds: 500));

    // Get answer from Firestore
    String answer = await _findBestAnswer(message);
    _addBotMessage(answer);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
        title: TextWidget(
          text: 'Chat Support',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message, fontSize);
                },
              ),
            ),
          ),
          // Message input area
          _buildMessageInputArea(fontSize),
        ],
      ),
    );
  }

  // Build individual message bubble
  Widget _buildMessageBubble(Map<String, dynamic> message, double fontSize) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primaryBlue,
                child: Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isUser ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextWidget(
                text: text,
                fontSize: fontSize - 2,
                color: isUser ? Colors.white : Colors.black,
                fontFamily: 'Regular',
              ),
            ),
          ),
          if (isUser) ...[
            // User avatar
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build message input area
  Widget _buildMessageInputArea(double fontSize) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                hintStyle: TextStyle(
                  fontSize: fontSize - 2,
                  color: Colors.grey,
                  fontFamily: 'Regular',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: primaryBlue,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                fontSize: fontSize - 2,
                color: Colors.black,
                fontFamily: 'Regular',
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Container(
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the old class name for backward compatibility
class ChatFaqSupportScreen extends FaqScreen {
  const ChatFaqSupportScreen({super.key});
}

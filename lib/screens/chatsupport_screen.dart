import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

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

  // FAQs data - Combined from both sources
  final List<Map<String, String>> _allFaqs = [
    // Store Information
    {
      'question': 'What are your best seller drinks?',
      'answer':
          'Biscoff Latte and Spanish Latte are the top favorites at Kaffi Café!'
    },
    {
      'question': 'Do you have free wifi?',
      'answer': 'Yes, free Wi-Fi is available for all dine-in customers.'
    },
    {
      'question': 'What is the Password of WIFI?',
      'answer': 'It changes every week you can find it printed on your receipt'
    },
    {
      'question': 'How long can I access WIFI?',
      'answer': 'There\'s no time limit for dine-in customers.'
    },
    {
      'question': 'What are your Operating Hours?',
      'answer': 'The café opens at 10:00 AM and closes at 2:00 AM.'
    },
    {
      'question': 'Where are your branches located?',
      'answer':
          'Our store is located at P.Noval in front of UST, and 1218 Delos Reyes St. corner Eloisa St. in MANILA'
    },
    // Order & Payment
    {
      'question': 'How do I place an order?',
      'answer':
          'Browse the menu, select your food or drink, add to cart, and proceed to checkout to confirm your order.'
    },
    {
      'question': 'Can I reserve a table in advance?',
      'answer':
          'Yes! Go to the "Dine-in" section, select your preferred table and time, and confirm your booking.'
    },
    {
      'question': 'How do I pay for my order?',
      'answer':
          'You can pay securely through PayMongo Sandbox (demo payment). In the future, this will support real payment options.'
    },
    {
      'question': 'Can I change or cancel my order after placing it?',
      'answer':
          'Once confirmed, orders can no longer be changed or canceled through the app. You may contact the staff directly for special requests.'
    },
    {
      'question': 'Do you offer delivery?',
      'answer':
          'Currently, delivery is not available, but you can order for pickup or dine-in.'
    },
    {
      'question': 'Can I order in advance before arriving?',
      'answer': 'Yes! You can order ahead and just pick it up when you arrive.'
    },
    {
      'question': 'Do you offer group or bulk orders?',
      'answer':
          'Yes, you can place multiple items in one order for group purchases.'
    },
    // Rewards & Points
    {
      'question': 'How does the loyalty and rewards system work?',
      'answer':
          'Every purchase earns you points. You can exchange points for vouchers or discounts on your next order.'
    },
    {
      'question': 'How do I earn points?',
      'answer': 'Earn 10% of your total order value in points at Kaffi Cafe.'
    },
    {
      'question': 'How can I redeem vouchers?',
      'answer': 'Visit the Rewards tab to redeem vouchers using your points.'
    },
    // App Features
    {
      'question': 'How do I get personalized drink recommendations?',
      'answer':
          'The app uses a KNN (K-Nearest Neighbors) algorithm that suggests drinks or food items based on your previous orders or popular items.'
    },
    {
      'question': 'How do I know if my order is confirmed?',
      'answer':
          'You will receive in-app notification and the status of your order will display "Confirmed"'
    },
    {
      'question': 'Is my data safe in the app?',
      'answer':
          'Yes. The system uses Firebase Authentication and Firestore for secure storage and encrypted transactions.'
    },
    {
      'question': 'Why can\'t I use real payments yet?',
      'answer':
          'The app currently uses the PayMongo Sandbox for testing, as real payment setup requires verified business documents.'
    },
    // Policies
    {
      'question': 'What is the return policy?',
      'answer': 'Returns are accepted within 24 hours with a valid receipt.'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _addBotMessage(
        'Hello! I\'m here to help you with any questions about Kaffi Café. Feel free to ask me anything!');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Add bot message to chat
  void _addBotMessage(String message) {
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

  // Find best matching FAQ answer using simple keyword matching
  String _findBestAnswer(String userQuestion) {
    String question = userQuestion.toLowerCase();

    // Check for small talk patterns first
    String? smallTalkResponse = _checkSmallTalk(question);
    if (smallTalkResponse != null) {
      return smallTalkResponse;
    }

    // Calculate similarity score for each FAQ
    Map<String, double> scores = {};

    for (var faq in _allFaqs) {
      double score = 0;
      String faqQuestion = faq['question']!.toLowerCase();
      String faqAnswer = faq['answer']!.toLowerCase();

      // Split user question into words
      List<String> userWords = question.split(RegExp(r'\s+'));

      // Check for keyword matches in FAQ question
      for (String word in userWords) {
        if (word.length > 2) {
          // Ignore very short words
          if (faqQuestion.contains(word)) {
            score += 2; // Higher weight for question matches
          }
          if (faqAnswer.contains(word)) {
            score += 1; // Lower weight for answer matches
          }
        }
      }

      scores[faq['question']!] = score;
    }

    // Find the FAQ with highest score
    String bestQuestion = '';
    double highestScore = 0;

    scores.forEach((question, score) {
      if (score > highestScore) {
        highestScore = score;
        bestQuestion = question;
      }
    });

    // If no good match found, return default response
    if (highestScore < 2) {
      return 'I\'m sorry, I don\'t have information about that. You can ask me about our menu, operating hours, location, ordering process, rewards program, or app features.';
    }

    // Return the answer for the best matching question
    var matchedFaq =
        _allFaqs.firstWhere((faq) => faq['question'] == bestQuestion);
    return matchedFaq['answer']!;
  }

  // Check for small talk patterns and return appropriate responses
  String? _checkSmallTalk(String question) {
    // Greetings
    if (question.contains('hello') ||
        question.contains('hi') ||
        question.contains('hey')) {
      return 'Hello! Welcome to Kaffi Café! How can I help you today? ☕';
    }

    if (question.contains('good morning') || question.contains('morning')) {
      return 'Good morning! Nothing beats starting the day with a great cup of coffee! What can I get for you today?';
    }

    if (question.contains('good afternoon') || question.contains('afternoon')) {
      return 'Good afternoon! Perfect time for a coffee break! How can I assist you?';
    }

    if (question.contains('good evening') || question.contains('evening')) {
      return 'Good evening! We\'re open until 2 AM if you need a late-night coffee fix! What can I help you with?';
    }

    // How are you
    if (question.contains('how are you')) {
      return 'I\'m doing great, thanks for asking! Ready to help you with all things Kaffi Café! 😊';
    }

    // Coffee related small talk
    if (question.contains('love coffee') || question.contains('coffee lover')) {
      return 'That\'s wonderful! You\'ve come to the right place! Our Biscoff Latte and Spanish Latte are customer favorites. Have you tried them?';
    }

    if (question.contains('what coffee') ||
        question.contains('recommend') ||
        question.contains('suggestion')) {
      return 'Great question! I\'d highly recommend our Biscoff Latte - it\'s our top seller! The Spanish Latte is also amazing if you like something a bit sweeter. What type of flavors do you usually enjoy?';
    }

    if (question.contains('best coffee') || question.contains('favorite')) {
      return 'Our customers absolutely love the Biscoff Latte and Spanish Latte! They\'re our signature drinks. Both have unique flavors that keep people coming back!';
    }

    if (question.contains('weather') &&
        (question.contains('coffee') || question.contains('perfect'))) {
      return 'Absolutely! Any weather is perfect weather for coffee! ☕ Whether it\'s hot or cold outside, there\'s always a great drink waiting for you at Kaffi Café.';
    }

    // Cafe atmosphere
    if (question.contains('study') ||
        question.contains('work') ||
        question.contains('wifi')) {
      return 'Kaffi Café is perfect for studying or working! We have free Wi-Fi for dine-in customers, a cozy atmosphere, and of course, plenty of delicious coffee to keep you focused!';
    }

    if (question.contains('cozy') ||
        question.contains('ambiance') ||
        question.contains('atmosphere')) {
      return 'We pride ourselves on creating a warm, welcoming atmosphere! Whether you\'re here to study, catch up with friends, or just enjoy a great cup of coffee, Kaffi Café is the perfect spot.';
    }

    // Thank you responses
    if (question.contains('thank') || question.contains('thanks')) {
      return 'You\'re very welcome! I\'m happy to help. Is there anything else you\'d like to know about Kaffi Café?';
    }

    // Goodbye
    if (question.contains('bye') ||
        question.contains('goodbye') ||
        question.contains('see you')) {
      return 'Goodbye! We look forward to serving you soon at Kaffi Café. Have a wonderful day! ☕';
    }

    // General positive responses
    if (question.contains('awesome') ||
        question.contains('great') ||
        question.contains('amazing')) {
      return 'Thank you! We try our best to provide an excellent experience at Kaffi Café! Is there anything specific I can help you with?';
    }

    // Help related
    if (question.contains('help') || question.contains('assist')) {
      return 'I\'m here to help! You can ask me about our menu, operating hours, location, ordering process, rewards program, or any other questions about Kaffi Café!';
    }

    return null; // No small talk pattern matched
  }

  // Handle message sending
  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    // Simulate bot thinking delay
    Future.delayed(const Duration(milliseconds: 500), () {
      String answer = _findBestAnswer(message);
      _addBotMessage(answer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
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
                backgroundColor: bayanihanBlue,
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
                color: isUser ? bayanihanBlue : Colors.white,
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
                color: isUser ? Colors.white : textBlack,
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
                  color: charcoalGray,
                  fontFamily: 'Regular',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: ashGray,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: ashGray,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: bayanihanBlue,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: cloudWhite,
              ),
              style: TextStyle(
                fontSize: fontSize - 2,
                color: textBlack,
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
              color: bayanihanBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bayanihanBlue.withOpacity(0.3),
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

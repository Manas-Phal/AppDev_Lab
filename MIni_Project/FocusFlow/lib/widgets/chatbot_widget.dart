import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';
import '../models/task.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoadingHistory = true;
  bool _isGeneratingResponse = false;
  List<Task> _userTasks = [];
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Load user tasks for context
      _userTasks = await AIService.fetchUserTasks(user.uid);
      
      // Calculate analytics
      _analytics = AIService.calculateAnalytics(_userTasks);
      
      setState(() {});
    }
  }

  Future<void> _loadChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _messages.add({
          'text': 'Hello! I\'m your AI assistant. How can I help you with productivity today?',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
        _isLoadingHistory = false;
      });
      return;
    }

    try {
      final historyRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatbot_history')
          .orderBy('timestamp', descending: false)
          .limit(50);

      final snapshot = await historyRef.get();
      
      if (snapshot.docs.isEmpty) {
        // No history, add welcome message
        setState(() {
          _messages.add({
            'text': 'Hello! I\'m your AI assistant. How can I help you with productivity today?',
            'sender': 'bot',
            'timestamp': DateTime.now(),
          });
        });
      } else {
        // Load existing messages
        final loadedMessages = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'text': data['text'] ?? '',
            'sender': data['sender'] ?? 'bot',
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'id': doc.id,
          };
        }).toList();
        
        setState(() {
          _messages.addAll(loadedMessages);
        });
        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      setState(() {
        _messages.add({
          'text': 'Hello! I\'m your AI assistant. How can I help you with productivity today?',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
      });
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isGeneratingResponse) return;

    final user = _auth.currentUser;
    final timestamp = DateTime.now();

    // Add user message to UI
    setState(() {
      _messages.add({
        'text': text,
        'sender': 'user',
        'timestamp': timestamp,
      });
      _isGeneratingResponse = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Save user message to Firestore
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('chatbot_history')
            .add({
          'text': text,
          'sender': 'user',
          'timestamp': Timestamp.fromDate(timestamp),
        });
      } catch (e) {
        debugPrint('Error saving user message: $e');
      }
    }

    // Show typing indicator
    setState(() {
      _messages.add({
        'text': 'Thinking...',
        'sender': 'bot',
        'timestamp': DateTime.now(),
        'isTyping': true,
      });
    });
    _scrollToBottom();

    // Refresh user data for latest context
    await _loadUserData();

    // Get AI response
    try {
      final response = await AIService.getAIResponse(
        userMessage: text,
        userId: user?.uid ?? 'guest',
        tasks: _userTasks,
        analytics: _analytics,
      );
      
      final botTimestamp = DateTime.now();
      
      // Remove typing indicator and add response
      setState(() {
        _messages.removeLast(); // Remove typing indicator
        _messages.add({
          'text': response,
          'sender': 'bot',
          'timestamp': botTimestamp,
        });
        _isGeneratingResponse = false;
      });
      _scrollToBottom();

      // Save bot response to Firestore
      if (user != null) {
        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('chatbot_history')
              .add({
            'text': response,
            'sender': 'bot',
            'timestamp': Timestamp.fromDate(botTimestamp),
          });
        } catch (e) {
          debugPrint('Error saving bot message: $e');
        }
      }
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      setState(() {
        _messages.removeLast(); // Remove typing indicator
        _messages.add({
          'text': 'Sorry, I encountered an error. Please try again.',
          'sender': 'bot',
          'timestamp': DateTime.now(),
        });
        _isGeneratingResponse = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Messages area
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message['sender'] == 'user';

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? Colors.blue.shade700 : Colors.blue.shade500)
                        : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: message['isTyping'] == true
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              message['text'] ?? '',
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            fontSize: 14,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade700 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isGeneratingResponse
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: _isGeneratingResponse
                    ? null
                    : () => _sendMessage(_controller.text),
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


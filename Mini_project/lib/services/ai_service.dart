import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class AIService {
  // Google Gemini API configuration
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.0-flash-exp'; // or 'gemini-1.5-pro' for more capabilities
  
  // IMPORTANT: Store API key securely (use environment variables or secure storage)
  // For production, use Firebase Functions or backend to hide API key
  static String? _apiKey;
  
  static void setApiKey(String key) {
    _apiKey = key;
  }
  
  /// Get AI response with user context
  static Future<String> getAIResponse({
    required String userMessage,
    required String userId,
    List<Task>? tasks,
    Map<String, dynamic>? analytics,
  }) async {
    try {
      // Build context from user data
      final context = await _buildContext(userId, tasks, analytics);
      
      // Build prompt for Gemini
      final prompt = '''You are a helpful AI assistant for a productivity tracking app called FocusFlow. 
Your role is to help users with:
1. Task management - answering questions about their tasks, suggesting improvements, helping prioritize
2. Productivity tips - providing advice on time management, focus techniques, productivity methods
3. Analytics insights - explaining their productivity data, trends, and suggesting improvements

Always be friendly, concise, and actionable. When answering questions about the user's data, reference specific numbers and tasks when available.
Use the provided context about the user's tasks and productivity data to give personalized responses.

Context about user's productivity:
$context

User question: $userMessage''';
      
      // Call Gemini API
      final response = await _callGeminiAPI(prompt);
      
      if (response != null && response.isNotEmpty) {
        return response;
      } else {
        // Fallback response if API fails
        return _getFallbackResponse(userMessage, context);
      }
    } catch (e) {
      print('AI Service Error: $e');
      return _getFallbackResponse(userMessage, '');
    }
  }
  
  /// Build context string from user data
  static Future<String> _buildContext(
    String userId,
    List<Task>? tasks,
    Map<String, dynamic>? analytics,
  ) async {
    final buffer = StringBuffer();
    
    // Add tasks context
    if (tasks != null && tasks.isNotEmpty) {
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isDone).length;
      final pendingTasks = totalTasks - completedTasks;
      
      buffer.writeln('Tasks Summary:');
      buffer.writeln('- Total tasks: $totalTasks');
      buffer.writeln('- Completed: $completedTasks');
      buffer.writeln('- Pending: $pendingTasks');
      buffer.writeln('- Completion rate: ${totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(1) : 0}%');
      
      // Recent tasks
      final recentTasks = tasks.take(5).toList();
      if (recentTasks.isNotEmpty) {
        buffer.writeln('\nRecent tasks:');
        for (var task in recentTasks) {
          buffer.writeln('- ${task.title} (${task.isDone ? "Completed" : "Pending"}) - Category: ${task.category}');
        }
      }
      
      // Tasks by category
      final tasksByCategory = <String, int>{};
      for (var task in tasks) {
        tasksByCategory[task.category] = (tasksByCategory[task.category] ?? 0) + 1;
      }
      if (tasksByCategory.isNotEmpty) {
        buffer.writeln('\nTasks by category:');
        tasksByCategory.forEach((category, count) {
          buffer.writeln('- $category: $count tasks');
        });
      }
    } else {
      buffer.writeln('No tasks found.');
    }
    
    // Add analytics context
    if (analytics != null) {
      buffer.writeln('\nAnalytics:');
      if (analytics['totalTasks'] != null) {
        buffer.writeln('- Total tasks: ${analytics['totalTasks']}');
      }
      if (analytics['completedTasks'] != null) {
        buffer.writeln('- Completed tasks: ${analytics['completedTasks']}');
      }
      if (analytics['completionRate'] != null) {
        buffer.writeln('- Completion rate: ${analytics['completionRate']}%');
      }
      if (analytics['productivityLevel'] != null) {
        buffer.writeln('- Productivity level: ${analytics['productivityLevel']}');
      }
    }
    
    return buffer.toString();
  }
  
  /// Call Gemini API
  static Future<String?> _callGeminiAPI(String prompt) async {
    // If no API key is set, return null to use fallback
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('Gemini API key not set. Using fallback responses.');
      return null;
    }
    
    try {
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        }
        print('Gemini API: No text in response');
        return null;
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Gemini API Exception: $e');
      return null;
    }
  }
  
  /// Fallback response when AI API is not available
  static String _getFallbackResponse(String userMessage, String context) {
    final lower = userMessage.toLowerCase();
    
    // Enhanced fallback with context awareness
    if (context.isNotEmpty) {
      if (lower.contains('task') || lower.contains('todo')) {
        if (context.contains('Total tasks:')) {
          final taskMatch = RegExp(r'Total tasks: (\d+)').firstMatch(context);
          if (taskMatch != null) {
            return 'You have ${taskMatch.group(1)} tasks. Would you like help prioritizing them or getting productivity tips?';
          }
        }
        return 'I can help you with task management! You can add tasks in the Tasks tab, and I can provide tips on organization and productivity.';
      }
      
      if (lower.contains('complete') || lower.contains('finished') || lower.contains('done')) {
        if (context.contains('Completed:')) {
          final completedMatch = RegExp(r'Completed: (\d+)').firstMatch(context);
          if (completedMatch != null) {
            return 'Great job! You have completed ${completedMatch.group(1)} tasks. Keep up the excellent work!';
          }
        }
        return 'Congratulations on your progress! Completing tasks consistently is key to productivity.';
      }
      
      if (lower.contains('productivity') || lower.contains('progress')) {
        if (context.contains('Completion rate:')) {
          final rateMatch = RegExp(r'Completion rate: ([\d.]+)%').firstMatch(context);
          if (rateMatch != null) {
            final rate = double.tryParse(rateMatch.group(1) ?? '0') ?? 0;
            if (rate >= 70) {
              return 'Your completion rate is ${rateMatch.group(1)}% - excellent work! You\'re maintaining high productivity.';
            } else if (rate >= 40) {
              return 'Your completion rate is ${rateMatch.group(1)}% - good progress! Try breaking down larger tasks into smaller steps.';
            } else {
              return 'Your completion rate is ${rateMatch.group(1)}%. Let\'s work on improving this! Try focusing on one task at a time and setting realistic deadlines.';
            }
          }
        }
        return 'Productivity is about consistent progress. Try the Pomodoro technique: work for 25 minutes, then take a 5-minute break.';
      }
      
      if (lower.contains('analytics') || lower.contains('statistics') || lower.contains('data')) {
        return 'I can help you understand your productivity data! Check the Analytics tab for detailed charts and insights about your task completion trends.';
      }
      
      if (lower.contains('category') || lower.contains('categor')) {
        if (context.contains('Tasks by category:')) {
          return 'I can see your tasks are organized by categories. This helps with focus and prioritization!';
        }
        return 'Organizing tasks by category helps you focus on similar work together and improves efficiency.';
      }
    }
    
    // General responses
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return 'Hello! I\'m your AI productivity assistant. I can help you with tasks, productivity tips, and analytics insights. What would you like to know?';
    }
    
    if (lower.contains('help')) {
      return 'I can help you with:\n• Task management and prioritization\n• Productivity tips and techniques\n• Understanding your analytics and progress\n• Time management strategies\n\nWhat would you like help with?';
    }
    
    if (lower.contains('pomodoro') || lower.contains('focus') || lower.contains('time')) {
      return 'The Pomodoro Technique is great for focus! Work for 25 minutes, then take a 5-minute break. After 4 pomodoros, take a longer 15-30 minute break. This helps maintain focus and prevents burnout.';
    }
    
    if (lower.contains('habit') || lower.contains('routine')) {
      return 'Building good habits takes time and consistency. Start small, be specific about what you want to achieve, and track your progress. Remember, it takes about 21-66 days to form a new habit!';
    }
    
    // Default response
    return 'I\'m here to help with your productivity! I can assist with tasks, provide productivity tips, explain your analytics, and suggest improvements. Try asking about your tasks, productivity levels, or tips for better time management.';
  }
  
  /// Fetch user tasks for context
  static Future<List<Task>> fetchUserTasks(String userId) async {
    try {
      if (userId == 'guest' || userId.isEmpty) {
        return [];
      }
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching tasks for AI context: $e');
      return [];
    }
  }
  
  /// Calculate analytics data
  static Map<String, dynamic> calculateAnalytics(List<Task> tasks) {
    if (tasks.isEmpty) {
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'completionRate': 0.0,
        'productivityLevel': 'No data',
      };
    }
    
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isDone).length;
    final pendingTasks = totalTasks - completedTasks;
    final completionRate = (completedTasks / totalTasks * 100);
    
    String productivityLevel;
    if (completionRate >= 70) {
      productivityLevel = 'Excellent';
    } else if (completionRate >= 40) {
      productivityLevel = 'Good';
    } else {
      productivityLevel = 'Needs Improvement';
    }
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'completionRate': completionRate.toStringAsFixed(1),
      'productivityLevel': productivityLevel,
    };
  }
}

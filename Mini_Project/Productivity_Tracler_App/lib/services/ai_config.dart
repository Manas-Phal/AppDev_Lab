import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';

/// Configuration service for AI API key
/// Store API key securely using SharedPreferences
class AIConfig {
  static const String _apiKeyKey = 'ai_api_key';
  
  /// Load API key from storage and set it in AIService
  static Future<void> loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(_apiKeyKey);
      if (apiKey != null && apiKey.isNotEmpty) {
        AIService.setApiKey(apiKey);
      }
    } catch (e) {
      print('Error loading API key: $e');
    }
  }
  
  /// Save API key to storage
  static Future<void> saveApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey);
      AIService.setApiKey(apiKey);
    } catch (e) {
      print('Error saving API key: $e');
    }
  }
  
  /// Check if API key is set
  static Future<bool> hasApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(_apiKeyKey);
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Remove API key
  static Future<void> removeApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      AIService.setApiKey('');
    } catch (e) {
      print('Error removing API key: $e');
    }
  }
}


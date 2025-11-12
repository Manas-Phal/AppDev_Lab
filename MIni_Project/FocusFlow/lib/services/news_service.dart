import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  // Using NewsAPI.org - you'll need to get a free API key from https://newsapi.org
  // For demo purposes, using a free alternative API
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'ebb2acc1d5ae402fbb05b39b694a2209';
  
  // Alternative: Using a free API that doesn't require key
  static const String _freeBaseUrl = 'https://api.currentsapi.services/v1';
  static const String _freeApiKey = 'YOUR_CURRENTS_API_KEY'; // Get from https://currentsapi.services

  Future<List<Map<String, dynamic>>> fetchNews({String category = 'technology'}) async {
    try {
      // Using NewsAPI.org - top-headlines requires country parameter
      // Using 'everything' endpoint instead which is more flexible
      final url = Uri.parse('$_baseUrl/everything?q=$category&sortBy=publishedAt&apiKey=$_apiKey&pageSize=20&language=en');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('News API timeout');
        },
      );
      
      print('News API Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['articles'] != null) {
          final articles = List<Map<String, dynamic>>.from(data['articles']);
          // Filter out articles without required fields
          final validArticles = articles.where((article) => 
            article['title'] != null && 
            article['title'].toString().isNotEmpty &&
            article['description'] != null
          ).toList();
          
          if (validArticles.isNotEmpty) {
            return validArticles;
          }
        } else if (data['code'] != null) {
          // API error response
          print('News API Error: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        print('News API: Unauthorized - Check API key');
      } else if (response.statusCode == 429) {
        print('News API: Rate limit exceeded');
      } else {
        print('News API: Unexpected status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
    
    // Fallback: Try free API or return sample data
    try {
      final freeResult = await _fetchNewsFromFreeAPI(category);
      if (freeResult.isNotEmpty) {
        return freeResult;
      }
    } catch (e) {
      print('Error fetching from free API: $e');
    }
    
    // Final fallback: Return sample data
    return _getSampleNews();
  }

  Future<List<Map<String, dynamic>>> _fetchNewsFromFreeAPI(String category) async {
    try {
      final url = Uri.parse('$_freeBaseUrl/latest-news?category=$category&apiKey=$_freeApiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['news'] != null) {
          return List<Map<String, dynamic>>.from(data['news']);
        }
      }
    } catch (e) {
      print('Error fetching from free API: $e');
    }
    return _getSampleNews();
  }

  List<Map<String, dynamic>> _getSampleNews() {
    return [
      {
        'title': 'Latest Technology Trends',
        'description': 'Exploring the latest trends in technology and innovation.',
        'urlToImage': 'https://via.placeholder.com/400x300',
        'url': 'https://example.com/news1',
        'publishedAt': DateTime.now().toIso8601String(),
        'author': 'Tech News',
      },
      {
        'title': 'AI Development Updates',
        'description': 'Recent developments in artificial intelligence and machine learning.',
        'urlToImage': 'https://via.placeholder.com/400x300',
        'url': 'https://example.com/news2',
        'publishedAt': DateTime.now().toIso8601String(),
        'author': 'AI Weekly',
      },
      {
        'title': 'Productivity Tools Review',
        'description': 'A comprehensive review of the best productivity tools available.',
        'urlToImage': 'https://via.placeholder.com/400x300',
        'url': 'https://example.com/news3',
        'publishedAt': DateTime.now().toIso8601String(),
        'author': 'Productivity Magazine',
      },
    ];
  }
}

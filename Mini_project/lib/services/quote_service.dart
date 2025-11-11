import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  // Only using zenquotes.io now
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/today';

  Future<Map<String, dynamic>> fetchQuote() async {
    try {
      final url = Uri.parse(_zenQuotesUrl);
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('ZenQuotes API timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0]['q'] != null) {
          return {
            'content': data[0]['q'],
            'author': data[0]['a'] ?? 'Unknown',
          };
        }
      }
    } catch (e) {
      print('Error fetching quote from zenquotes: $e');
    }
    
    // Return default quote as final fallback
    return _getDefaultQuote();
  }

  Map<String, dynamic> _getDefaultQuote() {
    final quotes = [
      {'content': 'The way to get started is to quit talking and begin doing.', 'author': 'Walt Disney'},
      {'content': 'Productivity is never an accident. It is always the result of a commitment to excellence.', 'author': 'Paul J. Meyer'},
      {'content': 'Focus on being productive instead of busy.', 'author': 'Tim Ferriss'},
      {'content': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain'},
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
}

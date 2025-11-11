import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('API Integration Tests', () {
    test('Fetch news from NewsAPI', () async {
      const String newsUrl =
          'https://newsapi.org/v2/top-headlines?country=in&apiKey=ebb2acc1d5ae402fbb05b39b694a2209';

      final response = await http.get(Uri.parse(newsUrl));
      expect(response.statusCode, 200);

      final data = json.decode(response.body);
      if (data['articles'] != null && data['articles'].isNotEmpty) {
        expect(data['articles'], isA<List>());
      } else {
        print('⚠️ No articles found — check API key or category');
      }
    });

    test('Fetch quote from ZenQuotes API', () async {
      const String quotesUrl = 'https://zenquotes.io/api/random';
      final response = await http.get(Uri.parse(quotesUrl));
      expect(response.statusCode, 200);

      final data = json.decode(response.body);
            expect(data, isA<List>());
            expect(data.first['q'], isNotEmpty);
          });
        });
      }

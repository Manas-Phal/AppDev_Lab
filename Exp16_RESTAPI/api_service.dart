import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/launch_model.dart';

class ApiService {
  final String apiUrl = 'https://api.spacexdata.com/v4/launches';

  Future<List<Launch>> fetchLaunches() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_launches', response.body);

        return data.map((json) => Launch.fromJson(json)).toList();
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Try loading cached data
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_launches');
      if (cached != null) {
        final List data = jsonDecode(cached);
        return data.map((json) => Launch.fromJson(json)).toList();
      } else {
        throw Exception('Network error & no cached data: $e');
      }
    }
  }
}

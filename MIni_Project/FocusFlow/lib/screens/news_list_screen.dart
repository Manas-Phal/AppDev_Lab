import 'package:flutter/material.dart';
import 'news_detail_screen.dart';
import '../services/news_service.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'technology';

  final List<String> _categories = [
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology'
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final articles = await _newsService.fetchNews(category: _selectedCategory);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
        backgroundColor: Colors.deepPurple,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.deepPurple.shade100,
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                  _loadNews();
                }
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadNews,
        child: ListView.builder(
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            final article = _articles[index];
            final imageUrl = article['urlToImage'] ??
                'https://via.placeholder.com/150';
            final title = article['title'] ?? 'No title';
            final description =
                article['description'] ?? 'No description';

            return Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl,
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(article: article),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

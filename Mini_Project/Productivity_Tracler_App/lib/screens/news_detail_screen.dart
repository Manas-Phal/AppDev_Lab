import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final dynamic article;
  const NewsDetailScreen({super.key, required this.article});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()?['role'] == 'admin') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = article['urlToImage'] ?? '';
    final title = article['title'] ?? 'No title';
    final content = article['content'] ?? 'No content available';
    final source = article['source']?['name'] ?? 'Unknown Source';
    final publishedAt = article['publishedAt'] ?? '';
    final url = article['url'] ?? '';

    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(source),
            backgroundColor: Colors.deepPurple,
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Navigate to Add News page
                    Navigator.pushNamed(context, '/addNews');
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl),
                  ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Published at: $publishedAt', style: const TextStyle(color: Colors.grey)),
                const Divider(),
                Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 20),
                if (url.isNotEmpty)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _launchURL(url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Read Full Article'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


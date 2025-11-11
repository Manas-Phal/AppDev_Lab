import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/news_service.dart';
import '../services/quote_service.dart';
import '../services/firebase_functions_service.dart';
import '../widgets/chatbot_widget.dart';
import 'news_list_screen.dart';
import 'news_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Color themeColor;
  final bool isDark;
  final Function(Color) onThemeChange;
  final bool isGuest;
  final String userRole;
  const DashboardScreen({
    super.key,
    required this.themeColor,
    required this.isDark,
    required this.onThemeChange,
    this.isGuest = false,
    required this.userRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  User? currentUser = FirebaseAuth.instance.currentUser;
  int _totalTasks = 0;
  int _completedTasks = 0;

  final NewsService _newsService = NewsService();
  final QuoteService _quoteService = QuoteService();
  final FirebaseFunctionsService _functionsService = FirebaseFunctionsService(); // <-- Added service instance

  List<dynamic> _latestNews = [];
  String _quote = 'Stay focused and productive!';
  String _quoteAuthor = 'Unknown';

  final List<Color> _themeColors = [
    Colors.teal,
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.indigo,
    Colors.orange,
    Colors.green,
    Colors.blue,
  ];

  // Controllers and variables for assign role UI
  final TextEditingController _uidController = TextEditingController();  // <-- Added controller
  String _selectedRole = 'vip';  // <-- Added selected role

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      await Future.wait([
        _loadTaskSummary(),
        _loadNews(),
        _loadQuote(),
      ]);
      _controller.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNews() async {
    try {
      final news = await _newsService.fetchNews(category: 'technology');
      setState(() => _latestNews = news.take(3).toList());
    } catch (e) {
      debugPrint('Error loading news: $e');
    }
  }

  Future<void> _loadQuote() async {
    try {
      final quoteData = await _quoteService.fetchQuote();
      setState(() {
        _quote = quoteData['content'] ?? 'Stay focused and productive!';
        _quoteAuthor = quoteData['author'] ?? 'Unknown';
      });
    } catch (e) {
      debugPrint('Error loading quote: $e');
    }
  }

  Future<void> _loadTaskSummary() async {
    if (currentUser == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('tasks')
          .get();

      final allTasks =
      snapshot.docs.map((e) => Task.fromFirestore(e.data(), e.id)).toList();
      final completed = allTasks.where((t) => t.isDone).length;

      setState(() {
        _totalTasks = allTasks.length;
        _completedTasks = completed;
      });
    } catch (e) {
      debugPrint('⚠️ Error fetching task summary: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _uidController.dispose();  // <-- Dispose added here
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  double _getCompletionPercent() {
    if (_totalTasks == 0) return 0;
    return _completedTasks / _totalTasks;
  }

  // ** New: Assign Role method for calling cloud function **
  Future<void> _assignRole() async {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a user UID')),
      );
      return;
    }
    try {
      final message = await _functionsService.assignUserRole(uid, _selectedRole);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      _uidController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.themeColor;
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: themeColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [themeColor.withOpacity(0.8), Colors.black87]
                : [themeColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeIn,
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👋 Greeting Section
                  _buildGreetingSection(themeColor),

                  const SizedBox(height: 20),

                  // ** New: Assign Role UI shown only to admin roles **
                  if (widget.userRole.startsWith('admin'))
                    _buildAssignRoleSection(themeColor),

                  const SizedBox(height: 20),

                  // 🎯 Task Summary Section
                  _buildTaskSummary(themeColor, isDark),

                  const SizedBox(height: 25),

                  // 💬 Quote Section
                  _buildQuoteCard(themeColor, isDark),

                  const SizedBox(height: 25),

                  // 🎨 Theme Color Picker
                  _buildThemeSelector(themeColor),

                  const SizedBox(height: 25),

                  // 🤖 Chatbot Section (VIP only)
                  if (widget.userRole == 'vip')
                    _buildChatbotSection(themeColor, isDark),

                  const SizedBox(height: 25),

                  // 📰 News Section
                  _buildNewsSection(themeColor, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ** New: Assign Role Widget UI **
  Widget _buildAssignRoleSection(Color themeColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Role (Admin Only)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(
                labelText: 'Enter User UID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRole,
              items: [
                'guest',
                'user',
                'vip',
                'admin_student',
                'admin_professor'
              ]
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRole = val;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _assignRole,
              child: Text('Assign Role'),
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            ),
          ],
        ),
      ),
    );
  }

  // Your original existing widget builders remain unchanged below...

  Widget _buildGreetingSection(Color themeColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: themeColor.withOpacity(0.3),
          child: const Icon(Icons.person, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_getGreeting()},",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              currentUser?.displayName ?? "FocusFlow User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskSummary(Color themeColor, bool isDark) {
    final progress = _getCompletionPercent();

    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today’s Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: themeColor,
              backgroundColor: themeColor.withOpacity(0.2),
            ),
            const SizedBox(height: 10),
            Text(
              'Completed $_completedTasks / $_totalTasks tasks',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Color themeColor, bool isDark) {
    return Card(
      color: themeColor.withOpacity(0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '"$_quote"',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : themeColor.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "- $_quoteAuthor",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Theme Color',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _themeColors.length,
            itemBuilder: (context, index) {
              final color = _themeColors[index];
              return GestureDetector(
                onTap: () => widget.onThemeChange(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == themeColor
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsSection(Color themeColor, bool isDark) {
    if (_latestNews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Tech News',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewsListScreen()),
                );
              },
              child: Text('See All', style: TextStyle(color: themeColor)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: _latestNews.map((article) {
            final imageUrl = article['urlToImage'] ?? '';
            final title = article['title'] ?? 'No title';
            final desc = article['description'] ?? 'No description';

            return Card(
              color: isDark
                  ? Colors.grey.shade900
                  : Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                      width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  desc,
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
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChatbotSection(Color themeColor, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: themeColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: const ChatbotWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  get shade700 => null;
}

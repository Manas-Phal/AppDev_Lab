import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;
  final Color themeColor;
  final bool isDark;

  const HistoryScreen({
    Key? key,
    required this.userId,
    this.themeColor = Colors.teal,
    this.isDark = false,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryService _historyService;
  List<Map<String, dynamic>> _historyItems = [];
  bool _loading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Added', 'Updated', 'Deleted', 'Completed', 'Searched'];

  @override
  void initState() {
    super.initState();
    _historyService = HistoryService(widget.userId);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final items = await _historyService.getHistory();
      setState(() {
        _historyItems = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'All') {
      return _historyItems;
    }
    final actionMap = {
      'Added': 'taskAdded',
      'Updated': 'taskUpdated',
      'Deleted': 'taskDeleted',
      'Completed': 'taskCompleted',
      'Searched': 'taskSearched',
    };
    final action = actionMap[_selectedFilter];
    return _historyItems.where((item) => item['action'] == action).toList();
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'taskAdded':
        return Icons.add_circle;
      case 'taskUpdated':
        return Icons.edit;
      case 'taskDeleted':
        return Icons.delete;
      case 'taskCompleted':
        return Icons.check_circle;
      case 'taskSearched':
        return Icons.search;
      case 'pomodoroStarted':
        return Icons.timer;
      case 'pomodoroCompleted':
        return Icons.timer_off;
      default:
        return Icons.history;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'taskAdded':
        return Colors.green;
      case 'taskUpdated':
        return Colors.blue;
      case 'taskDeleted':
        return Colors.red;
      case 'taskCompleted':
        return Colors.teal;
      case 'taskSearched':
        return Colors.orange;
      case 'pomodoroStarted':
        return Colors.purple;
      case 'pomodoroCompleted':
        return Colors.purpleAccent;
      default:
        return widget.themeColor;
    }
  }

  String _getActionText(String action) {
    switch (action) {
      case 'taskAdded':
        return 'Task Added';
      case 'taskUpdated':
        return 'Task Updated';
      case 'taskDeleted':
        return 'Task Deleted';
      case 'taskCompleted':
        return 'Task Completed';
      case 'taskSearched':
        return 'Task Searched';
      case 'pomodoroStarted':
        return 'Pomodoro Started';
      case 'pomodoroCompleted':
        return 'Pomodoro Completed';
      default:
        return action;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Unknown time';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: widget.themeColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Clear History'),
                onTap: () async {
                  await _historyService.clearHistory();
                  _loadHistory();
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: widget.themeColor.withOpacity(0.3),
                    checkmarkColor: widget.themeColor,
                  ),
                );
              },
            ),
          ),
          // History list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: widget.isDark ? Colors.white38 : Colors.black38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No history yet',
                              style: TextStyle(
                                color: widget.isDark ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredHistory.length,
                          itemBuilder: (context, index) {
                            final item = _filteredHistory[index];
                            final action = item['action'] ?? 'unknown';
                            final taskTitle = item['taskTitle'] ?? 'Unknown Task';
                            final timestamp = item['timestamp'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getActionColor(action).withOpacity(0.2),
                                  child: Icon(
                                    _getActionIcon(action),
                                    color: _getActionColor(action),
                                  ),
                                ),
                                title: Text(
                                  _getActionText(action),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      taskTitle,
                                      style: TextStyle(
                                        color: widget.isDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        color: widget.isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: widget.isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

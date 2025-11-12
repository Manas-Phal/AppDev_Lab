import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';
import '../services/role_access.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Task> tasks;
  final Color themeColor;
  final bool isDark;
  final String role; // ✅ Added role

  const AnalyticsScreen({
    Key? key,
    required this.tasks,
    required this.themeColor,
    required this.isDark,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔒 Restrict guest users entirely
    if (RoleAccess.isGuest(role)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Access Restricted for Guests",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate stats
    final completed = tasks.where((t) => t.isDone).length;
    final total = tasks.length;
    final ongoing = total - completed;
    final percent = total == 0 ? 0.0 : (completed / total);

    // Line chart dummy trend data
    final completionTrend = [
      FlSpot(0, 50),
      FlSpot(1, 70),
      FlSpot(2, percent * 100),
    ];

    final pomodoroTrend = [
      FlSpot(0, 1),
      FlSpot(1, 3),
      FlSpot(2, 2),
    ];

    // 🔒 Limit access for basic users (restricted chart view) - Only VIP can access
    if (!RoleAccess.isVIP(role)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          backgroundColor: themeColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                "Analytics Access Restricted",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This feature is available only for VIP users.\nUpgrade to VIP in your Profile to unlock analytics.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to profile tab (index 4)
                  // This will be handled by parent
                },
                icon: const Icon(Icons.person),
                label: const Text('Go to Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Full analytics for VIP, Student, Professor
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Analysis & Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Enlarged stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bigStatCard('Total', total.toString(), themeColor, isDark),
                _bigStatCard(
                    'Ongoing', ongoing.toString(), Colors.orange, isDark),
                _bigStatCard(
                    'Completed', completed.toString(), Colors.green, isDark),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Circle Center
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 14.0,
                          color: themeColor.withOpacity(0.95),
                          backgroundColor: themeColor.withOpacity(0.18),
                        ),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tasks completed: $completed / $total',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid: Line charts
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _lineChartCard('Completion Rate Trend (%)', completionTrend,
                    themeColor, isDark),
                _lineChartCard('Pomodoro Sessions Trend', pomodoroTrend,
                    Colors.redAccent, isDark),
              ],
            ),

            const SizedBox(height: 12),

            // Summary Section
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _summaryCard('Weekly Summary',
                        '$completed Tasks Completed\n${total} Total Tasks', themeColor, isDark)),
                const SizedBox(width: 10),
                Expanded(
                    child: _summaryCard(
                        'Productivity Level', 
                        percent > 0.7 ? 'Excellent' : percent > 0.4 ? 'Good' : 'Needs Improvement', 
                        themeColor, isDark)),
              ],
            ),
            const SizedBox(height: 12),
            _summaryCard(
              'Overall Progress',
              'You have completed ${(percent * 100).toStringAsFixed(1)}% of your tasks. Keep up the great work!',
              themeColor,
              isDark,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _bigStatCard(String title, String value, Color c, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: dark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineChartCard(
      String title, List<FlSpot> spots, Color c, bool dark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12, color: dark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: spots,
                    color: c,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: c.withOpacity(0.12),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String subtitle, Color c, bool dark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12, color: dark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: c)),
        ],
      ),
    );
  }
}










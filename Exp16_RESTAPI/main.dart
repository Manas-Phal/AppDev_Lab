import 'package:flutter/material.dart';
import 'models/launch_model.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SpaceXApp());
}

class SpaceXApp extends StatelessWidget {
  const SpaceXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpaceX Launch Tracker',
      theme: ThemeData.dark(useMaterial3: true),
      home: const LaunchListScreen(),
    );
  }
}

class LaunchListScreen extends StatefulWidget {
  const LaunchListScreen({super.key});

  @override
  State<LaunchListScreen> createState() => _LaunchListScreenState();
}

class _LaunchListScreenState extends State<LaunchListScreen> {
  late Future<List<Launch>> futureLaunches;
  List<Launch> allLaunches = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureLaunches = ApiService().fetchLaunches();
  }

  void _retry() {
    setState(() {
      futureLaunches = ApiService().fetchLaunches();
    });
  }

  List<Launch> _filterLaunches() {
    if (searchQuery.isEmpty) return allLaunches;
    return allLaunches
        .where((l) => l.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 SpaceX Launch Tracker'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Search Launches'),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _retry(),
              child: FutureBuilder<List<Launch>>(
                future: futureLaunches,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 60),
                          const SizedBox(height: 10),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _retry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No launches found.'));
                  }

                  allLaunches = snapshot.data!;
                  final filteredLaunches = _filterLaunches();

                  if (filteredLaunches.isEmpty) {
                    return const Center(child: Text('No launches match search.'));
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredLaunches.length,
                    itemBuilder: (context, index) {
                      final launch = filteredLaunches[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: launch.imageUrl != null
                              ? Image.network(
                                  launch.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.rocket_launch),
                                )
                              : const Icon(Icons.rocket_launch,
                                  color: Colors.white),
                          title: Text(
                            launch.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Date: ${launch.dateUtc.toLocal().toString()}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        LaunchDetailScreen(launch: launch)));
                          },
                        ),
                      );
                    },
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

// ----------------- Launch Detail Page -----------------

class LaunchDetailScreen extends StatelessWidget {
  final Launch launch;

  const LaunchDetailScreen({super.key, required this.launch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(launch.name),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            launch.imageUrl != null
                ? Image.network(
                    launch.imageUrl!,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.rocket_launch, size: 100),
                  )
                : const Icon(Icons.rocket_launch, size: 100),
            const SizedBox(height: 16),
            Text(
              launch.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Launch Date: ${launch.dateUtc.toLocal()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Details not available via this API, but you can extend this page to include rocket info, launchpad, or links.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

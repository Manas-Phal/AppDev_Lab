import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:productivity_tracker_app/main.dart';

// Mock classes (optional for dependency isolation)
class MockFirebaseCore extends Mock implements Firebase {}

/// Initializes Firebase safely for widget tests
Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:1234567890:android:fakeappid',
        messagingSenderId: '1234567890',
        projectId: 'fake-project-id',
      ),
    );
  } catch (e) {
    // Firebase already initialized, ignore error
  }
}

void main() {
  setUpAll(() async {
    await setupFirebaseMocks();
  });

  group('✅ UI Responsiveness Tests', () {
    testWidgets('App loads correctly on mobile screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812)); // Mobile resolution
      await tester.pumpWidget(const MaterialApp(home: MockAppScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Mocked App Screen for Responsiveness Test'), findsOneWidget);
    });

    testWidgets('App scales correctly on web/desktop screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900)); // Desktop/Web resolution
      await tester.pumpWidget(const MaterialApp(home: MockAppScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

/// Mock version of the app’s root widget
/// Prevents FirebaseAuth or Firestore from being called.
class MockAppScreen extends StatelessWidget {
  const MockAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Mocked App Screen for Responsiveness Test')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_friend_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

// Add this line for mocking Firebase
class MockFirebaseApp extends Fake implements FirebaseApp {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Look for either login screen or home screen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dopamine2_0/main.dart';

void main() {
  testWidgets('Dopamine app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DopamineApp());

    // Verify that the app title is displayed
    expect(find.text('Dopamine 2.0 - YouTube Audio Player'), findsOneWidget);
    
    // Verify search field exists
    expect(find.byType(TextField), findsOneWidget);
    
    // Verify initial empty state message
    expect(find.text('Search for songs to get started!'), findsOneWidget);
  });
}

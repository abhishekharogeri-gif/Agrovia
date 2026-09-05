import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/app.dart';

void main() {
  testWidgets('Agrovia app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroviaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

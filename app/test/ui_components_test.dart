import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrovia/widgets/glass_container.dart';
import 'package:agrovia/theme/agrovia_theme.dart';
import 'package:agrovia/screens/market/market_screen.dart';
import 'package:agrovia/screens/yojana_hub/yojana_hub_screen.dart';
import 'package:agrovia/screens/connect/connect_screen.dart';

void main() {
  group('GlassContainer Widget Tests', () {
    testWidgets('renders child and applies dark glass properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgroviaTheme.darkTheme,
          home: const Scaffold(
            body: GlassContainer(
              child: Text('Test Glass Container'),
            ),
          ),
        ),
      );

      expect(find.text('Test Glass Container'), findsOneWidget);
      expect(find.byType(GlassContainer), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('renders child in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgroviaTheme.lightTheme,
          home: const Scaffold(
            body: GlassContainer(
              child: Text('Light Glass Container'),
            ),
          ),
        ),
      );

      expect(find.text('Light Glass Container'), findsOneWidget);
      expect(find.byType(GlassContainer), findsOneWidget);
    });
  });

  group('MarketScreen UI Tests', () {
    testWidgets('renders search bar and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgroviaTheme.darkTheme,
          home: const MarketScreen(),
        ),
      );

      // Verify title and chips
      expect(find.text('Mandi Spot Rates'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Soybean'), findsOneWidget);
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('YojanaHubScreen UI Tests', () {
    testWidgets('renders eligibility check card and recommended schemes header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgroviaTheme.darkTheme,
          home: const YojanaHubScreen(),
        ),
      );

      expect(find.text('Yojana Hub'), findsOneWidget);
      expect(find.text('Check Eligibility'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });
  });

  group('ConnectScreen UI Tests', () {
    testWidgets('renders community feed and farmer card banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgroviaTheme.darkTheme,
          home: const ConnectScreen(),
        ),
      );

      expect(find.text('Kisan Connect'), findsOneWidget);
      expect(find.text('Share Your Farmer Card'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

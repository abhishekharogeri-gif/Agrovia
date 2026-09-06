import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/agrovia_theme.dart';
import 'widgets/bottom_nav_bar.dart';

import 'screens/auth/phone_login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/connect/connect_screen.dart';
import 'screens/vision_x/vision_x_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/yojana_hub/yojana_hub_screen.dart';
import 'screens/saanvi/saanvi_bottom_sheet.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: PhoneLoginScreen()),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/connect',
          pageBuilder: (context, state) => const NoTransitionPage(child: ConnectScreen()),
        ),
        GoRoute(
          path: '/vision-x',
          pageBuilder: (context, state) => const NoTransitionPage(child: VisionXScreen()),
        ),
        GoRoute(
          path: '/market',
          pageBuilder: (context, state) => const NoTransitionPage(child: MarketScreen()),
        ),
        GoRoute(
          path: '/yojana-hub',
          pageBuilder: (context, state) => const NoTransitionPage(child: YojanaHubScreen()),
        ),
      ],
    ),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/connect')) return 1;
    if (location.startsWith('/vision-x')) return 2;
    if (location.startsWith('/market')) return 3;
    if (location.startsWith('/yojana-hub')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: AgroviaColors.primaryDark,
        onPressed: () => SaanviBottomSheet.show(context),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      bottomNavigationBar: AgroviaBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/connect');
              break;
            case 2:
              context.go('/vision-x');
              break;
            case 3:
              context.go('/market');
              break;
            case 4:
              context.go('/yojana-hub');
              break;
          }
        },
      ),
    );
  }
}

class AgroviaApp extends StatelessWidget {
  const AgroviaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agrovia',
      debugShowCheckedModeBanner: false,
      theme: AgroviaTheme.lightTheme,
      darkTheme: AgroviaTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

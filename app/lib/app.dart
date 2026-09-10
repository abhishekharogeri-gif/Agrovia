import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/agrovia_theme.dart';
import 'widgets/bottom_nav_bar.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/onboarding/personal_details_screen.dart';
import 'screens/onboarding/permissions_onboarding_screen.dart';

import 'screens/home/home_screen.dart';
import 'screens/connect/connect_screen.dart';
import 'screens/vision_x/vision_x_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/yojana_hub/yojana_hub_screen.dart';
import 'screens/saanvi/saanvi_bottom_sheet.dart';
import 'screens/profile/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/onboarding/details',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: PersonalDetailsScreen()),
    ),
    GoRoute(
      path: '/onboarding/permissions',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(child: PermissionsOnboardingScreen()),
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
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
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
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        mini: false, // Changed to default size for the character icon
        backgroundColor: Colors.transparent, // Background transparent
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () => SaanviBottomSheet.show(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AgroviaColors.primaryLight, AgroviaColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AgroviaColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/icons/saanvi.png', fit: BoxFit.contain),
          ),
        ),
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
            case 5:
              context.go('/profile');
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
      theme: AgroviaTheme.darkTheme, // Force dark theme for glassmorphism
      darkTheme: AgroviaTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agrovia', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () async {
              // added logout logic directly to this button for testing
              await FirebaseAuth.instance.signOut();
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'jwt_token');
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Weather & Advisory Glass Card
          GlassContainer(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Indore, MP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '28°C • Clear Sky',
                      style: TextStyle(color: AgroviaColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AgroviaColors.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Good Spray Window: 4 PM',
                        style: TextStyle(fontSize: 12, color: AgroviaColors.accentGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.wb_sunny_rounded, size: 48, color: Colors.orangeAccent),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Farm & Crops Overview
          const Text('Your Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: const [
                      Icon(Icons.grass_rounded, color: AgroviaColors.primaryDark, size: 32),
                      SizedBox(height: 8),
                      Text('Soybean', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('4.5 Acres • Vegetative', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: const [
                      Icon(Icons.eco_rounded, color: AgroviaColors.accentGreen, size: 32),
                      SizedBox(height: 8),
                      Text('Wheat', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('2.0 Acres • Sowing', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Mandi Price Highlight
          const Text('Market Spot Rates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GlassContainer(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AgroviaColors.primaryLight,
                child: Icon(Icons.trending_up, color: AgroviaColors.primaryDark),
              ),
              title: const Text('Soybean (Yellow)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Indore Mandi • 12km away'),
              trailing: const Text('₹4,850/q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.accentGreen)),
            ),
          ),
        ],
      ),
    );
  }
}

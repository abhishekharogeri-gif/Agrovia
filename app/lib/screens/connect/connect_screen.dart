import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kisan Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              // Open QR scan sheet
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // QR Exchange Banner
          GlassContainer(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AgroviaColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 36, color: AgroviaColors.primaryDark),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Share Your Farmer Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Connect with local farmers & verified experts instantly.', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Nearby Farmers & Groups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          _buildUserTile('Ramesh Patel', 'Indore • Soybean Specialist', true),
          _buildUserTile('Suresh Sharma', 'Dewas • Organic Wheat', false),
          _buildUserTile('Dr. Alok Verma', 'KVK Agronomist (Verified)', true, isExpert: true),
        ],
      ),
    );
  }

  Widget _buildUserTile(String name, String subtitle, bool isOnline, {bool isExpert = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: isExpert ? AgroviaColors.accentGreen : AgroviaColors.primaryDark,
                child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AgroviaColors.accentGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
          trailing: IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AgroviaColors.primaryDark),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

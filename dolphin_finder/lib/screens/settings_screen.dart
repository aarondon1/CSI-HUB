import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/signin_screen.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';

import '../supabase/supabase_client.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color appBlue = Color(0xFF4A90E2);

  Future<void> _logout(BuildContext context) async {
    await SupabaseManager.client.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have been logged out.")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
        bottomNavigationBar: const CustomNavButton(currentIndex: 4),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

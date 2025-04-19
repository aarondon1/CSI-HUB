// widgets/custom_bottom_nav.dart
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';


class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Color(0xFF4A90E2),
      unselectedItemColor: Color(0xFF4A90E2),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        if (index == currentIndex) return; // avoid reload
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 14,
            backgroundImage: AssetImage('assets/user.png'),
          ),
          label: '',
        ),
      ],
    );
  }
}

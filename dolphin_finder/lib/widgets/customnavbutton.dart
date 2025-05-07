import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';
import 'package:dolphin_finder/screens/notificationcenterscreen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/supabase/supabase_client.dart';

class CustomNavButton extends StatefulWidget {
  final int currentIndex;

  const CustomNavButton({super.key, required this.currentIndex});

  @override
  State<CustomNavButton> createState() => _CustomNavButtonState();
}

class _CustomNavButtonState extends State<CustomNavButton> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userId = SupabaseManager.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await SupabaseManager.client
          .from('users_profile')
          .select('profile_picture')
          .eq('id', userId)
          .single();

      if (mounted && response != null) {
        setState(() {
          profileImageUrl = response['profile_picture'];
        });
      }
    } catch (e) {
      // Handle error silently
      print('Error loading profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        if (index == widget.currentIndex) return;
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationCenterScreen()));
        } else if (index == 3) {
          final userId = SupabaseManager.client.auth.currentUser?.id ?? '';
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        const BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
        const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 14,
            backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/user.png') as ImageProvider,
          ),
          label: '',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
      ],
    );
  }
}





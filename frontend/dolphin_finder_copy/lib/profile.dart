import 'package:flutter/material.dart';
import 'package:dolphin_finder/home.dart';
import 'package:dolphin_finder/newprojectpage.dart';
import 'package:dolphin_finder/settings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color appBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            // Profile Image
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/user.png'), // your image
            ),
            const SizedBox(height: 16),

            // Name
            const Text(
              "Daniel",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Info Cards
            buildInfoCard(
              title: "Email Address",
              content: "nickfrost@gmail.com",
              onEdit: () {},
            ),
            buildInfoCard(
              title: "Phone Number",
              content: "123-456-7891",
              onEdit: () {},
            ),
            buildInfoCard(
              title: "Instagram",
              content: "https://www.instagram.com/CSI",
              isLink: true,
              onEdit: () {},
            ),
          ],
        ),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: appBlue,
        unselectedItemColor: appBlue,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewProjectPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assets/user.png'),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String content,
    required VoidCallback onEdit,
    bool isLink = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: appBlue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLink ? Colors.blue : Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Edit icon
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
        ],
      ),
    );
  }
}

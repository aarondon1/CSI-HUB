import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color appBlue = Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/user.png'),
            ),
            const SizedBox(height: 16),
            const Text("Daniel", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            buildInfoCard(
              title: "Email Address",
              content: "nickfrost@gmail.com",
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Email clicked")),
                );
              },
            ),
            buildInfoCard(
              title: "Phone Number",
              content: "123-456-7891",
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Phone clicked")),
                );
              },
            ),
            buildInfoCard(
              title: "Instagram",
              content: "https://www.instagram.com/CSI",
              isLink: true,
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Instagram clicked")),
                );
              },
            ),
          ],
        ),
      ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

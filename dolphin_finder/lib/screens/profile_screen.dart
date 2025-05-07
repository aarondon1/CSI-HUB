import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';

import '../supabase/supabase_client.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await SupabaseManager.client
          .from('users_profile')
          .select()
          .eq('id', widget.userId)
          .single();

      setState(() {
        _profileData = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );

              // Refresh profile data if edit was successful
              if (result == true) {
                _loadProfile();
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileData?['profile_picture'] != null && _profileData!['profile_picture'].isNotEmpty
                  ? NetworkImage(_profileData!['profile_picture'])
                  : const AssetImage('assets/user.png') as ImageProvider,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            Text(
              _profileData?['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            buildInfoCard("Email Address", _profileData?['email'] ?? 'N/A'),
            buildInfoCard("Instagram", _profileData?['instagram'] ?? 'N/A', isLink: true),
            buildInfoCard("GitHub", _profileData?['github'] ?? 'N/A', isLink: true),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavButton(currentIndex: 3),
    );
  }

  Widget buildInfoCard(String title, String content, {bool isLink = false}) {
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
        ],
      ),
    );
  }
}
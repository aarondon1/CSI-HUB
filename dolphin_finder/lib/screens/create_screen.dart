import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';
import '../supabase/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/homescreen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';
import '../supabase/supabase_client.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreen();
}

class _CreateScreen extends State<CreateScreen> {
  static const Color appBlue = Color(0xFF4A90E2);
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> roles = ["UI/UX Designer", "Frontend Dev", "Backend Dev", "ML Engineer", "Project Manager", "Other"];
  final Set<String> selectedRoles = {};

  void _postProject() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final userId = SupabaseManager.client.auth.currentUser?.id;

    if (title.isEmpty || description.isEmpty || selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields and select at least one role.")),
      );
      return;
    }

    try {
      await SupabaseManager.client.from('posts').insert({
        'title': title,
        'description': description,
        'roles_needed': selectedRoles.toList(),
        'created_by': userId,
      });

      titleController.clear();
      descriptionController.clear();
      setState(() {
        selectedRoles.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project posted successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error posting project: $e")),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("New Project", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Project Title", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter your project title',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Project Description", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Describe what the project is about and who you’re looking for',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Looking for...", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: roles.map((role) {
                final isSelected = selectedRoles.contains(role);
                return ChoiceChip(
                  label: Text(role),
                  selected: isSelected,
                  selectedColor: appBlue,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedRoles.add(role);
                      } else {
                        selectedRoles.remove(role);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _postProject,
                icon: const Icon(Icons.check_circle),
                label: const Text("Post Project"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavButton(currentIndex: 1),
    );
  }
}




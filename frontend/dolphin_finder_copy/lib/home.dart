import 'package:flutter/material.dart';
import 'package:dolphin_finder/newprojectpage.dart';
import 'package:dolphin_finder/settings.dart';
import 'package:dolphin_finder/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> filters = ['Python', 'C++', 'HTML', 'Java', 'Other'];
  final Set<String> selectedFilters = {};
  static const Color appBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: appBlue,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.menu, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SEARCH',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  Wrap(
                    spacing: 8,
                    children:
                        filters.map((filter) {
                          final isSelected = selectedFilters.contains(filter);
                          return ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedFilters.add(filter);
                                } else {
                                  selectedFilters.remove(filter);
                                }
                              });
                            },
                            selectedColor: appBlue.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? appBlue : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color:
                                    isSelected ? appBlue : Colors.grey.shade400,
                              ),
                            ),
                            backgroundColor: Colors.white,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  buildPost(
                    username: "Daniel",
                    time: "2 hrs ago",
                    description:
                        "Looking for need building a habit tracker app w/ AI...",
                    likes: 6,
                  ),
                  const SizedBox(height: 20),
                  buildPost(
                    username: "Emily",
                    time: "1 hr ago",
                    description:
                        "I am building a social study app w/ real-time collab...",
                    likes: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: appBlue,
        unselectedItemColor: appBlue,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewProjectPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
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

  Widget buildPost({
    required String username,
    required String time,
    required String description,
    required int likes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/user.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.more_horiz, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(height: 10),
        Text(description),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: appBlue,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            "Ask To Join",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 20),
            const SizedBox(width: 6),
            Text("$likes likes"),
          ],
        ),
      ],
    );
  }
}

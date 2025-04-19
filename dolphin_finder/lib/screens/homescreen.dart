import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/settings_screen.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/screens/create_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> filters = ['Python', 'C++', 'HTML', 'Java', 'Other'];
  final Set<String> selectedFilters = {};
  static const Color appBlue = Color(0xFF4A90E2);

  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Daniel',
      'time': '2 hrs ago',
      'description': 'Looking for need building a habit tracker app w/ AI, using firebase + python. Looking for: ML engineer 🧠, someone good w/ UI/UX design 🎨 i’m chill, just wanna build something cool over the next couple months\nhmu if you’re down!\nDiscord @danielgoodboy',
      'likes': 6,
      'liked': false,
    },
    {
      'username': 'Emily',
      'time': '1 hr ago',
      'description': 'I am building a social study app w/ real-time collab features, using React + Firebase + python.\nLooking for: frontend dev (React) 💻 and a project manager.\nDiscord @emilyxoxo49\nEmail: emilyvegas2323@gmail.com',
      'likes': 15,
      'liked': false,
    },
  ];

  void toggleLike(int index) {
    setState(() {
      final liked = posts[index]['liked'] ?? false;
      posts[index]['liked'] = !liked;
      posts[index]['likes'] += liked ? -1 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: appBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilters.contains(filter);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
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
                      selectedColor: appBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final query = searchController.text.toLowerCase();
                  if (query.isNotEmpty && !post['description'].toLowerCase().contains(query)) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
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
                                  post['username'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  post['time'],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(Icons.more_horiz, color: Colors.grey[600]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post['description']),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request sent!")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Ask To Join"),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => toggleLike(index),
                          child: Row(
                            children: [
                              Icon(
                                (post['liked'] ?? false) ? Icons.favorite : Icons.favorite_border,
                                color: (post['liked'] ?? false) ? Colors.red : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text("${post['likes']} likes"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}

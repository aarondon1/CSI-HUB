import 'package:flutter/material.dart';
import 'package:dolphin_finder/screens/profile_screen.dart';
import 'package:dolphin_finder/widgets/customnavbutton.dart';
import '../supabase/supabase_client.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  List<Map<String, dynamic>> posts = [];
  Map<String, Map<String, dynamic>> userProfiles = {};
  bool isLoading = true;
  StreamSubscription? likesSubscription;
  StreamSubscription? notificationsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    likesSubscription?.cancel();
    notificationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await fetchPosts();
    subscribeToLikes();
    subscribeToNotifications();
  }

  void subscribeToLikes() {
    final userId = SupabaseManager.client.auth.currentUser?.id;
    if (userId == null) return;

    likesSubscription = SupabaseManager.client
        .from('likes')
        .stream(primaryKey: ['id'])
        .listen((event) {
      fetchPosts();
    }, onError: (error) {
      print('Error in likes subscription: $error');
    });
  }

  void subscribeToNotifications() {
    final userId = SupabaseManager.client.auth.currentUser?.id;
    if (userId == null) return;

    notificationsSubscription = SupabaseManager.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('to_user', userId)
        .listen((event) {
      print("🔔 New notification received!");
    }, onError: (error) {
      print('Error in notifications subscription: $error');
    });
  }

  Future<void> fetchPosts() async {
    try {
      setState(() => isLoading = true);
      final userId = SupabaseManager.client.auth.currentUser?.id;

      final postsResponse = await SupabaseManager.client
          .from('posts')
          .select('*, likes(count), join_requests(count)')
          .order('created_at', ascending: false);

      final usersResponse = await SupabaseManager.client
          .from('users_profile')
          .select('id, name, profile_picture');

      Set<dynamic> likedPostIds = {};

      if (userId != null) {
        final likesResponse = await SupabaseManager.client
            .from('likes')
            .select('post_id')
            .eq('user_id', userId);

        likedPostIds = likesResponse.map((like) => like['post_id']).toSet();
      }

      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in usersResponse) {
        profileMap[profile['id']] = {
          'name': profile['name'] ?? 'Unknown',
          'avatar': profile['profile_picture'],
        };
      }

      setState(() {
        posts = postsResponse.map((post) {
          post['liked'] = likedPostIds.contains(post['id']);
          post['likes'] = post['likes']?.isNotEmpty == true ? post['likes'][0]['count'] : 0;
          post['join_requests'] = post['join_requests']?.isNotEmpty == true ? post['join_requests'][0]['count'] : 0;
          return Map<String, dynamic>.from(post);
        }).toList();
        userProfiles = profileMap;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts or user profiles: $e');
      setState(() => isLoading = false);
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  Future<void> toggleLike(int index) async {
    final userId = SupabaseManager.client.auth.currentUser?.id;
    if (userId == null) return;

    final postId = posts[index]['id'];
    final postOwnerId = posts[index]['created_by'];
    final liked = posts[index]['liked'] ?? false;

    setState(() {

      posts[index]['liked'] = !liked;
      posts[index]['likes'] = (posts[index]['likes'] ?? 0) + (liked ? -1 : 1);
    });

    try {
      if (liked) {
        await SupabaseManager.client
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);
      } else {
        await SupabaseManager.client.from('likes').insert({
          'user_id': userId,
          'post_id': postId,
        });

        if (userId != postOwnerId) {
          await SupabaseManager.client.from('notifications').insert({
            'type': 'like',
            'from_user': userId,
            'to_user': postOwnerId,
            'post_id': postId,
          });
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      setState(() {
        posts[index]['liked'] = liked;
        posts[index]['likes'] = (posts[index]['likes'] ?? 0) + (liked ? 1 : -1);
      });
    }
  }

  void viewUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
  }

  Widget buildAvatar(String userId) {
    final profile = userProfiles[userId];
    final avatarUrl = profile?['avatar'];

    return CircleAvatar(
      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? NetworkImage(avatarUrl)
          : const AssetImage('assets/user.png') as ImageProvider,
      radius: 20,
    );
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
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => setState(() {})),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final createdBy = post['created_by'];
                  final userName = userProfiles[createdBy]?['name'] ?? 'Unknown';
                  final postTime = DateTime.tryParse(post['created_at'] ?? '') ?? DateTime.now();

                  final query = searchController.text.toLowerCase();
                  final matchesSearch = query.isEmpty ||
                      (post['description']?.toString().toLowerCase().contains(query) ?? false);

                  final roles = List<String>.from(post['roles_needed'] ?? []);
                  final matchesFilter = selectedFilters.isEmpty ||
                      roles.any((r) => selectedFilters.contains(r));

                  if (!matchesSearch || !matchesFilter) return const SizedBox.shrink();

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
                            buildAvatar(createdBy),

                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => viewUserProfile(createdBy),
                                  child: Text(
                                    userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  timeAgo(postTime),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(Icons.more_horiz, color: Colors.grey[600]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(post['description'] ?? 'No Description'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: roles.map((role) => Chip(label: Text(role))).toList(),
                        ),
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
                                (post['liked'] ?? false)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: (post['liked'] ?? false)
                                    ? Colors.red
                                    : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text("${post['likes'] ?? 0} likes"),
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
      bottomNavigationBar: const CustomNavButton(currentIndex: 0),
    );
  }
}

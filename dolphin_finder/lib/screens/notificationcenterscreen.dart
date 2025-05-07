import 'package:flutter/material.dart';
import 'package:dolphin_finder/supabase/supabase_client.dart';
import 'package:intl/intl.dart';

import '../widgets/customnavbutton.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final userId = SupabaseManager.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await SupabaseManager.client
          .from('notifications')
          .select('*')
          .eq('to_user', userId)
          .order('created_at', ascending: false);

      // Fetch sender names
      List<Map<String, dynamic>> enrichedNotifications = [];

      for (var notification in response) {
        final senderId = notification['from_user'];
        final userProfile = await SupabaseManager.client
            .from('users_profile')
            .select('name')
            .eq('id', senderId)
            .single();

        notification['sender_name'] = userProfile['name'] ?? 'Someone';
        enrichedNotifications.add(notification);
      }

      setState(() {
        notifications = enrichedNotifications;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  String formatTimestamp(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';
    return DateFormat.yMMMd().add_jm().format(date);
  }

  Widget buildNotificationItem(Map<String, dynamic> notification) {
    final type = notification['type'] ?? '';
    final fromUser = notification['sender_name'] ?? 'Someone';

    final postId = notification['post_id'] ?? '';
    String message;

    if (type == 'like') {
      message = "$fromUser liked your post";
    } else if (type == 'request') {
      message = "$fromUser requested to join your post";
    } else {
      message = "$fromUser did something";
    }

    return ListTile(
      leading: Icon(
        type == 'like' ? Icons.favorite : Icons.person_add,
        color: type == 'like' ? Colors.red : Colors.blue,
      ),
      title: Text(message),
      subtitle: Text(formatTimestamp(notification['created_at'] ?? '')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("No notifications found"))
          : ListView.builder(

        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return buildNotificationItem(notifications[index]);
        },
      ),
        bottomNavigationBar: const CustomNavButton(currentIndex: 2)
    );
  }
}

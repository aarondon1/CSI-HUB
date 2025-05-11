import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// Supabase client
final supabase = Supabase.instance.client;

// Use dotenv to get API URL from environment variables
final String apiBaseUrl =
    dotenv.env['API_URL'] ?? (kDebugMode ? 'http://10.0.2.2:8000' : '');

// API Endpoints
class ApiEndpoints {
  // Profile endpoints
  static const String createProfile = '/create-profile/';
  static const String getProfile = '/profile/'; // + user_id
  static const String updateProfile = '/profile/'; // + user_id
  static const String getCurrentUser = '/me/';

  // Project endpoints
  static const String createProject = '/create-project/';
  static const String projectDetail = '/projects/'; // + project_id
  static const String userProjects = '/user-projects/'; // + user_id
  static const String homepage = '/homepage/';

  // Join request endpoints
  static const String createJoinRequest = '/join-request/';
  static const String updateJoinRequestStatus =
      '/join-request/'; // + request_id + /status/
  static const String receivedJoinRequests = '/join-request/user/'; // + user_id
  static const String sentJoinRequests = '/join-request/sent/';
}

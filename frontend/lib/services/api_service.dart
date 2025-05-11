// TODO: Before production release:
// 1. Remove all debug logging
// 2. Remove debugAuthentication method
// 3. Ensure no tokens or sensitive data are logged
// 4. Set ENABLE_DEBUG_LOGGING to false

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/utils/constants.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/models/project.dart';
import 'package:frontend/models/join_request.dart';
import 'package:frontend/utils/error_handler.dart';
import 'package:flutter/foundation.dart';

// Global debug flag - set to false before production or demo
const bool ENABLE_DEBUG_LOGGING = true;

class ApiService {
  // Safe logging function
  void safeLog(String message) {
    if (kDebugMode && ENABLE_DEBUG_LOGGING) {
      print(message);
    }
  }

  // Get auth token from Supabase
  Future<String?> _getAuthToken() async {
    try {
      // Get the current session without forcing a refresh
      final session = supabase.auth.currentSession;

      safeLog('Current session: ${session != null ? 'exists' : 'null'}');
      if (session != null) {
        safeLog('Token exists with expiration');
        if (session.expiresAt != null) {
          safeLog(
              'Token expires at: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}');
        }
        safeLog('Current time: ${DateTime.now()}');
      }

      // If session exists, return the token
      if (session != null) {
        return session.accessToken;
      } else {
        safeLog('No active session found');
        return null;
      }
    } catch (e) {
      safeLog('Error getting auth token: $e');
      return null;
    }
  }

  // Create headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    if (token == null) {
      ErrorHandler.logError('ApiService', 'No authentication token available');
      throw Exception('No authentication token available');
    }

    // Make sure to use 'Bearer ' prefix (with a space)
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Debug authentication - use this to diagnose issues
  // DEVELOPMENT ONLY - DO NOT USE IN PRODUCTION
  Future<void> debugAuthentication() async {
    try {
      safeLog('--- DEBUG AUTHENTICATION START ---');

      // Get token without exposing it
      final token = await _getAuthToken();
      safeLog('Auth token available: ${token != null}');

      // Test a direct API call
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$apiBaseUrl${ApiEndpoints.getCurrentUser}'),
          headers: headers,
        );
        safeLog('Direct API call status: ${response.statusCode}');
        safeLog(
            'API call successful: ${response.statusCode >= 200 && response.statusCode < 300}');
      } catch (e) {
        safeLog('Error making direct API call: $e');
      }

      safeLog('--- DEBUG AUTHENTICATION END ---');
    } catch (e) {
      safeLog('Debug authentication error: $e');
    }
  }

  // Test authentication
  Future<Map<String, dynamic>> testAuth() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/token-debug/'),
        headers: headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Auth test failed: ${response.statusCode}');
      }
    } catch (e) {
      ErrorHandler.logError('ApiService.testAuth', e);
      rethrow;
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      ErrorHandler.logError('ApiService', 'Authentication failed (401)');
      throw Exception('Authentication failed: Please log in again');
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'API Error: ${response.statusCode}');
      } catch (e) {
        throw Exception('API Error: ${response.statusCode}');
      }
    }
  }

  // PROFILE ENDPOINTS

  // Get current user profile
  Future<Profile?> getCurrentUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.getCurrentUser}'),
        headers: headers,
      );

      if (response.statusCode == 404) {
        safeLog('Profile not found for current user');
        return null; // Profile not found, return null
      }

      final data = _handleResponse(response);
      return data != null ? Profile.fromJson(data) : null;
    } catch (e) {
      ErrorHandler.logError('ApiService.getCurrentUserProfile', e);
      // Return null instead of throwing an exception
      return null;
    }
  }

  // Create profile
  Future<Profile> createProfile(Profile profile) async {
    try {
      final headers = await _getHeaders();

      // Log the request without exposing sensitive data
      safeLog('Creating profile...');

      final response = await http.post(
        Uri.parse('$apiBaseUrl${ApiEndpoints.createProfile}'),
        headers: headers,
        body: json.encode(profile.toJson()),
      );

      // Log the response status without exposing sensitive data
      safeLog('Profile creation response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return Profile.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.createProfile', e);
      rethrow;
    }
  }

  // Get profile by user ID
  Future<Profile> getProfile(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.getProfile}$userId/'),
        headers: headers,
      );

      final data = _handleResponse(response);
      return Profile.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.getProfile', e);
      rethrow;
    }
  }

  // Update profile
  Future<Profile> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      final headers = await _getHeaders();
      safeLog('Updating profile for user: $userId');

      final response = await http.patch(
        Uri.parse('$apiBaseUrl${ApiEndpoints.updateProfile}$userId/'),
        headers: headers,
        body: json.encode(updates),
      );

      safeLog('Profile update response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return Profile.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.updateProfile', e);
      rethrow;
    }
  }

  // PROJECT ENDPOINTS

  // Get all projects (homepage)
  Future<List<Project>> getProjects({String? query}) async {
    try {
      final headers = await _getHeaders();
      final Uri uri = query != null && query.isNotEmpty
          ? Uri.parse('$apiBaseUrl${ApiEndpoints.homepage}?query=$query')
          : Uri.parse('$apiBaseUrl${ApiEndpoints.homepage}');

      safeLog('Fetching projects${query != null ? ' with query' : ''}');

      final response = await http.get(uri, headers: headers);
      safeLog('Projects fetch response code: ${response.statusCode}');

      final List data = _handleResponse(response);
      return data.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      ErrorHandler.logError('ApiService.getProjects', e);
      rethrow;
    }
  }

  // Create project
  Future<Project> createProject(Project project) async {
    try {
      final headers = await _getHeaders();
      safeLog('Creating new project');

      final response = await http.post(
        Uri.parse('$apiBaseUrl${ApiEndpoints.createProject}'),
        headers: headers,
        body: json.encode(project.toJson()),
      );

      safeLog('Project creation response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return Project.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.createProject', e);
      rethrow;
    }
  }

  // Get project details
  Future<Project> getProjectDetails(int projectId) async {
    try {
      final headers = await _getHeaders();
      safeLog('Fetching details for project ID: $projectId');

      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.projectDetail}$projectId/'),
        headers: headers,
      );

      safeLog('Project details response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return Project.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.getProjectDetails', e);
      rethrow;
    }
  }

  // Update project
  Future<Project> updateProject(
      int projectId, Map<String, dynamic> updates) async {
    try {
      final headers = await _getHeaders();
      safeLog('Updating project ID: $projectId');

      final response = await http.patch(
        Uri.parse('$apiBaseUrl${ApiEndpoints.projectDetail}$projectId/'),
        headers: headers,
        body: json.encode(updates),
      );

      safeLog('Project update response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return Project.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.updateProject', e);
      rethrow;
    }
  }

  // Delete project
  Future<void> deleteProject(int projectId) async {
    try {
      final headers = await _getHeaders();
      safeLog('Deleting project ID: $projectId');

      final response = await http.delete(
        Uri.parse('$apiBaseUrl${ApiEndpoints.projectDetail}$projectId/'),
        headers: headers,
      );

      safeLog('Project deletion response code: ${response.statusCode}');

      _handleResponse(response);
    } catch (e) {
      ErrorHandler.logError('ApiService.deleteProject', e);
      rethrow;
    }
  }

  // Get user projects
  Future<List<Project>> getUserProjects(String userId) async {
    try {
      final headers = await _getHeaders();
      safeLog('Fetching projects for user ID: $userId');

      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.userProjects}$userId/'),
        headers: headers,
      );

      safeLog('User projects response code: ${response.statusCode}');

      final List data = _handleResponse(response);
      return data.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      ErrorHandler.logError('ApiService.getUserProjects', e);
      rethrow;
    }
  }

  // JOIN REQUEST ENDPOINTS

  // Create join request
  Future<JoinRequest> createJoinRequest(int projectId, String? message) async {
    try {
      final headers = await _getHeaders();
      safeLog('Creating join request for project ID: $projectId');

      final response = await http.post(
        Uri.parse('$apiBaseUrl${ApiEndpoints.createJoinRequest}'),
        headers: headers,
        body: json.encode({
          'project_id': projectId,
          'message': message ?? '',
        }),
      );

      safeLog('Join request creation response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return JoinRequest.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.createJoinRequest', e);
      rethrow;
    }
  }

  // Update join request status
  Future<JoinRequest> updateJoinRequestStatus(
      int requestId, String status) async {
    try {
      final headers = await _getHeaders();
      safeLog('Updating join request ID: $requestId to status: $status');

      final response = await http.patch(
        Uri.parse(
            '$apiBaseUrl${ApiEndpoints.updateJoinRequestStatus}$requestId/status/'),
        headers: headers,
        body: json.encode({'status': status}),
      );

      safeLog('Join request update response code: ${response.statusCode}');

      final data = _handleResponse(response);
      return JoinRequest.fromJson(data);
    } catch (e) {
      ErrorHandler.logError('ApiService.updateJoinRequestStatus', e);
      rethrow;
    }
  }

  // Get received join requests
  Future<List<JoinRequest>> getReceivedJoinRequests(String userId) async {
    try {
      final headers = await _getHeaders();
      safeLog('Fetching received join requests for user ID: $userId');

      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.receivedJoinRequests}$userId/'),
        headers: headers,
      );

      safeLog('Received join requests response code: ${response.statusCode}');

      final List data = _handleResponse(response);
      return data.map((json) => JoinRequest.fromJson(json)).toList();
    } catch (e) {
      ErrorHandler.logError('ApiService.getReceivedJoinRequests', e);
      rethrow;
    }
  }

  // Get sent join requests
  Future<List<JoinRequest>> getSentJoinRequests() async {
    try {
      final headers = await _getHeaders();
      safeLog('Fetching sent join requests');

      final response = await http.get(
        Uri.parse('$apiBaseUrl${ApiEndpoints.sentJoinRequests}'),
        headers: headers,
      );

      safeLog('Sent join requests response code: ${response.statusCode}');

      final List data = _handleResponse(response);
      return data.map((json) => JoinRequest.fromJson(json)).toList();
    } catch (e) {
      ErrorHandler.logError('ApiService.getSentJoinRequests', e);
      rethrow;
    }
  }
}

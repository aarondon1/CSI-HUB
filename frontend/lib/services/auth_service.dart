// TODO: Before production release:
// 1. Remove all debug logging
// 2. Remove temporary workaround code for Supabase profiles
// 3. Ensure no tokens or sensitive data are logged
// 4. Set ENABLE_DEBUG_LOGGING to false

import 'package:flutter/foundation.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/supabase_profile_service.dart';
import 'package:frontend/models/profile.dart';

// Global debug flag - set to false before production or demo
const bool ENABLE_DEBUG_LOGGING = true;

class AuthService {
  final ApiService _apiService = ApiService();
  // TEMPORARY WORKAROUND: Using Supabase directly for profiles
  // TODO: Remove this once Django backend profile creation is fixed
  final SupabaseProfileService _supabaseProfileService =
      SupabaseProfileService();

  // Safe logging function
  void safeLog(String message) {
    if (kDebugMode && ENABLE_DEBUG_LOGGING) {
      print(message);
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    final user = supabase.auth.currentUser;
    final session = supabase.auth.currentSession;

    safeLog('Current user: ${user != null ? 'exists' : 'null'}');
    safeLog('Current session: ${session != null ? 'valid' : 'null'}');

    if (session != null) {
      // Check if token is expired
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (expiresAt != null && expiresAt < now) {
        safeLog('Session token has expired');
        return false;
      }
    }

    return user != null && session != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // Sign up with email and password
  Future<void> signUp({required String email, required String password}) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign up');
    }

    safeLog('User signed up successfully');
  }

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign in');
    }

    safeLog('User signed in successfully');
    safeLog('Session token received');
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
    safeLog('User signed out');
  }

  // Check if user has a profile
  Future<bool> hasProfile() async {
    try {
      if (!isAuthenticated()) {
        safeLog('User is not authenticated, cannot check profile');
        return false;
      }

      final userId = getCurrentUserId();
      if (userId == null) {
        safeLog('User ID is null, cannot check profile');
        return false;
      }

      // TEMPORARY WORKAROUND: Try Supabase first, then fall back to Django
      // TODO: Remove this once Django backend profile creation is fixed
      try {
        final hasSupabaseProfile =
            await _supabaseProfileService.profileExistsInSupabase();
        if (hasSupabaseProfile) {
          safeLog('Profile found in Supabase');
          return true;
        }
      } catch (e) {
        safeLog('Error checking Supabase profile');
      }

      // Fall back to Django API
      final profile = await _apiService.getCurrentUserProfile();
      return profile != null;
    } catch (e) {
      safeLog('Error checking profile');
      return false;
    }
  }

  // Get current user profile
  Future<Profile?> getCurrentProfile() async {
    try {
      // TEMPORARY WORKAROUND: Try Supabase first, then fall back to Django
      // TODO: Remove this once Django backend profile creation is fixed
      try {
        final supabaseProfile =
            await _supabaseProfileService.getProfileFromSupabase();
        if (supabaseProfile != null) {
          safeLog('Profile retrieved from Supabase');
          return supabaseProfile;
        }
      } catch (e) {
        safeLog('Error getting Supabase profile');
      }

      // Fall back to Django API
      return await _apiService.getCurrentUserProfile();
    } catch (e) {
      safeLog('Error getting profile');
      return null;
    }
  }
}

// import 'package:frontend/utils/constants.dart';
// import 'package:frontend/services/api_service.dart';
// import 'package:frontend/models/profile.dart';
// import 'package:frontend/utils/error_handler.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// class AuthService {
//   final ApiService _apiService = ApiService();

//   // Check if user is authenticated
//   bool isAuthenticated() {
//     final user = supabase.auth.currentUser;
//     final session = supabase.auth.currentSession;

//     if (session != null) {
//       // Check if token is expired
//       final expiresAt = session.expiresAt;
//       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       if (expiresAt != null && expiresAt < now) {
//         ErrorHandler.logInfo('Session token has expired');
//         return false;
//       }
//     }

//     return user != null && session != null;
//   }

//   // Get current user ID
//   String? getCurrentUserId() {
//     return supabase.auth.currentUser?.id;
//   }

//   // Sign up with email and password
//   Future<void> signUp({required String email, required String password}) async {
//     try {
//       final response = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         emailRedirectTo: null, // Set to null to use default redirect
//       );

//       if (response.user == null) {
//         throw Exception('Failed to sign up');
//       }

//       ErrorHandler.logInfo('User signed up: ${response.user?.id}');
//     } catch (e) {
//       ErrorHandler.logError('AuthService.signUp', e);
//       rethrow;
//     }
//   }

//   // Sign in with email and password
//   Future<void> signIn({required String email, required String password}) async {
//     try {
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );

//       if (response.user == null) {
//         throw Exception('Failed to sign in');
//       }

//       ErrorHandler.logInfo('User signed in: ${response.user?.id}');
//     } catch (e) {
//       ErrorHandler.logError('AuthService.signIn', e);
//       rethrow;
//     }
//   }

//   // Check if email is verified
//   bool isEmailVerified() {
//     final user = supabase.auth.currentUser;
//     return user?.emailConfirmedAt != null;
//   }

//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await supabase.auth.signOut();
//       ErrorHandler.logInfo('User signed out');
//     } catch (e) {
//       ErrorHandler.logError('AuthService.signOut', e);
//       rethrow;
//     }
//   }

//   // Check if user has a profile
//   Future<bool> hasProfile() async {
//     try {
//       if (!isAuthenticated()) {
//         ErrorHandler.logInfo('User is not authenticated, cannot check profile');
//         return false;
//       }

//       final userId = getCurrentUserId();
//       if (userId == null) {
//         ErrorHandler.logInfo('User ID is null, cannot check profile');
//         return false;
//       }

//       try {
//         final profile = await _apiService.getCurrentUserProfile();
//         return profile != null;
//       } catch (apiError) {
//         ErrorHandler.logError('AuthService.hasProfile.apiCall', apiError);

//         // If we get an authentication error, let's try to navigate to home anyway
//         // This is a temporary fix to get past the login screen
//         if (apiError.toString().contains('Authentication failed')) {
//           ErrorHandler.logInfo(
//               'Authentication error when checking profile, assuming user has profile');
//           return true;
//         }
//         return false;
//       }
//     } catch (e) {
//       ErrorHandler.logError('AuthService.hasProfile', e);
//       return false;
//     }
//   }

//   // Get current user profile
//   Future<Profile?> getCurrentProfile() async {
//     try {
//       return await _apiService.getCurrentUserProfile();
//     } catch (e) {
//       ErrorHandler.logError('AuthService.getCurrentProfile', e);
//       return null;
//     }
//   }
// }

// lib/services/supabase_profile_service.dart

// this is a temp supabase profile service that will be removed and reviewed when in production
import 'package:frontend/utils/constants.dart';
import 'package:frontend/models/profile.dart';

class SupabaseProfileService {
  // TEMPORARY WORKAROUND: This class directly interacts with Supabase
  // bypassing the Django backend for profile operations.
  // TODO: Remove this class once Django backend profile creation is fixed

  // Create a profile directly in Supabase
  Future<Profile> createProfileInSupabase(Profile profile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // TEMPORARY: Insert profile directly into Supabase 'profiles' table
      // TODO: Replace with Django API call once backend is fixed
      final response = await supabase
          .from('profiles')
          .insert({
            'user_id': userId,
            'username': profile.username,
            'bio': profile.bio,
            'email': supabase.auth.currentUser?.email,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('Profile created in Supabase: $response');
      return Profile.fromJson(response);
    } catch (e) {
      print('Error creating profile in Supabase: $e');
      throw Exception('Failed to create profile: $e');
    }
  }

  // Check if profile exists in Supabase
  Future<bool> profileExistsInSupabase() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      // TEMPORARY: Check profile directly in Supabase
      // TODO: Replace with Django API call once backend is fixed
      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking profile in Supabase: $e');
      return false;
    }
  }

  // Get profile from Supabase
  Future<Profile?> getProfileFromSupabase() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return null;
      }

      // TEMPORARY: Get profile directly from Supabase
      // TODO: Replace with Django API call once backend is fixed
      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return Profile.fromJson(response);
    } catch (e) {
      print('Error getting profile from Supabase: $e');
      return null;
    }
  }
}

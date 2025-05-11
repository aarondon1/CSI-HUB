// lib/screens/profile/create_profile_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/supabase_profile_service.dart'; // rmeove this later once fixed
import 'package:frontend/models/profile.dart';
import 'package:frontend/screens/home/home_page.dart';
import 'package:frontend/utils/theme.dart';
import 'package:frontend/widgets/loading_overlay.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  // TEMPORARY WORKAROUND: Using Supabase directly for profiles
  // TODO: Remove this once Django backend profile creation is fixed
  final SupabaseProfileService _supabaseProfileService =
      SupabaseProfileService();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final userId = _authService.getCurrentUserId();
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final profile = Profile(
          userId: userId,
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          email: null, // Will be set by the backend
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // TEMPORARY WORKAROUND: Try creating profile in Supabase first
        // TODO: Remove this once Django backend profile creation is fixed
        try {
          print('Attempting to create profile in Supabase...');
          await _supabaseProfileService.createProfileInSupabase(profile);
          print('Profile created in Supabase successfully');

          if (!mounted) return;

          // Navigate to home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
          return; // Exit early if Supabase profile creation succeeds
        } catch (supabaseError) {
          print('Error creating profile in Supabase: $supabaseError');
          // Continue to try Django API if Supabase fails
        }

        // Fall back to Django API
        print('Falling back to Django API for profile creation...');
        await _apiService.createProfile(profile);

        if (!mounted) return;

        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains unchanged
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Profile'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us a bit about yourself',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.description),
                      hintText:
                          'Tell us about yourself, your interests, and skills',
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a bio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Create Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:frontend/services/auth_service.dart';
// import 'package:frontend/services/api_service.dart';
// import 'package:frontend/models/profile.dart';
// import 'package:frontend/screens/home/home_page.dart';
// import 'package:frontend/utils/theme.dart';
// import 'package:frontend/widgets/loading_overlay.dart';
// import 'package:frontend/utils/error_handler.dart';
// import 'package:flutter/foundation.dart';
// import 'package:frontend/utils/constants.dart';

// class CreateProfilePage extends StatefulWidget {
//   const CreateProfilePage({super.key});

//   @override
//   State<CreateProfilePage> createState() => _CreateProfilePageState();
// }

// class _CreateProfilePageState extends State<CreateProfilePage> {
//   final AuthService _authService = AuthService();
//   final ApiService _apiService = ApiService();
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _bioController = TextEditingController();
//   bool _isLoading = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     // Check authentication status when page loads
//     _checkAuthStatus();
//   }

//   Future<void> _checkAuthStatus() async {
//     if (!_authService.isAuthenticated()) {
//       if (kDebugMode) {
//         print(
//             'User not authenticated in CreateProfilePage, attempting to refresh session');
//       }

//       try {
//         // Try to refresh the session
//         await supabase.auth.refreshSession();

//         if (!_authService.isAuthenticated()) {
//           if (kDebugMode) {
//             print('Still not authenticated after refresh');
//           }
//         } else {
//           if (kDebugMode) {
//             print('Successfully refreshed authentication');
//           }
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print('Error refreshing session: $e');
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _createProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       try {
//         final userId = _authService.getCurrentUserId();
//         if (userId == null) {
//           throw Exception('User not authenticated');
//         }

//         // Get the user's email from Supabase
//         final userEmail = supabase.auth.currentUser?.email;

//         final profile = Profile(
//           userId: userId,
//           username: _usernameController.text.trim(),
//           bio: _bioController.text.trim(),
//           email: userEmail, // Include the email from Supabase
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         );

//         if (kDebugMode) {
//           print('Creating profile for user: $userId');
//           print('Username: ${profile.username}');
//           print('Bio: ${profile.bio}');
//           print('Email: ${profile.email}');
//         }

//         await _apiService.createProfile(profile);

//         if (!mounted) return;

//         // Navigate to home page
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } catch (e) {
//         ErrorHandler.logError('CreateProfilePage._createProfile', e);
//         setState(() {
//           _errorMessage = e.toString();
//         });
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LoadingOverlay(
//       isLoading: _isLoading,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Create Profile'),
//           automaticallyImplyLeading: false,
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(height: 24),
//                   const Icon(
//                     Icons.person_outline,
//                     size: 80,
//                     color: AppTheme.primaryColor,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Complete Your Profile',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Tell us a bit about yourself',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),
//                   if (_errorMessage.isNotEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         _errorMessage,
//                         style: TextStyle(color: Colors.red.shade800),
//                       ),
//                     ),
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Username',
//                       prefixIcon: Icon(Icons.person),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a username';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _bioController,
//                     decoration: const InputDecoration(
//                       labelText: 'Bio',
//                       prefixIcon: Icon(Icons.description),
//                       hintText:
//                           'Tell us about yourself, your interests, and skills',
//                     ),
//                     maxLines: 4,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a bio';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _createProfile,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: const Text(
//                       'Create Profile',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

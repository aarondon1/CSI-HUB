import 'package:flutter/material.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/services/api_service.dart';
//import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/loading_overlay.dart';
import 'package:frontend/utils/error_handler.dart';

class EditProfilePage extends StatefulWidget {
  // The parameter name might be different than 'profile'
  final Profile userProfile; // or some other name

  const EditProfilePage(
      {super.key, required this.userProfile}); // Check this line

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  final ApiService _apiService = ApiService();
  // Remove this line since it's not used
  // final AuthService _authService = AuthService();

  bool _isLoading = true;
  String _errorMessage = '';
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final profile = await _apiService.getCurrentUserProfile();

      if (profile != null) {
        setState(() {
          _profile = profile;
          _usernameController.text = profile.username;
          _bioController.text = profile.bio ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Profile not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        if (_profile == null) {
          throw Exception('Profile not loaded');
        }

        final updates = {
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
        };

        await _apiService.updateProfile(_profile!.userId, updates);

        if (!mounted) return;

        ErrorHandler.showSuccessSnackBar(
            context, 'Profile updated successfully');

        // Navigate back
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ErrorHandler.showErrorSnackBar(context, e);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _errorMessage.isNotEmpty && _profile == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
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
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Update Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

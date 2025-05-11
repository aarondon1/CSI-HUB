import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/auth/auth_page.dart';
import 'package:frontend/screens/home/home_page.dart';
import 'package:frontend/screens/profile/create_profile_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/error_handler.dart';
//import 'package:frontend/utils/theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _hasProfile = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isAuthenticated = _authService.isAuthenticated();
      bool hasProfile = false;

      if (isAuthenticated) {
        hasProfile = await _authService.hasProfile();
      }

      setState(() {
        _isAuthenticated = isAuthenticated;
        _hasProfile = hasProfile;
        _isLoading = false;
      });

      // Navigate to appropriate screen after state is updated
      if (_isAuthenticated) {
        if (_hasProfile) {
          _navigateToHome();
        } else {
          _navigateToCreateProfile();
        }
      }
    } catch (e) {
      ErrorHandler.logError('LandingPage._checkAuthState', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void _navigateToCreateProfile() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CreateProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bluebg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bluebg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo and title with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Column(
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/newlogo.png',
                          height: 250,
                        ),
                        const SizedBox(
                            height:
                                75), // Reduced spacing between logo and text

                        // Text
                        const Text(
                          'Connect with like-minded students to bring your ideas to life!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 96, 96, 96),
                          ),
                          textAlign:
                              TextAlign.center, // Ensure proper alignment
                        ),
                        const SizedBox(
                            height:
                                16), // Adjust spacing below the text if needed
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Button with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 40, 155, 237),
                          foregroundColor:
                              const Color(0xFF0D3B66), // Darker blue from logo
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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

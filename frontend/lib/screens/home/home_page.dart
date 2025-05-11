import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/project.dart';
import 'package:frontend/widgets/project_card.dart';
import 'package:frontend/screens/project/create_project_page.dart';
import 'package:frontend/screens/profile/profile_page.dart';
import 'package:frontend/screens/settings/settings_page.dart';
import 'package:frontend/utils/error_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  int _currentIndex = 0;
  List<Project> _projects = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // Reference to profile page's state
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _projects = await _apiService.getProjects(query: query);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = ErrorHandler.getReadableErrorMessage(e);
        _isLoading = false;
      });

      ErrorHandler.logError('HomePage._loadProjects', e);
    }
  }

  Future<void> _search() async {
    await _loadProjects(query: _searchController.text.trim());
  }

  Future<void> _sendJoinRequest(int projectId) async {
    // Show a dialog to get the message
    final TextEditingController messageController = TextEditingController();

    if (!mounted) return;

    final String? message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add a message to your join request (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Explain why you want to join this project...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(messageController.text),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    // If dialog was dismissed or canceled
    if (message == null) return;

    try {
      await _apiService.createJoinRequest(projectId, message);

      if (!mounted) return;

      ErrorHandler.showSuccessSnackBar(
          context, 'Join request sent successfully');

      // Refresh profile page after sending a request
      _refreshProfilePage();
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  // Method to refresh profile page
  void _refreshProfilePage() {
    if (_profileKey.currentState != null) {
      _profileKey.currentState!.loadData();
    }
  }

  void _onTabTapped(int index) {
    // If it's the create project tab
    if (index == 1) {
      // Use a mounted check before using BuildContext
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateProjectPage(),
          fullscreenDialog: true,
        ),
      ).then((result) {
        // If a project was created, reload the projects and refresh profile
        if (result == true) {
          _loadProjects();
          _refreshProfilePage();
        }
      });
      // Don't update the current index, stay on current tab
      return;
    }

    // For other tabs, update normally
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search projects...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadProjects();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),

        // Projects list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $_errorMessage',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProjects,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _projects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No projects found',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProjects,
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProjects,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _projects.length,
                            itemBuilder: (context, index) {
                              final project = _projects[index];
                              return ProjectCard(
                                project: project,
                                onJoinRequest: () =>
                                    _sendJoinRequest(project.id!),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dolphin Finder'),
        automaticallyImplyLeading: false,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProjects,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          Container(), // Empty container for Create tab (we navigate instead)
          ProfilePage(key: _profileKey, onRefresh: () => _loadProjects()),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

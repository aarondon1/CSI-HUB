import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/models/project.dart';
import 'package:frontend/models/join_request.dart';
import 'package:frontend/screens/profile/edit_profile_page.dart';
import 'package:frontend/widgets/project_card.dart';
import 'package:frontend/widgets/join_request_card.dart';
import 'package:frontend/utils/theme.dart';
import 'package:frontend/utils/error_handler.dart';

class ProfilePage extends StatefulWidget {
  // Add a key to access this widget's state from parent
  final Function? onRefresh;

  const ProfilePage({super.key, this.onRefresh});

  @override
  ProfilePageState createState() => ProfilePageState();
}

// Make the state class public by removing the underscore
class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  Profile? _profile;
  List<Project> _userProjects = [];
  List<JoinRequest> _receivedRequests = [];
  List<JoinRequest> _sentRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true; // Keep the state when switching tabs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the widget is inserted into the tree
    // and when the dependencies change
    _refreshIfNeeded();
  }

  Future<void> _refreshIfNeeded() async {
    // Check if we need to refresh the data
    if (!_isLoading && mounted) {
      await _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Make the method public to be called from HomePage
  Future<void> loadData() async {
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Load profile
      _profile = await _apiService.getProfile(userId);

      // Load user projects
      _userProjects = await _apiService.getUserProjects(userId);

      // Load received join requests
      _receivedRequests = await _apiService.getReceivedJoinRequests(userId);

      // Load sent join requests
      _sentRequests = await _apiService.getSentJoinRequests();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Notify parent if refresh callback is provided
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = ErrorHandler.getReadableErrorMessage(e);
        _isLoading = false;
      });

      ErrorHandler.logError('ProfilePage._loadData', e);
    }
  }

  Future<void> _deleteProject(int projectId) async {
    try {
      await _apiService.deleteProject(projectId);

      if (!mounted) return;

      setState(() {
        _userProjects.removeWhere((project) => project.id == projectId);
      });

      ErrorHandler.showSuccessSnackBar(context, 'Project deleted successfully');
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  Future<void> _updateJoinRequestStatus(int requestId, String status) async {
    try {
      final updatedRequest =
          await _apiService.updateJoinRequestStatus(requestId, status);

      if (!mounted) return;

      setState(() {
        final index =
            _receivedRequests.indexWhere((request) => request.id == requestId);
        if (index != -1) {
          _receivedRequests[index] = updatedRequest;
        }
      });

      ErrorHandler.showSuccessSnackBar(
          context, 'Request ${status.toLowerCase()} successfully');
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    // Replace 'profile' with whatever parameter name your EditProfilePage uses
                    // For example, if it uses 'userProfile', change it to:
                    builder: (_) => EditProfilePage(userProfile: _profile!),
                    // Or if it uses 'userData', change it to:
                    // builder: (_) => EditProfilePage(userData: _profile!),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
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
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _profile == null
                  ? const Center(child: Text('Profile not found'))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: Column(
                        children: [
                          // Profile header
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: AppTheme.primaryColor.withAlpha(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _profile!.username,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_profile!.email != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _profile!.email!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (_profile!.bio != null &&
                                    _profile!.bio!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _profile!.bio!,
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Tabs
                          TabBar(
                            controller: _tabController,
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'My Projects'),
                              Tab(text: 'Received Requests'),
                              Tab(text: 'Sent Requests'),
                            ],
                          ),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // My Projects tab
                                _userProjects.isEmpty
                                    ? const Center(
                                        child: Text(
                                            'You haven\'t created any projects yet'),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _userProjects.length,
                                        itemBuilder: (context, index) {
                                          final project = _userProjects[index];
                                          return ProjectCard(
                                            project: project,
                                            isOwner: true,
                                            onDelete: () =>
                                                _deleteProject(project.id!),
                                          );
                                        },
                                      ),

                                // Received Requests tab
                                _receivedRequests.isEmpty
                                    ? const Center(
                                        child:
                                            Text('No join requests received'),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _receivedRequests.length,
                                        itemBuilder: (context, index) {
                                          final request =
                                              _receivedRequests[index];
                                          return JoinRequestCard(
                                            request: request,
                                            isReceived: true,
                                            onAccept: request.status ==
                                                    'pending'
                                                ? () =>
                                                    _updateJoinRequestStatus(
                                                        request.id!, 'accepted')
                                                : null,
                                            onDecline: request.status ==
                                                    'pending'
                                                ? () =>
                                                    _updateJoinRequestStatus(
                                                        request.id!, 'declined')
                                                : null,
                                          );
                                        },
                                      ),

                                // Sent Requests tab
                                _sentRequests.isEmpty
                                    ? const Center(
                                        child: Text('No join requests sent'),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _sentRequests.length,
                                        itemBuilder: (context, index) {
                                          final request = _sentRequests[index];
                                          return JoinRequestCard(
                                            request: request,
                                            isReceived: false,
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/join_request.dart';
import 'package:frontend/models/profile.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/theme.dart';
import 'package:frontend/screens/profile/view_profile_page.dart';
import 'package:frontend/utils/error_handler.dart';

class JoinRequestCard extends StatefulWidget {
  final JoinRequest request;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const JoinRequestCard({
    super.key,
    required this.request,
    required this.isReceived,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<JoinRequestCard> createState() => _JoinRequestCardState();
}

class _JoinRequestCardState extends State<JoinRequestCard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  Profile? _senderProfile;
  Profile? _receiverProfile;
  String? _projectTitle;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load sender profile
      _senderProfile = await _apiService.getProfile(widget.request.senderId);

      // Load receiver profile
      _receiverProfile =
          await _apiService.getProfile(widget.request.receiverId);

      // Load project details to get the title
      try {
        final project =
            await _apiService.getProjectDetails(widget.request.projectId);
        _projectTitle = project.title;
      } catch (e) {
        debugPrint('Error loading project details: $e');
        _projectTitle = 'Project #${widget.request.projectId}';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorHandler.getReadableErrorMessage(e);
          _isLoading = false;
        });
      }
      ErrorHandler.logError('JoinRequestCard._loadProfiles', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      'Error: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to view profile page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProfilePage(
                                      userId: widget.isReceived
                                          ? widget.request.senderId
                                          : widget.request.receiverId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                widget.isReceived
                                    ? 'Request from: ${_senderProfile?.username ?? 'Unknown User'}'
                                    : 'Request to: ${_receiverProfile?.username ?? 'Unknown User'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.assignment,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Project: ${_projectTitle ?? 'Project #${widget.request.projectId}'}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.request.message != null &&
                          widget.request.message!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Message:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.request.message!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusChip(widget.request.status),
                          if (widget.isReceived &&
                              widget.request.status == 'pending')
                            Row(
                              children: [
                                if (widget.onAccept != null)
                                  ElevatedButton(
                                    onPressed: widget.onAccept,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                const SizedBox(width: 8),
                                if (widget.onDecline != null)
                                  ElevatedButton(
                                    onPressed: widget.onDecline,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.errorColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'accepted':
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'declined':
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

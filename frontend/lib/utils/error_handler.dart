import 'package:flutter/material.dart';

class ErrorHandler {
  // Logs errors to console with sensitive data protection
  static void logError(String source, dynamic error) {
    // Sanitize error message to remove sensitive data
    String errorMsg = _sanitizeErrorMessage(error.toString());

    // Use debugPrint which is safer than print
    debugPrint('ERROR [$source]: $errorMsg');
  }

  // Logs informational messages to console
  static void logInfo(String message) {
    // Use debugPrint which is safer than print
    debugPrint('INFO: $message');
  }

  // Sanitize error messages to remove sensitive information
  static String _sanitizeErrorMessage(String message) {
    // Remove any potential tokens
    if (message.contains("Bearer ")) {
      message = message.replaceAll(
          RegExp(r'Bearer [A-Za-z0-9\-_\.]+'), 'Bearer [REDACTED]');
    }

    // Remove any potential JWT tokens that might be in the error
    message =
        message.replaceAll(RegExp(r'eyJ[A-Za-z0-9\-_\.]+'), '[REDACTED_TOKEN]');

    // Remove any potential email addresses
    message = message.replaceAll(
        RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
        '[REDACTED_EMAIL]');

    return message;
  }

  // Returns a user-friendly error message
  static String getReadableErrorMessage(dynamic error) {
    String message = error.toString();

    // Clean up common error messages
    if (message.contains('Connection refused') ||
        message.contains('Failed host lookup') ||
        message.contains('Network is unreachable')) {
      return 'Cannot connect to the server. Please check your internet connection.';
    } else if (message.contains('authentication failed')) {
      return 'Your session has expired. Please log in again.';
    } else if (message.contains('404')) {
      return 'The requested resource was not found.';
    } else if (message.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (message.contains('Profile not found')) {
      return 'Profile not found. Please create a profile first.';
    }

    // If the error message is too long, truncate it
    if (message.length > 100) {
      message = '${message.substring(0, 100)}...';
    }

    return message;
  }

  // Shows an error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getReadableErrorMessage(error)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Shows a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Shows an info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Shows an error dialog for more serious errors
  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Handle network-specific errors
  static void handleNetworkError(BuildContext context, dynamic error) {
    logError('Network', error);
    showErrorSnackBar(context, error);
  }

  // Handle form validation errors
  static void handleFormError(BuildContext context, String message) {
    showErrorSnackBar(context, message);
  }
}

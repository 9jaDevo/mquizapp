import 'package:flutter/material.dart';
import 'package:mquiz/core/network/api_client_exception.dart';

/// Maps an [ApiClientException] (or generic [Exception]) to a user-friendly
/// message that is safe to display.
String describeError(Object e) {
  if (e is ApiClientException) {
    if (e.isUnauthorized) return 'Your session expired. Please sign in again.';
    if (e.isNotFound) return 'We couldn\'t find what you were looking for.';
    if (e.isConflict) return e.message;
    if (e.isTooManyRequests) {
      return 'You are doing that too often. Please wait a moment.';
    }
    if (e.isServerError) {
      return 'Something went wrong on our side. Please try again shortly.';
    }
    return e.message;
  }
  return 'Network error. Please check your connection and try again.';
}

void showErrorSnack(BuildContext context, Object e) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(describeError(e)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

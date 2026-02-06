import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/api_utils.dart';
import '../../../core/constants/api_endpoints_constants.dart';

/// Service to track user engagement time in the app
///
/// Monitors app lifecycle events to calculate session duration
/// Submits session data to backend API when app goes to background
class EngagementTrackerService with WidgetsBindingObserver {
  static const String _sessionStartKey = 'engagement_session_start';
  static const String _pendingSessionsKey = 'engagement_pending_sessions';

  DateTime? _sessionStart;
  Timer? _periodicSubmitTimer;

  /// Initialize the engagement tracker
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _restorePendingSession();
    _startPeriodicSubmit();
  }

  /// Clean up resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicSubmitTimer?.cancel();
  }

  /// Called when app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _endSession();
        break;
      case AppLifecycleState.detached:
        _endSession();
        break;
      case AppLifecycleState.hidden:
        _endSession();
        break;
    }
  }

  /// Start a new session
  void _startSession() {
    _sessionStart = DateTime.now();
    _saveSessionStart();
    debugPrint('📊 Engagement session started: ${_sessionStart}');
  }

  /// End the current session and submit to API
  Future<void> _endSession() async {
    if (_sessionStart == null) {
      return;
    }

    final sessionEnd = DateTime.now();
    final duration = sessionEnd.difference(_sessionStart!);

    // Only track sessions longer than 5 seconds
    if (duration.inSeconds < 5) {
      _sessionStart = null;
      await _clearSessionStart();
      return;
    }

    debugPrint(
      '📊 Engagement session ended: $sessionEnd, Duration: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
    );

    // Submit session to API
    await _submitSession(_sessionStart!, sessionEnd, duration.inSeconds);

    // Clear session
    _sessionStart = null;
    await _clearSessionStart();
  }

  /// Submit session duration to API
  Future<void> _submitSession(
    DateTime start,
    DateTime end,
    int durationSeconds,
  ) async {
    try {
      final sessionData = {
        'session_start': _formatDateTime(start),
        'session_end': _formatDateTime(end),
        'duration_seconds': durationSeconds.toString(),
      };

      // Try to submit immediately
      final success = await _sendSessionToAPI(sessionData);

      if (!success) {
        // If failed, queue for later retry
        await _queueFailedSession(sessionData);
      }
    } catch (e) {
      debugPrint('❌ Error submitting engagement session: $e');
      // Queue for retry
      await _queueFailedSession({
        'session_start': _formatDateTime(start),
        'session_end': _formatDateTime(end),
        'duration_seconds': durationSeconds.toString(),
      });
    }
  }

  /// Send session data to API
  Future<bool> _sendSessionToAPI(Map<String, String> sessionData) async {
    try {
      final response = await http
          .post(
            Uri.parse(submitSessionDurationUrl),
            body: sessionData,
            headers: await ApiUtils.getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          debugPrint('✅ Engagement session submitted successfully');
          return true;
        } else {
          debugPrint('⚠️ API returned error: ${data['message']}');
          return false;
        }
      } else {
        debugPrint('⚠️ HTTP error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network error submitting session: $e');
      return false;
    }
  }

  /// Queue failed session for retry
  Future<void> _queueFailedSession(Map<String, String> sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingList = prefs.getStringList(_pendingSessionsKey) ?? [];

      // Limit queue size to prevent infinite growth
      if (pendingList.length < 50) {
        pendingList.add(json.encode(sessionData));
        await prefs.setStringList(_pendingSessionsKey, pendingList);
        debugPrint(
          '📝 Session queued for retry. Queue size: ${pendingList.length}',
        );
      } else {
        debugPrint('⚠️ Session queue full, discarding oldest session');
        pendingList.removeAt(0);
        pendingList.add(json.encode(sessionData));
        await prefs.setStringList(_pendingSessionsKey, pendingList);
      }
    } catch (e) {
      debugPrint('❌ Error queuing failed session: $e');
    }
  }

  /// Retry submitting pending sessions
  Future<void> _retryPendingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingList = prefs.getStringList(_pendingSessionsKey) ?? [];

      if (pendingList.isEmpty) {
        return;
      }

      debugPrint('🔄 Retrying ${pendingList.length} pending sessions...');

      final stillPending = <String>[];

      for (final sessionJson in pendingList) {
        final sessionData = Map<String, String>.from(json.decode(sessionJson));
        final success = await _sendSessionToAPI(sessionData);

        if (!success) {
          stillPending.add(sessionJson);
        }
      }

      // Update pending list with failed retries
      await prefs.setStringList(_pendingSessionsKey, stillPending);

      if (stillPending.isEmpty) {
        debugPrint('✅ All pending sessions submitted successfully');
      } else {
        debugPrint('⚠️ ${stillPending.length} sessions still pending');
      }
    } catch (e) {
      debugPrint('❌ Error retrying pending sessions: $e');
    }
  }

  /// Start periodic submission of pending sessions
  void _startPeriodicSubmit() {
    // Retry pending sessions every 10 minutes
    _periodicSubmitTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _retryPendingSessions(),
    );
  }

  /// Save session start time to persistent storage
  Future<void> _saveSessionStart() async {
    if (_sessionStart == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionStartKey, _sessionStart!.toIso8601String());
    } catch (e) {
      debugPrint('❌ Error saving session start: $e');
    }
  }

  /// Clear session start time from persistent storage
  Future<void> _clearSessionStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionStartKey);
    } catch (e) {
      debugPrint('❌ Error clearing session start: $e');
    }
  }

  /// Restore pending session from storage (in case app crashed)
  Future<void> _restorePendingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStart = prefs.getString(_sessionStartKey);

      if (savedStart != null) {
        final sessionStart = DateTime.parse(savedStart);
        final now = DateTime.now();
        final duration = now.difference(sessionStart);

        // Only restore if less than 12 hours ago (prevent fraud)
        if (duration.inHours < 12) {
          debugPrint(
            '🔄 Restoring crashed session: ${duration.inMinutes} minutes',
          );
          await _submitSession(sessionStart, now, duration.inSeconds);
        } else {
          debugPrint('⚠️ Discarding old session: ${duration.inHours} hours');
        }

        await _clearSessionStart();
      }

      // Also retry any pending sessions
      await _retryPendingSessions();
    } catch (e) {
      debugPrint('❌ Error restoring pending session: $e');
    }
  }

  /// Format DateTime for API
  String _formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 19).replaceAll('T', ' ');
  }

  /// Manual trigger to end session (for testing)
  Future<void> forceEndSession() async {
    await _endSession();
  }
}

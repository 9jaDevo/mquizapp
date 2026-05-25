/// NestJS API configuration for the mQuiz mobile app.
///
/// All requests go to the NestJS backend directly — no PHP fallback.
/// The base URL can be overridden at build time:
///   flutter build apk --dart-define=API_BASE_URL=https://staging.mquizapi.onrender.com
library;

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://mquizapi.onrender.com',
);

const String apiVersion = '/v2';

/// Full root: https://mquizapi.onrender.com/v2
const String apiRoot = '$apiBaseUrl$apiVersion';

/// Bridge helpers for the NestJS migration.
///
/// Wraps [NestJsApi] calls so they throw the legacy [ApiException] type that
/// existing cubits already handle. This lets a data source swap PHP for
/// NestJS without rewriting the cubit's error logic.
library;

import 'dart:io';

import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/core/network/api_client_exception.dart';

/// Run a NestJS call and translate failures to [ApiException].
Future<T> runNestCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on ApiClientException catch (e) {
    if (e.statusCode == null) {
      // network-level error
      throw const ApiException(errorCodeNoInternet);
    }
    throw ApiException(e.message);
  } on SocketException {
    throw const ApiException(errorCodeNoInternet);
  } on ApiException {
    rethrow;
  } on Exception {
    throw const ApiException(errorCodeDefaultMessage);
  }
}

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Maps raw exceptions and HTTP status codes to typed [Failure] objects.
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Map any exception to a [Failure].
  static Failure map(Object error) {
    if (error is AuthException) {
      return ValidationFailure(error.message);
    }

    if (error is PostgrestException) {
      return ValidationFailure(error.message);
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    if (error is Failure) {
      return error;
    }

    if (error is Exception) {
      final message = error.toString();
      if (message.contains('SocketException') ||
          message.contains('No internet')) {
        return const NetworkFailure();
      }
      if (message.contains('TimeoutException') ||
          message.contains('timed out')) {
        return const TimeoutFailure();
      }
    }

    return const UnknownFailure();
  }

  /// Map an HTTP status code to a [Failure].
  static Failure fromStatusCode(int statusCode, [String? message]) {
    return switch (statusCode) {
      400 => ValidationFailure(message ?? 'Bad request'),
      401 => const UnauthorizedFailure(),
      403 => const UnauthorizedFailure(),
      404 => ValidationFailure(message ?? 'Not found'),
      422 => ValidationFailure(message ?? 'Validation error'),
      429 => const ValidationFailure('Too many requests'),
      >= 500 => ServerFailure(message ?? 'Server error'),
      _ => UnknownFailure(message ?? 'Unexpected error'),
    };
  }
}

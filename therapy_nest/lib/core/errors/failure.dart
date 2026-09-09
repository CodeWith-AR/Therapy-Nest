/// Base failure class for all application errors.
/// Concrete subclasses represent specific error categories.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

/// No internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

/// HTTP request timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timed out');
}

/// Session expired or invalid token (HTTP 401).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Session expired');
}

/// Server-side validation error (HTTP 422/400).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Server error (HTTP 500+).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Catch-all for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

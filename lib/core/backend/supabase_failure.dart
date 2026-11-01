import 'dart:async';

import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:supabase/supabase.dart';

abstract final class HttpStatus {
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
}

abstract final class PostgrestCode {
  static const String notFound = 'PGRST116';
  static const String invalidJwt = 'PGRST301';
  static const String insufficientPrivilege = '42501';
  static const String uniqueViolation = '23505';
}

Failure supabaseFailure(Object error) => switch (error) {
  TimeoutException() ||
  AuthRetryableFetchException() => const ConnectionFailure(),
  AuthSessionMissingException() => const UnauthorizedFailure(),
  AuthException() => _failureFromAuth(error),
  PostgrestException() => _failureFromPostgrest(error),
  _ => const UnknownFailure(),
};

Failure _failureFromAuth(AuthException error) =>
    _failureFromHttpStatus(int.tryParse(error.statusCode ?? ''));

Failure _failureFromHttpStatus(int? status) => switch (status) {
  HttpStatus.badRequest ||
  HttpStatus.unauthorized => const UnauthorizedFailure(),
  HttpStatus.forbidden => const ForbiddenFailure(),
  HttpStatus.tooManyRequests => const RateLimitFailure(),
  final code? when code >= HttpStatus.serverError => const ServerFailure(),
  _ => const UnknownFailure(),
};

Failure _failureFromPostgrest(PostgrestException error) => switch (error.code) {
  PostgrestCode.notFound => const NotFoundFailure(),
  PostgrestCode.insufficientPrivilege => const ForbiddenFailure(),
  PostgrestCode.uniqueViolation => const ConflictFailure(),
  PostgrestCode.invalidJwt => const UnauthorizedFailure(),
  _ => const ServerFailure(),
};

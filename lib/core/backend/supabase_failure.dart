import 'dart:async';

import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:supabase/supabase.dart';

Failure supabaseFailure(Object error) {
  if (error is TimeoutException || error is AuthRetryableFetchException) {
    return const ConnectionFailure();
  }
  if (error is AuthSessionMissingException) return const UnauthorizedFailure();
  if (error is AuthException) {
    return switch (int.tryParse(error.statusCode ?? '')) {
      400 || 401 => const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      429 => const RateLimitFailure(),
      final status? when status >= 500 => const ServerFailure(),
      _ => const UnknownFailure(),
    };
  }
  if (error is PostgrestException) {
    return switch (error.code) {
      'PGRST116' => const NotFoundFailure(),
      '42501' => const ForbiddenFailure(),
      '23505' => const ConflictFailure(),
      'PGRST301' => const UnauthorizedFailure(),
      _ => const ServerFailure(),
    };
  }
  return const UnknownFailure();
}

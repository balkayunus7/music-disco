import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/auth/auth_provider.dart' as domain;
import 'package:mobile_boilerplate/domain/auth/auth_session.dart';
import 'package:mobile_boilerplate/domain/auth/i_auth_service.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/domain/common/rate_limiter.dart';
import 'package:music_disco/core/backend/supabase_failure.dart';
import 'package:supabase/supabase.dart' as supabase show Session;
import 'package:supabase/supabase.dart' hide Session;

class ImplAuthService extends IAuthService {
  ImplAuthService(
    this._supabaseClient,
    this._secureStorage,
    this._rateLimiter, {
    required String projectUrl,
  }) : _sessionKey = 'music_disco.${Uri.parse(projectUrl).host}.session';
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;
  final RateLimiter _rateLimiter;
  final String _sessionKey;

  static const Set<String> _invalidSessionCodes = {
    'refresh_token_not_found',
    'refresh_token_already_used',
    'session_not_found',
  };

  final _sessionInvalidated = StreamController<void>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;
  Future<FailureOr<AuthSession>>? _pendingSignIn;
  Future<void> _pendingWrite = Future.value();

  Stream<void> get sessionInvalidated => _sessionInvalidated.stream;

  @override
  Future<void> listenAuthChanges({
    SessionRefreshCallback? onSessionRefreshed,
  }) async {
    await _authSubscription?.cancel();
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        unawaited(_saveSession(session).catchError((Object _) {}));
        onSessionRefreshed?.call(_toAuthSession(session));
      } else if (data.event == AuthChangeEvent.signedOut) {
        unawaited(_clearSession().catchError((Object _) {}));
        _sessionInvalidated.add(null);
      }
    }, onError: (Object _) {});
  }

  @override
  Future<FailureOr<AuthSession>> getCurrentSession() async {
    try {
      var session = _supabaseClient.auth.currentSession;
      if (session != null) {
        if (session.isExpired) {
          session = (await _supabaseClient.auth.refreshSession()).session;
        }
        if (session == null) return left(const UnauthorizedFailure());
        await _saveSession(session);
        return right(_toAuthSession(session));
      }

      await _pendingWrite;
      final sessionJson = await _secureStorage.read(key: _sessionKey);
      if (sessionJson == null) return left(const NotFoundFailure());
      if (!_isValidStoredSession(sessionJson)) {
        await _clearSession();
        return left(const NotFoundFailure());
      }

      final recoveredSession = (await _supabaseClient.auth.recoverSession(
        sessionJson,
      )).session;
      if (recoveredSession == null) return left(const UnauthorizedFailure());
      await _saveSession(recoveredSession);
      return right(_toAuthSession(recoveredSession));
    } on AuthException catch (error) {
      // Only a session rejected by Supabase is treated as missing. Network
      // errors keep the stored guest so a retry can restore it.
      if (_isInvalidSession(error)) {
        await _clearSession();
        return left(const NotFoundFailure());
      }
      return left(supabaseFailure(error));
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  @override
  Future<FailureOr<Unit>> clearSession() async {
    try {
      if (_supabaseClient.auth.currentSession != null) {
        await _supabaseClient.auth.signOut(scope: SignOutScope.local);
      }
      await _clearSession();
      return right(unit);
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  @override
  Future<FailureOr<AuthSession>> signInAnonymously() => _pendingSignIn ??=
      _signInAnonymously().whenComplete(() => _pendingSignIn = null);

  Future<FailureOr<AuthSession>> _signInAnonymously() async {
    if (_supabaseClient.auth.currentSession != null) return getCurrentSession();
    if (!_rateLimiter.canProceed) return left(const RateLimitFailure());
    _rateLimiter.recordAttempt();

    try {
      final session = (await _supabaseClient.auth.signInAnonymously()).session;
      if (session == null) return left(const UnauthorizedFailure());
      await _saveSession(session);

      _rateLimiter.reset();
      return right(_toAuthSession(session));
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  @override
  Future<FailureOr<Unit>> signOutAnonymously() => clearSession();

  @override
  Future<FailureOr<AuthSession>> signInWithApple() async =>
      left(const ForbiddenFailure());

  @override
  Future<FailureOr<AuthSession>> signInWithGoogle() async =>
      left(const ForbiddenFailure());

  @override
  Future<FailureOr<Unit>> signOutApple() => clearSession();

  @override
  Future<FailureOr<Unit>> signOutGoogle() => clearSession();

  void startAutoRefresh() => _supabaseClient.auth.startAutoRefresh();

  void stopAutoRefresh() => _supabaseClient.auth.stopAutoRefresh();

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _pendingWrite;
    await _sessionInvalidated.close();
  }

  AuthSession _toAuthSession(supabase.Session session) {
    return AuthSession(
      userId: session.user.id,
      idToken: session.accessToken,
      provider: domain.AuthProvider.anonymous,
    );
  }

  bool _isInvalidSession(AuthException error) =>
      error.statusCode == '401' || _invalidSessionCodes.contains(error.code);

  bool _isValidStoredSession(String sessionJson) {
    try {
      final decoded = jsonDecode(sessionJson);
      if (decoded is! Map<String, dynamic>) return false;
      return supabase.Session.fromJson(decoded)?.refreshToken != null;
    } on FormatException {
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<void> _saveSession(supabase.Session session) => _enqueueWrite(
    () => _secureStorage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    ),
  );

  Future<void> _clearSession() =>
      _enqueueWrite(() => _secureStorage.delete(key: _sessionKey));

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final write = _pendingWrite.then((_) => operation());
    _pendingWrite = write.catchError((Object _) {});
    return write;
  }
}

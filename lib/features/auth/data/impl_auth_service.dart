import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/auth/auth_provider.dart' as domain;
import 'package:mobile_boilerplate/domain/auth/auth_session.dart';
import 'package:mobile_boilerplate/domain/auth/i_auth_service.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/domain/common/rate_limiter.dart';
import 'package:music_disco/core/util/supabase_failure.dart';
import 'package:supabase/supabase.dart' as supabase show Session;
import 'package:supabase/supabase.dart' hide Session;

class ImplAuthService extends IAuthService {
  ImplAuthService(
    this._supabaseClient,
    this._secureStorage,
    this._rateLimiter, {
    required String projectUrl,
  }) : _sessionKey = 'music_disco.${Uri.parse(projectUrl).host}.session';

  final String _sessionKey;
  final _sessionInvalidated = StreamController<void>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;
  Future<FailureOr<AuthSession>>? _pendingSignIn;
  Future<void> _pendingWrite = Future.value();

  /// Emits when Supabase drops the session, e.g. after a revoked refresh token.
  Stream<void> get sessionInvalidated => _sessionInvalidated.stream;

  @override
  Future<void> listenAuthChanges({
    SessionRefreshCallback? onSessionRefreshed,
  }) async {
    await _authSubscription?.cancel();
    _authSubscription = supabaseClient.auth.onAuthStateChange.listen((data) {
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
      var session = supabaseClient.auth.currentSession;
      if (session != null) {
        if (session.isExpired) {
          session = (await supabaseClient.auth.refreshSession()).session;
        }
        if (session == null) return left(const UnauthorizedFailure());
        await _saveSession(session);
        return right(_toAuthSession(session));
      }

      await _pendingWrite;
      final sessionJson = await secureStorage.read(key: _sessionKey);
      if (sessionJson == null) return left(const NotFoundFailure());
      if (!_isValidStoredSession(sessionJson)) {
        await _clearSession();
        return left(const NotFoundFailure());
      }

      final recoveredSession = (await supabaseClient.auth.recoverSession(
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
      if (supabaseClient.auth.currentSession != null) {
        await supabaseClient.auth.signOut(scope: SignOutScope.local);
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
    if (supabaseClient.auth.currentSession != null) return getCurrentSession();
    if (!rateLimiter.canProceed) return left(const RateLimitFailure());
    rateLimiter.recordAttempt();

    try {
      final session = (await supabaseClient.auth.signInAnonymously()).session;
      if (session == null) return left(const UnauthorizedFailure());
      await _saveSession(session);

      rateLimiter.reset();
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

  void startAutoRefresh() => supabaseClient.auth.startAutoRefresh();

  void stopAutoRefresh() => supabaseClient.auth.stopAutoRefresh();

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
      error.statusCode == '401' ||
      {
        'refresh_token_not_found',
        'refresh_token_already_used',
        'session_not_found',
      }.contains(error.code);

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
    () => secureStorage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    ),
  );

  Future<void> _clearSession() =>
      _enqueueWrite(() => secureStorage.delete(key: _sessionKey));

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final write = _pendingWrite.then((_) => operation());
    _pendingWrite = write.catchError((Object _) {});
    return write;
  }

  FlutterSecureStorage get secureStorage => _secureStorage;
  SupabaseClient get supabaseClient => _supabaseClient;
  RateLimiter get rateLimiter => _rateLimiter;

  final FlutterSecureStorage _secureStorage;
  final SupabaseClient _supabaseClient;
  final RateLimiter _rateLimiter;
}

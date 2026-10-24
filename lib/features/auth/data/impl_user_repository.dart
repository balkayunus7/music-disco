import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/auth/auth_session.dart';
import 'package:mobile_boilerplate/domain/auth/i_user_repository.dart';
import 'package:mobile_boilerplate/domain/auth/user.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/domain/purchases/subscription.dart';
import 'package:music_disco/core/util/music_routes.dart';
import 'package:music_disco/core/util/supabase_failure.dart';
import 'package:music_disco/features/auth/domain/models/music_user.dart';
import 'package:music_disco/features/auth/domain/models/music_user_properties.dart';
import 'package:supabase/supabase.dart' hide Session, User;

class ImplUserRepository extends IUserRepository {
  ImplUserRepository(this._supabaseClient);

  @override
  Future<FailureOr<User>> getUser({required AuthSession session}) async {
    if (!_ownsSession(session)) return left(const UnauthorizedFailure());
    try {
      final data = await supabaseClient
          .from(usersTable)
          .select()
          .eq('user_id', session.userId)
          .single();
      return right(MusicUser.fromMap(data));
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  @override
  Future<FailureOr<Unit>> deleteUser({required AuthSession session}) async {
    if (!_ownsSession(session)) return left(const UnauthorizedFailure());
    try {
      final response = await supabaseClient.functions.invoke(
        deleteAccountRoute,
        headers: {
          'Authorization':
              'Bearer ${supabaseClient.auth.currentSession!.accessToken}',
        },
      );
      final data = response.data;
      if (response.status == 200 && data is Map && data['success'] == true) {
        return right(unit);
      }
      return left(const ServerFailure());
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  @override
  Future<FailureOr<Unit>> setFcmToken({
    required AuthSession session,
    required String fcmToken,
  }) async {
    if (!_ownsSession(session)) return left(const UnauthorizedFailure());
    return _updateUserRow(session, {'firebase_token': fcmToken});
  }

  @override
  Future<FailureOr<Unit>> updateUser({
    required AuthSession session,
    required covariant MusicUserProperties properties,
  }) async {
    if (!_ownsSession(session)) return left(const UnauthorizedFailure());
    if (!properties.isValid) return left(const BadRequestFailure());
    return _updateUserRow(session, properties.toMap());
  }

  @override
  Future<FailureOr<Unit>> syncSubscription({
    required AuthSession session,
    required Subscription subscription,
  }) async => left(const ForbiddenFailure());

  bool _ownsSession(AuthSession session) =>
      session.userId == supabaseClient.auth.currentUser?.id &&
      session.idToken.isNotEmpty;

  Future<FailureOr<Unit>> _updateUserRow(
    AuthSession session,
    Map<String, dynamic> data,
  ) async {
    try {
      await supabaseClient
          .from(usersTable)
          .update(data)
          .eq('user_id', session.userId)
          .select('user_id')
          .single();
      return right(unit);
    } on Exception catch (error) {
      return left(supabaseFailure(error));
    }
  }

  final SupabaseClient _supabaseClient;

  SupabaseClient get supabaseClient => _supabaseClient;
}

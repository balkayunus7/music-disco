import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/domain/common/failure.dart';
import 'package:mobile_boilerplate/extensions.dart';

extension AuthStateExt on AuthState {
  Failure? get _sessionFailure =>
      failOrSessionOption.getOrNull()?.getLeftOrNull();

  Failure? get _userFailure => failOrUserOption.getOrNull()?.getLeftOrNull();

  /// A guest is created only when no stored session exists. Network, storage
  /// and user-fetch failures must keep the existing guest for a retry.
  bool get canCreateGuest =>
      !isProcessing &&
      _sessionFailure is NotFoundFailure &&
      failOrUserOption.isNone();

  Failure? get startupFailure {
    final sessionFailure = _sessionFailure;
    if (sessionFailure != null && sessionFailure is! NotFoundFailure) {
      return sessionFailure;
    }
    return _userFailure;
  }

  bool get hasStartupFailed => !isProcessing && startupFailure != null;
}

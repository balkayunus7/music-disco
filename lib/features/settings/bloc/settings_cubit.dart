import 'package:mobile_boilerplate/common_dependencies.dart';

class SettingsCubit extends Cubit<bool> {
  SettingsCubit(this._preferences)
    : super(_preferences.getBool(reduceMotionKey) ?? false);

  static const reduceMotionKey = 'settings_reduce_motion';
  final SharedPreferences _preferences;

  Future<bool> setReduceMotion(bool value) async {
    try {
      final saved = await _preferences.setBool(reduceMotionKey, value);
      if (saved && !isClosed) emit(value);
      return saved;
    } on Exception {
      return false;
    }
  }
}

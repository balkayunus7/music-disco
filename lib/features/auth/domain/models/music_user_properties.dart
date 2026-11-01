import 'package:mobile_boilerplate/domain/auth/user.dart';
import 'package:mobile_boilerplate/domain/auth/user_properties.dart';
import 'package:music_disco/features/auth/domain/models/music_user.dart';

class MusicUserProperties extends UserProperties {
  const MusicUserProperties({required this.name});
  final String name;

  static const int maxNameLength = 80;

  String get _trimmed => name.trim();

  bool get isValid => _trimmed.isNotEmpty && _trimmed.length <= maxNameLength;

  Map<String, dynamic> toMap() => {'name': _trimmed};

  @override
  MusicUser applyTo(User user) => (user as MusicUser).copyWith(name: _trimmed);
}

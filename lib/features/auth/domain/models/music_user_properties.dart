import 'package:mobile_boilerplate/domain/auth/user.dart';
import 'package:mobile_boilerplate/domain/auth/user_properties.dart';
import 'package:music_disco/features/auth/domain/models/music_user.dart';

class MusicUserProperties extends UserProperties {
  const MusicUserProperties({required this.name});
  final String name;

  bool get isValid => name.trim().isNotEmpty && name.trim().length <= 80;
  Map<String, dynamic> toMap() => {'name': name.trim()};

  @override
  MusicUser applyTo(User user) =>
      (user as MusicUser).copyWith(name: name.trim());
}

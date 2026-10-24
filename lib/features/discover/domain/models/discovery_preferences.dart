import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';

class DiscoveryPreferences extends Equatable {
  const DiscoveryPreferences({
    this.mood = Mood.afterHours,
    this.direction = DiscoveryDirection.stay,
    this.distance = DiscoveryDistance.close,
  });

  final Mood mood;
  final DiscoveryDirection direction;
  final DiscoveryDistance distance;

  DiscoveryPreferences copyWith({
    Mood? mood,
    DiscoveryDirection? direction,
    DiscoveryDistance? distance,
  }) {
    return DiscoveryPreferences(
      mood: mood ?? this.mood,
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [mood, direction, distance];
}

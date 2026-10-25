import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:music_disco/features/discover/domain/models/discovery_direction.dart';
import 'package:music_disco/features/discover/domain/models/discovery_distance.dart';
import 'package:music_disco/features/discover/domain/models/discovery_source.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/domain/models/reference_aspect.dart';

class DiscoveryPreferences extends Equatable {
  const DiscoveryPreferences({
    this.mood = Mood.afterHours,
    this.direction = DiscoveryDirection.stay,
    this.distance = DiscoveryDistance.close,
    this.source = DiscoverySource.mood,
    this.reference,
    this.aspect = ReferenceAspect.atmosphere,
  });

  final Mood mood;
  final DiscoveryDirection direction;
  final DiscoveryDistance distance;
  final DiscoverySource source;
  final MusicReference? reference;
  final ReferenceAspect aspect;

  MusicReference? get activeReference => source == DiscoverySource.reference ? reference : null;

  Mood get anchorMood => activeReference?.mood ?? mood;

  DiscoveryPreferences copyWith({
    Mood? mood,
    DiscoveryDirection? direction,
    DiscoveryDistance? distance,
    DiscoverySource? source,
    MusicReference? reference,
    ReferenceAspect? aspect,
  }) {
    return DiscoveryPreferences(
      mood: mood ?? this.mood,
      direction: direction ?? this.direction,
      distance: distance ?? this.distance,
      source: source ?? this.source,
      reference: reference ?? this.reference,
      aspect: aspect ?? this.aspect,
    );
  }

  @override
  List<Object?> get props => [mood, direction, distance, source, reference, aspect];
}

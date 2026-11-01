import 'package:flutter/material.dart';
import 'package:music_disco/core/widgets/disc_cover.dart';
import 'package:music_disco/features/discover/domain/models/mood.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';

class MoodDisc extends StatelessWidget {
  const MoodDisc({
    super.key,
    required this.mood,
    required this.size,
    this.turns = 0,
    this.isDimmed = false,
    this.hasShadow = true,
  });
  final Mood mood;
  final double size;
  final double turns;
  final bool isDimmed;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return DiscCover(
      palette: mood.palette,
      size: size,
      title: mood.discTitle,
      caption: mood.discCaption,
      turns: turns,
      isDimmed: isDimmed,
      hasShadow: hasShadow,
    );
  }
}

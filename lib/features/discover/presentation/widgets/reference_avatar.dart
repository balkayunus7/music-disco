import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/features/discover/domain/models/music_reference.dart';
import 'package:music_disco/features/discover/presentation/mood_style.dart';

class ReferenceAvatar extends StatelessWidget {
  const ReferenceAvatar({super.key, required this.reference, required this.size});

  final MusicReference reference;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = reference.imageUrl;
    if (imageUrl == null) return _fallback(context);
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            wasSynchronouslyLoaded || frame != null ? child : _fallback(context),
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.surfaceSecondary, context.colors.surface, context.colors.accent],
        ),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        reference.initials,
        style: referenceTitleStyle(context).copyWith(fontSize: size * 0.3, color: context.colors.textSecondary),
      ),
    );
  }
}

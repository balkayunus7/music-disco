import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/text_styles.dart';

class CaptionLabel extends StatelessWidget {
  const CaptionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: captionLabelStyle(
        context,
      ).copyWith(color: context.colors.textSecondary),
    );
  }
}

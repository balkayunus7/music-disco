import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

/// Small, widely tracked uppercase label. Copy is uppercased in the
/// translation files so Turkish dotted capitals stay correct.
class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: m12w600(context).copyWith(
        color: color ?? context.colors.textSecondary,
        letterSpacing: 2.2,
      ),
    );
  }
}

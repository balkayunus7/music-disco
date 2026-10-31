import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key, this.color, this.loading = false});

  final String text;
  final Color? color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: eyebrowTextStyle(
        context,
        loading: loading,
      ).copyWith(color: color ?? context.colors.textSecondary),
    );
  }
}

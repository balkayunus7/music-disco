import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

/// Two-line display headline; the second line is dimmed.
class DisplayHeadline extends StatelessWidget {
  const DisplayHeadline({super.key, required this.first, required this.second});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final style = a56(context);
    return Semantics(
      header: true,
      label: '$first $second',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(first, style: style),
            Text(
              second,
              style: style.copyWith(color: context.colors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

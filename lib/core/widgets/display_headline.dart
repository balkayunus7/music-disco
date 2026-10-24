import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

class DisplayHeadline extends StatelessWidget {
  const DisplayHeadline({super.key, required this.first, required this.second});

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final style = a32(context);
    return Semantics(
      header: true,
      label: '$first $second',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: '$first '),
                TextSpan(
                  text: second,
                  style: style.copyWith(color: context.colors.textDisabled),
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/util/custom_app_colors.dart';

class DisplayHeadline extends StatelessWidget {
  const DisplayHeadline({
    super.key,
    required this.first,
    this.second = '',
    this.role = HeadlineRole.general,
    this.stacked = false,
  });

  final String first;
  final String second;
  final HeadlineRole role;
  final bool stacked;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final loading = role == HeadlineRole.loading;
      final style = headlineTextStyle(context, constraints.maxWidth, role: role)
          .copyWith(
            color: loading ? context.loadingText : context.colors.textPrimary,
          );
      return Semantics(
        header: true,
        label: second.isEmpty ? first : '$first $second',
        child: ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: first),
                if (second.isNotEmpty)
                  TextSpan(
                    text: stacked ? '\n$second' : ' $second',
                    style: style.copyWith(
                      color: loading
                          ? context.loadingMutedText
                          : context.colors.textTertiary,
                    ),
                  ),
              ],
            ),
            maxLines: stacked && second.isNotEmpty ? 2 : 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/design_system/colors.dart';

class AppPageHeadline extends StatelessWidget {
  const AppPageHeadline({
    super.key,
    required this.first,
    this.second,
    this.role = HeadlineRole.general,
  });
  final String first;
  final String? second;
  final HeadlineRole role;

  @override
  Widget build(BuildContext context) {
    final second = this.second;
    final colors = context.colors;
    final isLoading = role == HeadlineRole.loading;
    final isStacked = isLoading && second != null;
    final firstColor = isLoading ? context.loadingText : colors.textPrimary;
    final secondColor = isLoading
        ? context.loadingMutedText
        : colors.textTertiary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = headlineTextStyle(
          context,
          constraints.maxWidth,
          role: role,
        ).copyWith(color: firstColor);
        return Semantics(
          header: true,
          label: second == null ? first : '$first $second',
          child: ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: first),
                  if (second != null)
                    TextSpan(
                      text: isStacked ? '\n$second' : ' $second',
                      style: style.copyWith(color: secondColor),
                    ),
                ],
              ),
              maxLines: isStacked ? 2 : 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

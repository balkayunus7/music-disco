import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/page_back_button.dart';
import 'package:music_disco/core/widgets/round_icon_button.dart';

/// Shared page chrome with a leading title and consistent navigation controls.
class AppPageBar extends StatelessWidget {
  const AppPageBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.actionIcon,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionIcon == null && actionLabel == null && onAction == null) ||
             (actionIcon != null && actionLabel != null && onAction != null),
       );

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: Sp.cont.r,
    child: Row(
      children: [
        if (showBackButton) PageBackButton(onBack: onBack),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: eyebrowTextStyle(
                context,
              ).copyWith(color: context.colors.textSecondary),
            ),
          ),
        ),
        if (actionIcon != null) ...[
          Sp.xsmall.widthBox,
          RoundIconButton(
            icon: actionIcon!,
            onTap: onAction!,
            semanticLabel: actionLabel!,
          ),
        ],
      ],
    ),
  );
}

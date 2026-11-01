import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/app_back_button.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class AppPageBarAction {
  const AppPageBarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class AppPageBar extends StatelessWidget {
  const AppPageBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.action,
  }) : assert(showBackButton || onBack == null);
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final AppPageBarAction? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return SizedBox(
      height: Sp.control.r,
      child: Row(
        children: [
          if (showBackButton) ...[AppBackButton(onBack: onBack)],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: captionLabelStyle(
                  context,
                ).copyWith(color: context.colors.textSecondary),
              ),
            ),
          ),
          if (action != null) ...[
            Sp.s8.widthBox,
            _ActionButton(action: action),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final AppPageBarAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onTap: action.onTap,
      semanticLabel: action.label,
      haptic: TapHaptic.selection,
      child: SizedBox.square(
        dimension: Sp.s48.r,
        child: Align(
          alignment: Alignment.centerRight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: Sp.s36.r,
              child: Icon(
                action.icon,
                color: colors.textPrimary,
                size: Sp.s18.r,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

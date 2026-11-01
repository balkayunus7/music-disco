import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/core/design_system/motion.dart';

Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    clipBehavior: Clip.antiAlias,
    backgroundColor: context.colors.surface,
    barrierColor: context.colors.overlay,
    shape: RoundedRectangleBorder(
      borderRadius: Sp.s32.radiusOnlyR(tl: true, tr: true),
    ),
    builder: builder,
  );
}

class SheetOptionTile extends StatelessWidget {
  const SheetOptionTile({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isSelected = false,
  }) : isDestructive = false;

  const SheetOptionTile.destructive({
    super.key,
    required this.label,
    required this.onTap,
    required IconData this.icon,
  }) : isSelected = false,
       isDestructive = true;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSelected;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? context.colors.error
        : context.colors.textPrimary;

    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      pressedScale: MotionScale.pressedSubtle,
      child: ExcludeSemantics(
        child: SizedBox(
          height: Sp.s56.h,
          child: Row(
            spacing: Sp.s12.w,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: Sp.s20.r),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelTextStyle(context).copyWith(color: foreground),
                ),
              ),
              if (isSelected) ...[
                Icon(
                  Icons.check_rounded,
                  color: context.colors.primary,
                  size: Sp.s20.r,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

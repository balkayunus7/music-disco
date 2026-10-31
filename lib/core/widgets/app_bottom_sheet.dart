import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

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
      borderRadius: Sp.xxlarge.radiusOnlyR(tl: true, tr: true),
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
    this.color,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.colors.textPrimary;
    return Pressable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: label,
      pressedScale: 0.98,
      child: ExcludeSemantics(
        child: SizedBox(
          height: Sp.xxxlarge.h + Sp.xsmall.h,
          child: Row(
            spacing: Sp.small.w,
            children: [
              if (icon != null) Icon(icon, color: foreground, size: Sp.large.r),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelTextStyle(context).copyWith(color: foreground),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  color: context.colors.primary,
                  size: Sp.large.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

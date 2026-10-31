import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.text,
    required this.onTap,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    final trailingIcon = this.trailingIcon;
    return Pressable(
      onTap: onTap,
      semanticLabel: text,
      haptic: TapHaptic.selection,
      child: ExcludeSemantics(
        child: Padding(
          padding: Sp.xsmall.padVR,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Sp.xsmall.w,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: bodyTextStyle(context).copyWith(color: color),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: color, size: Sp.medium.r),
            ],
          ),
        ),
      ),
    );
  }
}

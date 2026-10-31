import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class PageBackButton extends StatelessWidget {
  const PageBackButton({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onBack ?? context.pop,
      semanticLabel: LocaleKeys.back.tr(),
      haptic: TapHaptic.selection,
      child: SizedBox(
        width: Sp.minTouchTarget,
        height: Sp.xxxlarge.r,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
            size: Sp.large.r,
          ),
        ),
      ),
    );
  }
}

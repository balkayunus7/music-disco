import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';

/// "ara®" wordmark with the frequency tagline shown at the top of each page.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          header: true,
          label: 'ara',
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ara', style: a34(context)),
                Text('®', style: m12w500(context)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Text(
          LocaleKeys.brand_tagline.tr(),
          style: m11w700(
            context,
          ).copyWith(color: context.colors.textSecondary, letterSpacing: 1.8),
        ),
        Sp.small.widthBox,
        Container(
          width: Sp.xsmall.r + 2,
          height: Sp.xsmall.r + 2,
          decoration: BoxDecoration(
            color: context.colors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

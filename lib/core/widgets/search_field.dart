import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/pressable.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.clearLabel,
    required this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final String clearLabel;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  void _clear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: Sp.medium.radiusR,
      borderSide: BorderSide(color: context.colors.border),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: context.colors.textPrimary,
      style: m15w500(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: m15w500(context).copyWith(color: context.colors.textDisabled),
        filled: true,
        fillColor: context.colors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: Sp.medium.w, vertical: Sp.medium.h),
        prefixIcon: Icon(Icons.search_rounded, color: context.colors.textSecondary, size: Sp.large.r),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => AnimatedSwitcher(
            duration: 180.ms,
            child: value.text.isEmpty
                ? const SizedBox.shrink()
                : Pressable(
                    onTap: _clear,
                    semanticLabel: clearLabel,
                    haptic: TapHaptic.selection,
                    child: Icon(Icons.close_rounded, color: context.colors.textSecondary, size: Sp.large.r),
                  ),
          ),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: context.colors.textSecondary)),
      ),
    );
  }
}

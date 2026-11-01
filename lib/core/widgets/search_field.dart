import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/core/design_system/motion.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
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
    final colors = context.colors;
    final border = OutlineInputBorder(
      borderRadius: Sp.inputRadius.radiusR,
      borderSide: BorderSide(color: colors.border),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: colors.textPrimary,
      style: inputTextStyle(context),
      decoration: InputDecoration(
        constraints: const BoxConstraints(minHeight: Sp.control),
        hintText: hint,
        hintStyle: inputTextStyle(context).copyWith(color: colors.textDisabled),
        filled: true,
        fillColor: colors.surface,
        isDense: true,
        contentPadding: Sp.s16.padHVR(Sp.s16),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.textSecondary,
          size: Sp.s20.r,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => AnimatedSwitcher(
            duration: context.motion(MotionDuration.fast),
            child: value.text.isEmpty
                ? const SizedBox.shrink()
                : Pressable(
                    onTap: _clear,
                    semanticLabel: clearLabel,
                    haptic: TapHaptic.selection,
                    child: Icon(
                      Icons.close_rounded,
                      color: colors.textSecondary,
                      size: Sp.s20.r,
                    ),
                  ),
          ),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.textSecondary),
        ),
      ),
    );
  }
}

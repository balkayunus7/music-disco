import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/core_app.dart' show appConfig;
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/util/custom_app_sizes.dart';
import 'package:music_disco/core/util/disc_palette.dart';
import 'package:music_disco/core/util/locale_keys.dart';
import 'package:music_disco/core/util/text_style_helper.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_snack_bar.dart';
import 'package:music_disco/core/widgets/brand_page_body.dart';
import 'package:music_disco/core/widgets/app_page_bar.dart';
import 'package:music_disco/core/widgets/display_headline.dart';
import 'package:music_disco/core/widgets/fancy_button.dart';
import 'package:music_disco/core/widgets/holo_disc.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/auth/domain/models/music_user.dart';
import 'package:music_disco/features/auth/domain/models/music_user_properties.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
import 'package:music_disco/core/util/locale_extensions.dart';
import 'package:music_disco/core/util/rebuild_app.dart';
import 'package:music_disco/features/taste/domain/models/music_language.dart';
import 'package:music_disco/features/taste/presentation/taste_style.dart';

part '../widgets/settings_profile_card.dart';
part '../widgets/settings_group.dart';
part '../widgets/settings_sheets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _aboutExpanded = false;

  Future<T?> _choose<T>({required String title, required T selected, required Map<T, String> options}) {
    return showAppBottomSheet<T>(
      context,
      builder: (_) => SettingsChoiceSheet(title: title, selected: selected, options: options),
    );
  }

  Future<void> _editProfile(String? name) async {
    final auth = context.read<AuthCubit>();
    await showAppBottomSheet<void>(
      context,
      builder: (_) => SettingsProfileEditor(
        initialName: name ?? '',
        onSave: (value) async {
          if (!auth.state.isAuthenticated) return false;
          await auth.updateUser(properties: MusicUserProperties(name: value));
          return auth.state.failOrUpdatedOption.fold(() => false, (result) => result.isRight());
        },
      ),
    );
  }

  Future<void> _changeLanguage() async {
    final taste = context.read<TasteCubit>();
    final language = await _choose(
      title: LocaleKeys.settings_song_language.tr(),
      selected: taste.state.saved.language,
      options: {for (final language in MusicLanguage.values) language: language.labelKey.tr()},
    );
    if (!mounted || language == null) return;
    taste.startEditing();
    taste.selectLanguage(language);
    final saved = await taste.save();
    if (!mounted || saved) return;
    showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
  }

  Future<void> _changeAppLanguage() async {
    final current = context.currentLocaleLanguage;
    final selected = await _choose(
      title: LocaleKeys.settings_app_language.tr(),
      selected: current,
      options: {for (final language in LocaleLanguage.values) language: language.nativeName},
    );
    if (!mounted || selected == null || selected == current) return;
    await context.setLocale(selected.locale);
    appConfig.setLanguage(selected.value);
    rebuildApp();
  }

  Future<void> _setReduceMotion(bool value) async {
    final saved = await context.read<SettingsCubit>().setReduceMotion(value);
    if (!mounted || saved) return;
    showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());
  }

  Future<void> _openLink(String value) async {
    if (value.trim().isEmpty) {
      showAppSnackBar(context, message: LocaleKeys.settings_link_unavailable.tr());
      return;
    }
    final uri = Uri.tryParse(value.trim());
    var opened = false;
    if (uri != null && {'https', 'http', 'mailto'}.contains(uri.scheme)) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Exception {
        opened = false;
      }
    }
    if (!mounted || opened) return;
    showAppSnackBar(context, message: LocaleKeys.settings_link_error.tr());
  }

  void _restorePurchases() {
    // Store purchases and server subscription sync are not configured yet.
    showAppSnackBar(context, message: LocaleKeys.settings_restore_unavailable.tr());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final user = auth.isAuthenticated ? auth.userOrCrash as MusicUser : null;
    final collection = context.watch<CollectionCubit>().state;
    final taste = context.watch<TasteCubit>().state.saved;
    final reduceMotion = context.watch<SettingsCubit>().state;
    return BrandPageBody(
      appBar: AppPageBar(title: LocaleKeys.settings_eyebrow.tr()),
      children: [
        DisplayHeadline(first: LocaleKeys.nav_settings.tr(), role: HeadlineRole.settings),
        Sp.large.heightBox,
        SettingsProfileCard(
          name: user?.name?.trim().isNotEmpty == true ? user!.name! : LocaleKeys.settings_listener.tr(),
          summary: LocaleKeys.settings_collection_summary.tr(args: ['${collection.count}', '${collection.shelfCount}']),
          onEdit: () => _editProfile(user?.name),
          onCollection: () => context.go(AppRoutes.collection),
        ),
        Sp.large.heightBox,
        SettingsSectionLabel(text: LocaleKeys.settings_music_world.tr()),
        Sp.small.heightBox,
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.tune_rounded,
              title: LocaleKeys.settings_music_taste.tr(),
              subtitle: taste.genreLabels.join(' · '),
              onTap: () => context.go(AppRoutes.settingsTaste),
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.translate_rounded,
              title: LocaleKeys.settings_song_language.tr(),
              subtitle: taste.language.labelKey.tr(),
              onTap: _changeLanguage,
            ),
          ],
        ),
        Sp.large.heightBox,
        SettingsSectionLabel(text: LocaleKeys.settings_application.tr()),
        Sp.small.heightBox,
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.language_rounded,
              title: LocaleKeys.settings_app_language.tr(),
              subtitle: context.currentLocaleLanguage.nativeName,
              onTap: _changeAppLanguage,
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.auto_awesome_outlined,
              title: LocaleKeys.settings_reduce_motion.tr(),
              subtitle: LocaleKeys.settings_reduce_motion_caption.tr(),
              trailing: Switch.adaptive(
                value: reduceMotion,
                onChanged: _setReduceMotion,
                activeTrackColor: context.colors.primary,
                activeThumbColor: context.colors.textOnPrimary,
                inactiveTrackColor: context.colors.surfaceSecondary,
                inactiveThumbColor: context.colors.textSecondary,
              ),
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.restore_rounded,
              title: LocaleKeys.settings_restore_purchases.tr(),
              onTap: _restorePurchases,
            ),
          ],
        ),
        Sp.large.heightBox,
        SettingsSectionLabel(text: LocaleKeys.settings_help_legal.tr()),
        Sp.small.heightBox,
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.help_outline_rounded,
              title: LocaleKeys.settings_support.tr(),
              onTap: () => _openLink(appConfig.mailToUrl),
              trailing: Icon(Icons.north_east_rounded, size: Sp.medium.r, color: context.colors.textTertiary),
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.shield_outlined,
              title: LocaleKeys.settings_privacy.tr(),
              onTap: () => _openLink(appConfig.privacyPolicyUrl),
              trailing: Icon(Icons.north_east_rounded, size: Sp.medium.r, color: context.colors.textTertiary),
            ),
            const SettingsDivider(),
            SettingsRow(
              icon: Icons.description_outlined,
              title: LocaleKeys.settings_terms.tr(),
              onTap: () => _openLink(appConfig.termsOfServiceUrl),
              trailing: Icon(Icons.north_east_rounded, size: Sp.medium.r, color: context.colors.textTertiary),
            ),
          ],
        ),
        Sp.large.heightBox,
        Divider(color: context.colors.borderSecondary),
        SettingsRow(
          icon: Icons.info_outline_rounded,
          title: LocaleKeys.settings_about.tr(),
          onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
          trailing: Icon(
            _aboutExpanded ? Icons.remove_rounded : Icons.add_rounded,
            color: context.colors.textSecondary,
          ),
        ),
        if (_aboutExpanded)
          Padding(
            padding: Sp.medium.padAllR,
            child: Text(
              LocaleKeys.settings_about_body.tr(),
              style: bodyTextStyle(context).copyWith(color: context.colors.textSecondary, height: 1.6),
            ),
          ),
      ],
    );
  }
}

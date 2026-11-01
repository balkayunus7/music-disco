import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_boilerplate/application/auth/auth_cubit.dart';
import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/core_app.dart' show appConfig;
import 'package:mobile_boilerplate/presentation/extensions/build_context_theme_ext.dart';
import 'package:music_disco/config/app_routes.dart';
import 'package:music_disco/core/design_system/colors.dart';
import 'package:music_disco/core/design_system/sizing.dart';
import 'package:music_disco/core/design_system/text_styles.dart';
import 'package:music_disco/core/design_system/typography.dart';
import 'package:music_disco/core/localization/locale_keys.dart';
import 'package:music_disco/core/localization/locale_language.dart';
import 'package:music_disco/core/util/rebuild_tree.dart';
import 'package:music_disco/core/widgets/app_bottom_sheet.dart';
import 'package:music_disco/core/widgets/app_cta_button.dart';
import 'package:music_disco/core/widgets/app_page_headline.dart';
import 'package:music_disco/core/widgets/app_page_scaffold.dart';
import 'package:music_disco/core/widgets/app_pagebar.dart';
import 'package:music_disco/core/widgets/app_snackbar.dart';
import 'package:music_disco/core/widgets/disc_cover.dart';
import 'package:music_disco/core/widgets/pressable.dart';
import 'package:music_disco/features/auth/domain/models/music_user.dart';
import 'package:music_disco/features/auth/domain/models/music_user_properties.dart';
import 'package:music_disco/features/collection/bloc/collection_cubit.dart';
import 'package:music_disco/features/settings/bloc/settings_cubit.dart';
import 'package:music_disco/features/taste/bloc/taste_cubit.dart';
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
  static const Set<String> _linkSchemes = {'https', 'http', 'mailto'};

  bool _aboutExpanded = false;

  void _showSaveError() =>
      showAppSnackBar(context, message: LocaleKeys.settings_save_error.tr());

  Future<T?> _choose<T>({
    required String title,
    required T selected,
    required Map<T, String> options,
  }) {
    return showAppBottomSheet<T>(
      context,
      builder: (_) => SettingsChoiceSheet(
        title: title,
        selected: selected,
        options: options,
      ),
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
          return auth.state.failOrUpdatedOption.fold(
            () => false,
            (result) => result.isRight(),
          );
        },
      ),
    );
  }

  Future<void> _changeLanguage() async {
    final taste = context.read<TasteCubit>();
    final language = await _choose(
      title: LocaleKeys.settings_song_language.tr(),
      selected: taste.state.saved.language,
      options: {
        for (final language in MusicLanguage.values)
          language: language.labelKey.tr(),
      },
    );
    if (!mounted || language == null) return;
    taste.startEditing();
    taste.selectLanguage(language);
    final saved = await taste.save();
    if (mounted && !saved) _showSaveError();
  }

  Future<void> _changeAppLanguage() async {
    final current = context.currentLocaleLanguage;
    final selected = await _choose(
      title: LocaleKeys.settings_app_language.tr(),
      selected: current,
      options: {
        for (final language in LocaleLanguage.values)
          language: language.nativeName,
      },
    );
    if (!mounted || selected == null || selected == current) return;
    await context.setLocale(selected.locale);
    appConfig.setLanguage(selected.value);
    rebuildTree();
  }

  Future<void> _setReduceMotion(bool value) async {
    final saved = await context.read<SettingsCubit>().setReduceMotion(value);
    if (mounted && !saved) _showSaveError();
  }

  Future<void> _openLink(String value) async {
    if (value.trim().isEmpty) {
      showAppSnackBar(
        context,
        message: LocaleKeys.settings_link_unavailable.tr(),
      );
      return;
    }
    final uri = Uri.tryParse(value.trim());
    var opened = false;
    if (uri != null && _linkSchemes.contains(uri.scheme)) {
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
    showAppSnackBar(
      context,
      message: LocaleKeys.settings_restore_unavailable.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      pageBar: AppPageBar(title: LocaleKeys.settings_eyebrow.tr()),
      children: [
        AppPageHeadline(
          first: LocaleKeys.nav_settings.tr(),
          role: HeadlineRole.settings,
        ),
        Sp.s20.heightBox,
        _buildProfileCard(context),
        Sp.s20.heightBox,
        _buildMusicSection(context),
        Sp.s20.heightBox,
        _buildApplicationSection(context),
        Sp.s20.heightBox,
        _buildHelpSection(),
        Sp.s20.heightBox,
        Divider(color: context.colors.borderSecondary),
        _buildAbout(context),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final user = auth.isAuthenticated ? auth.userOrCrash as MusicUser : null;
    final collection = context.watch<CollectionCubit>().state;
    final name = user?.name?.trim() ?? '';
    return SettingsProfileCard(
      name: name.isEmpty ? LocaleKeys.settings_listener.tr() : name,
      summary: LocaleKeys.settings_collection_summary.tr(
        args: ['${collection.count}', '${collection.shelfCount}'],
      ),
      onEdit: () => _editProfile(user?.name),
      onCollection: () => context.go(AppRoutes.collection),
    );
  }

  Widget _buildMusicSection(BuildContext context) {
    final taste = context.watch<TasteCubit>().state.saved;
    return SettingsSection(
      title: LocaleKeys.settings_music_world.tr(),
      children: [
        SettingsRow(
          icon: Icons.tune_rounded,
          title: LocaleKeys.settings_music_taste.tr(),
          subtitle: taste.genreLabels.join(' · '),
          onTap: () => context.go(AppRoutes.settingsTaste),
        ),
        SettingsRow(
          icon: Icons.translate_rounded,
          title: LocaleKeys.settings_song_language.tr(),
          subtitle: taste.language.labelKey.tr(),
          onTap: _changeLanguage,
        ),
      ],
    );
  }

  Widget _buildApplicationSection(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = context.watch<SettingsCubit>().state;
    return SettingsSection(
      title: LocaleKeys.settings_application.tr(),
      children: [
        SettingsRow(
          icon: Icons.language_rounded,
          title: LocaleKeys.settings_app_language.tr(),
          subtitle: context.currentLocaleLanguage.nativeName,
          onTap: _changeAppLanguage,
        ),
        SettingsRow(
          icon: Icons.auto_awesome_outlined,
          title: LocaleKeys.settings_reduce_motion.tr(),
          subtitle: LocaleKeys.settings_reduce_motion_caption.tr(),
          trailing: Switch.adaptive(
            value: reduceMotion,
            onChanged: _setReduceMotion,
            activeTrackColor: colors.primary,
            activeThumbColor: colors.textOnPrimary,
            inactiveTrackColor: colors.surfaceSecondary,
            inactiveThumbColor: colors.textSecondary,
          ),
        ),
        SettingsRow(
          icon: Icons.restore_rounded,
          title: LocaleKeys.settings_restore_purchases.tr(),
          onTap: _restorePurchases,
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return SettingsSection(
      title: LocaleKeys.settings_help_legal.tr(),
      children: [
        SettingsRow.external(
          icon: Icons.help_outline_rounded,
          title: LocaleKeys.settings_support.tr(),
          onTap: () => _openLink(appConfig.mailToUrl),
        ),
        SettingsRow.external(
          icon: Icons.shield_outlined,
          title: LocaleKeys.settings_privacy.tr(),
          onTap: () => _openLink(appConfig.privacyPolicyUrl),
        ),
        SettingsRow.external(
          icon: Icons.description_outlined,
          title: LocaleKeys.settings_terms.tr(),
          onTap: () => _openLink(appConfig.termsOfServiceUrl),
        ),
      ],
    );
  }

  Widget _buildAbout(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsRow(
          icon: Icons.info_outline_rounded,
          title: LocaleKeys.settings_about.tr(),
          onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
          trailing: Icon(
            _aboutExpanded ? Icons.remove_rounded : Icons.add_rounded,
            color: colors.textSecondary,
          ),
        ),
        if (_aboutExpanded)
          Padding(
            padding: Sp.s16.padAllR,
            child: Text(
              LocaleKeys.settings_about_body.tr(),
              style: bodyTextStyle(context).copyWith(
                color: colors.textSecondary,
                height: LineHeight.relaxed,
              ),
            ),
          ),
      ],
    );
  }
}

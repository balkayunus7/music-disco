import 'package:flutter/widgets.dart';
import 'package:mobile_boilerplate/core_app.dart';
import 'package:music_disco/config/app_config.dart';
import 'package:music_disco/config/restartable_app.dart';
import 'package:music_disco/config/setup_bindings.dart';
import 'package:music_disco/config/setup_dependencies.dart';
import 'package:music_disco/config/startup_failure_app.dart';
import 'package:music_disco/music_disco_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupBindings();
  await setupCoreApp(MusicAppConfig());
  if (!await trySetupDependencies()) {
    runApp(const StartupFailureApp());
    return;
  }
  runApp(const RestartableApp(child: MusicDiscoApp()));
}

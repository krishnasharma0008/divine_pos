import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';

import 'custom_upgrader_messages.dart';
import '../shared/routes/router.dart';
import '../shared/utils/http_client.dart';

final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError("Hive box not initialized");
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Force landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  /// Init Hive
  await Hive.initFlutter();

  /// Clear upgrader cache during testing
  await Upgrader.clearSavedSettings();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final Upgrader upgrader;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    upgrader = Upgrader(
      debugLogging: true,

      /// SHOW ALWAYS FOR TESTING
      debugDisplayAlways: true,
      debugDisplayOnce: false,

      /// FORCE UPDATE
      minAppVersion: '1.0.0',

      /// CUSTOM TEXT
      messages: MyUpgraderMessages(),

      /// APPCAST XML
      storeController: UpgraderStoreController(
        onAndroid: () => UpgraderAppcastStore(appcastURL: baseUrlupgrader),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),

      builder: (context, child) {
        return UpgradeAlert(
          upgrader: upgrader,

          /// REMOVE IGNORE BUTTON
          showIgnore: false,

          /// REMOVE LATER BUTTON
          showLater: false,

          /// FORCE USER TO UPDATE
          barrierDismissible: false,

          /// PREVENT BACK NAVIGATION
          shouldPopScope: () => false,

          /// REMOVE RELEASE NOTES
          ///showReleaseNotes: false,
          navigatorKey: router.routerDelegate.navigatorKey,

          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

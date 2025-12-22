import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../shared/routes/router.dart';
//import '../features/auth/data/auth_notifier.dart';

/// Provides Hive box to the auth provider
final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError("Hive box not initialized");
});

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();

  /// Init Hive              
  await Hive.initFlutter();

  /// Open the auth box before runApp
  //final authBox = await Hive.openBox('authBox');

  /// Provide the opened box to Riverpod
  runApp(
    ProviderScope(
      // overrides: [
      //   hiveBoxProvider.overrideWithValue(authBox),
      // ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeMetrics() {
  //   //ScaleSize.refresh();
  // }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    //print("width: ${MediaQuery.of(context).size.aspectRatio}");
    //print("width:t ${ScaleSize.aspectRatio}");
    // print("width:x ${MediaQuery.of(context).size.width}");
    // print(
    //   "width: ${WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width}",
    // );
    // print(
    //   "width:d ${WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio}",
    // );
    // ScaleSize.refresh();

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

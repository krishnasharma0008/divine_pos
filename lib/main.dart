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
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_notifier.dart';

const baseUrlProduction = "https://api2.divinesolitaires.com/softapi/";

final httpClientProvider = Provider<Dio>((ref) {
  final authRepo = ref.watch(authProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrlProduction,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final user = authRepo.user;
        if (user != null && user.token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${user.token}';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        // Handle 401/403 etc.
        if (e.response?.statusCode == 401) {
          // Maybe clear token or refresh
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});

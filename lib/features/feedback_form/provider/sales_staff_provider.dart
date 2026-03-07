import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';

final salesStaffProvider =
    AsyncNotifierProvider<SalesStaffNotifier, List<String>>(
      SalesStaffNotifier.new,
    );

class SalesStaffNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => _fetch();

  Future<List<String>> _fetch() async {
    final dio = ref.read(httpClientProvider);
    final auth = ref.read(authProvider);
    final pjcode = auth.user?.pjcode;

    if (pjcode == null) return [];

    final res = await dio.post(ApiEndPoint.sale_by, data: {'pjcode': pjcode});

    final body = res.data;
    if (body == null || body['success'] != true) {
      throw Exception(body?['msg'] ?? 'Failed to load staff list');
    }

    final list = body['data'] as List?;
    if (list == null) return [];

    // ⚠️ confirm the field name — common options: 'name', 'user_name', 'full_name'
    return list
        .map((e) => e['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:flutter/foundation.dart'; // ← needed for @immutable
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';

@immutable
class UidLookupResult {
  final String uid;
  final double mrp;
  const UidLookupResult({required this.uid, required this.mrp});
}

class UidLookupNotifier extends Notifier<AsyncValue<UidLookupResult?>> {
  @override
  AsyncValue<UidLookupResult?> build() => const AsyncData(null);

  Future<UidLookupResult?> fetch(String uid) async {
    if (uid.trim().isEmpty) return null;

    state = const AsyncLoading();
    try {
      final dio = ref.read(httpClientProvider);
      final auth = ref.read(authProvider);
      final pjcode = auth.user?.pjcode;

      final res = await dio.post(
        ApiEndPoint.get_jewellery_listing,
        data: {
          'item_number': uid.trim(),
          'pageno': 1,
          if (pjcode != null) 'laying_with': pjcode, // ← only sent if not null
        },
      );

      final raw = res.data;
      if (raw['success'] != true) {
        throw Exception(raw['message'] ?? 'Not found');
      }

      final list = raw['data'] as List?;
      if (list == null || list.isEmpty) {
        throw Exception('UID "$uid" not found');
      }

      final item = list.first as Map<String, dynamic>;

      final rawMrp = item['price']; // ← only 'price'
      if (rawMrp == null) throw Exception('Price not found for UID "$uid"');

      final result = UidLookupResult(
        uid:
            item['designno']?.toString() ??
            uid.trim(), // ← 'designno' from response
        mrp: (rawMrp as num).toDouble(),
      );

      state = AsyncData(result);
      return result;
    } on DioException catch (e) {
      state = AsyncError(e.message ?? 'Network error', StackTrace.current);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  void reset() => state = const AsyncData(null);
}

final uidLookupProvider =
    NotifierProvider<UidLookupNotifier, AsyncValue<UidLookupResult?>>(
      UidLookupNotifier.new,
    );

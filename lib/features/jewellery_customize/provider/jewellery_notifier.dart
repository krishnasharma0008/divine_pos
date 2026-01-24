import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../data/jewellery_detail_model.dart';
import '../data/jewellery_price_model.dart';

/// Provider
final jewelleryDetailProvider =
    AsyncNotifierProvider.autoDispose<
      JewelleryDetailNotifier,
      JewelleryDetail?
    >(JewelleryDetailNotifier.new);

class JewelleryDetailNotifier extends AsyncNotifier<JewelleryDetail?> {
  @override
  Future<JewelleryDetail?> build() async {
    // Do not auto-fetch
    return null;
  }

  /// Fetch jewellery detail using productCode
  Future<void> fetchJewelleryDetail(String productCode) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final dio = ref.read(httpClientProvider);

      final response = await dio
          .post(
            ApiEndPoint.get_jewellery_Prodct,
            data: {'product_code': productCode},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Request timed out after 15s'),
          );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      final body = response.data;

      if (body == null || body['success'] != true) {
        throw Exception('Invalid response from server');
      }

      final data = body['data'];

      if (data == null) {
        throw Exception('Jewellery detail not found');
      }

      return JewelleryDetail.fromJson(data);
    });
  }

  /// Fetch solitaire price (single API call)
  Future<double> fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) async {
    final dio = ref.read(httpClientProvider);

    final response = await dio.post(
      ApiEndPoint.get_price,
      data: {
        'itemgroup': itemGroup,
        'weight': (slab != null && slab.isNotEmpty) ? double.parse(slab) : null,
        'shape': (shape == null || shape.isEmpty) ? null : shape,
        'color': color,
        'quality': quality,
      },
    );

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch solitaire price');
    }

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid price response');
    }

    final price = body['price'];

    if (price is num) {
      return price.toDouble();
    }

    throw Exception('Invalid price response: $body');
  }
}

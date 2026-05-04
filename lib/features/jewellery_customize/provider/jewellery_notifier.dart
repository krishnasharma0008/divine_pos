import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../data/jewellery_detail_model.dart';

/// Provider
final jewelleryDetailProvider =
    AsyncNotifierProvider<JewelleryDetailNotifier, JewelleryDetail?>(
      JewelleryDetailNotifier.new,
    );

class JewelleryDetailNotifier extends AsyncNotifier<JewelleryDetail?> {
  @override
  Future<JewelleryDetail?> build() async {
    // Do not auto-fetch
    return null;
  }

  /// Fetch jewellery detail using productCode
  Future<void> fetchJewelleryDetail(
    String productCode, {
    String? lyingwith,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final dio = ref.read(httpClientProvider);

      //debugPrint('Product : $productCode');

      // debugPrint(
      //   '🌐PDP URL => ${dio.options.baseUrl}${ApiEndPoint.get_jewellery_Prodct}',
      // );
      //getproduct
      final response = await dio
          .post(
            ApiEndPoint.get_jewellery_Prodct,
            data: {
              'product_code': productCode,
              //lyingwith!.isNotEmpty ? 'laying_with' : '': lyingwith,
              if (lyingwith != null && lyingwith.trim().isNotEmpty)
                'laying_with': lyingwith.trim(),
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Request timed out after 15s'),
          );

      longPrint(
        "📦 Jewellery Detail 1 time Fetched Data: ${jsonEncode(response.data)}",
      );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      final body = response.data;
      //debugPrint('Data : $body');

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

  Future<JewelleryDetail?> fetchDetail(
    String productCode,
    String lyingwith,
  ) async {
    state = const AsyncLoading();

    final dio = ref.read(httpClientProvider);

    final response = await dio
        .post(
          ApiEndPoint.get_jewellery_Prodct,
          data: {'product_code': productCode, 'laying_with': lyingwith},
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
    //debugPrint('Data : $body');

    if (body == null || body['success'] != true) {
      throw Exception('Invalid response from server');
    }

    final data = body['data'];

    if (data == null) {
      throw Exception('Jewellery detail not found');
    }

    return JewelleryDetail.fromJson(data);
  }

  /// Fetch full jewellery detail using designno.
  /// Used as a background call to get complete Variants + BOM data for
  /// pricing calculations when the product_code fetch returns Variants: null.
  /// Does NOT update provider state — caller stores the result themselves.
  Future<JewelleryDetail?> fetchByDesignno(String designno) async {
    if (designno.isEmpty) return null;

    final dio = ref.read(httpClientProvider);

    //debugPrint('🔍 Fetching by designno to customise store data : $designno');

    final response = await dio
        .post(
          ApiEndPoint.get_jewellery_Prodct,
          data: {'product_code': designno},
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Request timed out after 15s'),
        );

    longPrint(
      "📦 Jewellery Detail Second time Fetched Data: ${jsonEncode(response.data)}",
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

    // debugPrint(
    //   'price for $itemGroup $shape $color $quality  $slab : ${body['price']}',
    // );

    final price = body['price'];

    if (price is num) {
      return price.toDouble();
    }

    throw Exception('Invalid price response: $body');
  }

  // ✅ Static — safe to call from anywhere, no ref dependency
  static Future<double> fetchPriceStatic({
    required Dio dio,
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) async {
    final response = await dio.post(
      ApiEndPoint.get_price,
      data: {
        'itemgroup': itemGroup,
        'weight': (slab != null && slab.isNotEmpty)
            ? double.tryParse(slab)
            : null,
        'shape': (shape == null || shape.isEmpty) ? null : shape,
        'color': color,
        'quality': quality,
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch price');
    }
    final body = response.data;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid price response');
    }
    final price = body['price'];
    if (price is num) return price.toDouble();
    throw Exception('Invalid price response: $body');
  }

  void longPrint(Object? obj) {
    const chunkSize = 800;
    final str = obj.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      debugPrint(str.substring(i, end));
    }
  }
}

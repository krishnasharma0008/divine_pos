import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../data/solitaire_detail_model.dart';

final solitaireDetailProvider =
    AsyncNotifierProvider<SolitaireDetailNotifier, SolitaireDetail?>(
      SolitaireDetailNotifier.new,
    );

class SolitaireDetailNotifier extends AsyncNotifier<SolitaireDetail?> {
  @override
  Future<SolitaireDetail?> build() async {
    return null;
  }

  // ✅ FIX 2: seed the detail from the screen so calc provider can use it
  Future<void> setDetail(SolitaireDetail detail) async {
    state = AsyncData(detail);
  }

  /// Fetch solitaire price (single API call)
  Future<double> fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) async {
    try {
      final dio = ref.read(httpClientProvider);

      double? weight;
      if (slab != null && slab.isNotEmpty) {
        weight = double.tryParse(slab);
      }

      final response = await dio.post(
        ApiEndPoint.get_price,
        data: {
          'itemgroup': itemGroup,
          'weight': weight,
          'shape': (shape == null || shape.isEmpty) ? null : shape,
          'color': color,
          'quality': quality,
        },
      );

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Failed to fetch solitaire price');
      }

      final body = response.data;
      longPrint(body);

      if (body == null || body['success'] != true) {
        throw Exception('Invalid price response');
      }

      final price = body['price'];
      if (price is num) return price.toDouble();

      throw Exception('Invalid price response: $body');
    } on DioException catch (e) {
      debugPrint("❌ Dio error: ${e.message}");
      throw Exception('Network error while fetching price');
    } catch (e) {
      debugPrint("❌ Price fetch error: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Step 3 — POST to cart API (inlined from CartNotifier.createCart)
  // ---------------------------------------------------------------------------

  // Future<void> _createCart(CartDetail item) async {

  //   final response = await _dio
  //       .post(ApiEndPoint.create_cart, data: [item.toJson()])
  //       .timeout(
  //         const Duration(seconds: 15),
  //         onTimeout: () => throw TimeoutException('Create cart timed out'),
  //       );

  //   if (response.statusCode != HttpStatus.ok) {
  //     throw HttpException('HTTP ${response.statusCode}');
  //   }

  //   final body = response.data as Map<String, dynamic>?;
  //   if (body == null || body['success'] != true) {
  //     throw Exception(body?['msg'] ?? 'Failed to create cart');
  //   }
  // }

  // Future<void> createCartFromRows({
  //   required List<Jewellery> rows,
  //   required CustomerDetail? customerOrder,
  //   required int customerid,
  //   required String customercode,
  //   required String customername,
  //   required String branch,
  // }) async {
  //   state = const AsyncData(AddToCartState(status: AddToCartStatus.loading));

  //   try {
  //     final validRows = rows.where(
  //       (row) =>
  //           row.shape != null &&
  //           row.weight != null &&
  //           row.color != null &&
  //           row.clarity != null,
  //     );

  //     final List<CartDetail> payloads = validRows.map((row) {
  //       final co = customerOrder;

  //       return CartDetail(
  //         orderFor: 'Customer',
  //         customerId: customerid, // co?.id ?? 0,
  //         customerCode: customercode,
  //         customerName: customername,
  //         customerBranch: branch,
  //         productType: 'Solitaire',
  //         orderType: 'RCO',
  //         collection: '',
  //         productCategory: '',
  //         productSubCategory: '',
  //         style: '',
  //         wearStyle: '',
  //         look: '',
  //         portfolioType: '',
  //         expDlvDate: DateTime.now()
  //             .add(const Duration(days: 15))
  //             .toUtc()
  //             .toIso8601String(),
  //         oldVarient: '',
  //         productCode: row.itemNumber ?? '',
  //         designno: row.designno ?? '',
  //         solitairePcs: row.pcs,
  //         productQty: row.pcs,
  //         productAmtMin: (row.pcs ?? 0) * (row.price ?? 0) * row.weight!,
  //         productAmtMax: (row.pcs ?? 0) * (row.price ?? 0) * row.weight!,
  //         solitaireShape: row.shape ?? '',
  //         solitaireSlab: row.weight.toString() ?? '',
  //         solitaireColor: '${row.color ?? ''} - ${row.color ?? ''}',
  //         solitaireQuality: '${row.clarity ?? ''} - ${row.clarity ?? ''}',
  //         solitairePremSize: '',
  //         solitairePremPct: 0,
  //         solitaireAmtMin: (row.pcs ?? 0) * (row.price ?? 0) * row.weight!,
  //         solitaireAmtMax: (row.pcs ?? 0) * (row.price ?? 0) * row.weight!,
  //         metalType: '',
  //         metalPurity: '',
  //         metalColor: '',
  //         metalWeight: 0,
  //         metalPrice: 0,
  //         mountAmtMin: 0,
  //         mountAmtMax: 0,
  //         sizeFrom: '-',
  //         sizeTo: '-',
  //         sideStonePcs: 0,
  //         sideStoneCts: 0,
  //         sideStoneColor: '',
  //         sideStoneQuality: '',
  //         cartRemarks: '',
  //         orderRemarks: '',
  //         end_customer_id: co?.id ?? 0,
  //         end_customer_name: co?.name ?? '',
  //       );
  //     }).toList();

  //     if (payloads.isEmpty) {
  //       throw Exception('No valid rows to create cart');
  //     }

  //     debugPrint('data : ${payloads.map((p) => p.toJson()).toList()}');
  //     final response = await _dio
  //         .post(
  //           ApiEndPoint.create_cart,
  //           data: payloads.map((p) => p.toJson()).toList(),
  //         )
  //         .timeout(
  //           const Duration(seconds: 15),
  //           onTimeout: () => throw TimeoutException('Create cart timed out'),
  //         );

  //     if (response.statusCode != HttpStatus.ok) {
  //       throw HttpException('HTTP ${response.statusCode}');
  //     }

  //     final body = response.data as Map<String, dynamic>?;
  //     if (body == null || body['success'] != true) {
  //       throw Exception(body?['msg'] ?? 'Failed to create cart');
  //     }

  //     // ✅ This is what was missing
  //     state = const AsyncData(AddToCartState(status: AddToCartStatus.success));
  //   } on TimeoutException {
  //     state = const AsyncData(
  //       AddToCartState(
  //         status: AddToCartStatus.error,
  //         errorMessage: 'Request timed out. Please try again.',
  //       ),
  //     );
  //   } on HttpException catch (e) {
  //     state = AsyncData(
  //       AddToCartState(
  //         status: AddToCartStatus.error,
  //         errorMessage: 'Network error: ${e.message}',
  //       ),
  //     );
  //   } catch (e, st) {
  //     debugPrint('createCartFromRows error: $e\n$st');
  //     state = AsyncData(
  //       AddToCartState(
  //         status: AddToCartStatus.error,
  //         errorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }

  void longPrint(Object? obj) {
    const chunkSize = 800;
    final str = obj.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      debugPrint(str.substring(i, end));
    }
  }
}

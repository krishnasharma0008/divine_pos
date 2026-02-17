import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/http_client.dart';
import '../../../shared/utils/api_endpointen.dart';
import '../../jewellery_customize/data/jewellery_detail_model.dart';
import '../../jewellery/service/jewellery_calculation_service.dart';
import '../../cart/data/cart_detail_model.dart';
import '../../cart/data/customer_detail_model.dart';

// =============================================================================
// State
// =============================================================================

enum AddToCartStatus { idle, loading, success, error }

class AddToCartState {
  const AddToCartState({this.status = AddToCartStatus.idle, this.errorMessage});

  final AddToCartStatus status;
  final String? errorMessage;

  bool get isLoading => status == AddToCartStatus.loading;
  bool get isSuccess => status == AddToCartStatus.success;
  bool get isError => status == AddToCartStatus.error;

  AddToCartState copyWith({AddToCartStatus? status, String? errorMessage}) {
    return AddToCartState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

// =============================================================================
// Provider  (Riverpod 3.x — plain AsyncNotifierProvider)
// =============================================================================

final addToCartProvider =
    AsyncNotifierProvider<AddToCartNotifier, AddToCartState>(
      AddToCartNotifier.new,
    );

// =============================================================================
// Notifier
// =============================================================================

class AddToCartNotifier extends AsyncNotifier<AddToCartState> {
  /// Captured ONCE in build() synchronously.
  /// Never re-read via ref after any await — this eliminates all
  /// "Ref disposed" crashes no matter how many awaits follow.
  late final Dio _dio;

  @override
  Future<AddToCartState> build() async {
    _dio = ref.read(httpClientProvider); // ✅ sync — safe
    return const AddToCartState();
  }

  // ---------------------------------------------------------------------------
  // Public entry point
  // ---------------------------------------------------------------------------

  Future<void> addToCart({
    required String productCode,
    //required String designno,
    required String branch,
    required CustomerDetail customer,
  }) async {
    if (productCode.isEmpty || branch.isEmpty) return;

    state = const AsyncData(AddToCartState(status: AddToCartStatus.loading));

    try {
      final detail = await _fetchDetail(productCode, branch);
      final cartItem = await _buildCartPayload(
        detail: detail,
        customer: customer,
        branch: branch,
        //designno: designno,
      );
      await _createCart(cartItem);

      state = const AsyncData(AddToCartState(status: AddToCartStatus.success));
    } on TimeoutException {
      state = const AsyncData(
        AddToCartState(
          status: AddToCartStatus.error,
          errorMessage: 'Request timed out. Please try again.',
        ),
      );
    } on HttpException catch (e) {
      state = AsyncData(
        AddToCartState(
          status: AddToCartStatus.error,
          errorMessage: 'Network error: ${e.message}',
        ),
      );
    } catch (e, st) {
      debugPrint('AddToCart error: $e\n$st');
      state = AsyncData(
        AddToCartState(
          status: AddToCartStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() => state = const AsyncData(AddToCartState());

  // ---------------------------------------------------------------------------
  // Step 1 — Fetch jewellery detail
  // ---------------------------------------------------------------------------

  Future<JewelleryDetail> _fetchDetail(
    String productCode,
    String branch,
  ) async {
    final response = await _dio
        .post(
          ApiEndPoint.get_jewellery_Prodct,
          data: {'product_code': productCode, 'laying_with': branch},
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Detail fetch timed out'),
        );

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}');
    }

    final body = response.data as Map<String, dynamic>?;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid response from server');
    }

    final data = body['data'];
    if (data == null) throw Exception('Jewellery detail not found');

    return JewelleryDetail.fromJson(data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Step 2a — Fetch a single price
  // ---------------------------------------------------------------------------

  Future<double> _fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) async {
    final response = await _dio
        .post(
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
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('Price fetch timed out for $itemGroup'),
        );

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch price for $itemGroup');
    }

    final body = response.data as Map<String, dynamic>?;
    if (body == null || body['success'] != true) {
      throw Exception('Invalid price response for $itemGroup');
    }

    final price = body['price'];
    if (price is num) return price.toDouble();
    throw Exception('Unexpected price format: $body');
  }

  // ---------------------------------------------------------------------------
  // Step 2b — Calculate metal amount (gold + platinum)
  // ---------------------------------------------------------------------------

  Future<double> _calcMetalAmount({
    required JewelleryDetail detail,
    required String metalColor,
    required String metalPurity,
    required double goldWeight,
    required double platinumWeight,
  }) async {
    if (metalColor.isEmpty || metalPurity.isEmpty) return 0.0;

    final goldColor = metalColor.contains('+')
        ? JewelleryCalculationService.getMetalColor('GOLD', metalColor)
        : metalColor;

    double goldPrice = 0;
    double platinumPrice = 0;

    if (goldWeight > 1) {
      goldPrice = await _fetchPrice(
        itemGroup: 'GOLD',
        color: goldColor,
        quality: JewelleryCalculationService.getValidPurity(
          'gold',
          metalPurity,
        ),
      );
    } else if (goldWeight > 0 && goldWeight <= 1) {
      // <= 1 gm: use flat price from detail
      goldPrice = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    debugPrint(
      'Gold weight: $goldWeight | price: $goldPrice | color: $goldColor | '
      'purity: ${JewelleryCalculationService.getValidPurity('gold', metalPurity)}',
    );

    if (platinumWeight > 0) {
      platinumPrice = await _fetchPrice(
        itemGroup: 'PLATINUM',
        color: JewelleryCalculationService.getMetalColor(
          'PLATINUM',
          metalColor,
        ),
        quality: metalPurity,
      );
    }

    double goldAmount = goldWeight > 0 ? goldWeight * goldPrice : 0;
    // <= 1 gm rule: override with flat price
    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    final platinumAmount = platinumWeight > 0
        ? platinumWeight * platinumPrice
        : 0;

    return goldAmount + platinumAmount;
  }

  // ---------------------------------------------------------------------------
  // Step 2c — Orchestrate all price fetches and build CartDetail
  // ---------------------------------------------------------------------------

  Future<CartDetail> _buildCartPayload({
    required JewelleryDetail detail,
    required CustomerDetail customer,
    required String branch,
    //required String designno,
  }) async {
    // Solitaire details (sync) ------------------------------------------------
    final sol = JewelleryCalculationService.getSolitaireDetails(
      bom: detail.bom,
    );

    final String shapeCode = sol['shapeCode'] as String;
    final double caratFrom = sol['caratFrom'] as double;
    final double caratTo = sol['caratTo'] as double;
    final String colorFrom = sol['colorFrom'] as String;
    final String colorTo = sol['colorTo'] as String;
    final String clarityFrom = sol['clarityFrom'] as String;
    final String clarityTo = sol['clarityTo'] as String;

    // Metal details (sync) ----------------------------------------------------
    final metalColor = (detail.metalColor ?? '').split(',').first.trim();
    final metalPurity = (detail.metalPurity ?? '').split(',').first.trim();
    final goldWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'GOLD',
      'METAL',
    );
    final platWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'PLATINUM',
      'METAL',
    );
    final netMetalWt = JewelleryCalculationService.getNetMetalWeight(
      detail.bom,
    );

    // Side diamond details (sync) ---------------------------------------------
    final sideWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'DIAMOND',
      'STONE',
    );
    final sidePcs = JewelleryCalculationService.getPcs(
      detail.bom,
      'DIAMOND',
      'STONE',
    );

    // Solitaire pcs (sync) ----------------------------------------------------
    final totalSolPcs = JewelleryCalculationService.getPcs(
      detail.bom,
      'SOLITAIRE',
      'STONE',
    );

    // =========================================================================
    // Async price fetches — all via _dio, zero ref usage
    // =========================================================================

    // 1. Metal
    final metalAmount = await _calcMetalAmount(
      detail: detail,
      metalColor: metalColor,
      metalPurity: metalPurity,
      goldWeight: goldWeight,
      platinumWeight: platWeight,
    );
    final perGram = netMetalWt > 0 ? metalAmount / netMetalWt : 0.0;

    // 2. Side diamond
    final sidePrice = await _fetchPrice(
      itemGroup: 'DIAMOND',
      color: 'IJ',
      quality: 'SI',
    );
    final sideDiamond = sideWeight * sidePrice;

    // 3. Solitaire from
    final rateFrom = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: caratFrom.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(colorFrom),
      quality: clarityFrom,
    );

    // 4. Solitaire to
    final rateTo = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: caratTo.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(colorTo),
      quality: clarityTo,
    );

    // Final calculations (sync) -----------------------------------------------
    final solFrom = rateFrom * caratFrom * totalSolPcs;
    final solTo = rateTo * caratTo * totalSolPcs;

    debugPrint(
      '💰 metal: $metalAmount | perGram: $perGram | '
      'side: $sideDiamond | solFrom: $solFrom | solTo: $solTo',
    );

    // Build payload -----------------------------------------------------------
    return CartDetail(
      orderFor: 'Retail Customer',
      customerId: customer.id,
      customerCode: '',
      customerName: customer.name,
      customerBranch: branch,
      productType: 'jewellery',
      orderType: 'RCO',
      productCategory: detail.productCategory,
      productSubCategory: detail.productSubCategory,
      collection: detail.collection,
      expDlvDate: DateTime.now()
          .add(const Duration(days: 15))
          .toUtc()
          .toIso8601String(),
      oldVarient: detail.oldVariant,
      productCode: detail.itemNumber,
      designno: detail.designno, // designno, // design no
      solitairePcs: totalSolPcs,
      productQty: 1,
      productAmtMin: detail.productPrice?.toDouble(),
      productAmtMax: detail.productPrice?.toDouble(),
      solitaireShape: JewelleryCalculationService.mapShapeCodeToName(shapeCode),
      solitaireSlab: '$caratFrom-$caratTo',
      solitaireColor: '$colorFrom-$colorTo',
      solitaireQuality: '$clarityFrom-$clarityTo',
      solitairePremSize: '',
      solitairePremPct: 0,
      solitaireAmtMin: solFrom.roundToDouble(),
      solitaireAmtMax: solTo.roundToDouble(),
      metalType: metalPurity == '950PT' ? 'PLATINUM' : 'GOLD',
      metalPurity: metalPurity,
      metalColor: metalColor,
      metalWeight: netMetalWt,
      metalPrice: perGram.roundToDouble(),
      mountAmtMin: (metalAmount + sideDiamond).roundToDouble(),
      mountAmtMax: (metalAmount + sideDiamond).roundToDouble(),
      sizeFrom: detail.productSizeFrom,
      sizeTo: detail.productSizeTo,
      sideStonePcs: sidePcs,
      sideStoneCts: sideWeight,
      sideStoneColor: 'IJ',
      sideStoneQuality: 'SI',
      cartRemarks: '',
      orderRemarks: '',
      style: detail.style,
      wearStyle: detail.wearStyle,
      look: detail.look,
      portfolioType: detail.portfolioType,
      gender: detail.gender,
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 — POST to cart API (inlined from CartNotifier.createCart)
  // ---------------------------------------------------------------------------

  Future<void> _createCart(CartDetail item) async {
    final response = await _dio
        .post(ApiEndPoint.create_cart, data: [item.toJson()])
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Create cart timed out'),
        );

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}');
    }

    final body = response.data as Map<String, dynamic>?;
    if (body == null || body['success'] != true) {
      throw Exception(body?['msg'] ?? 'Failed to create cart');
    }
  }
}

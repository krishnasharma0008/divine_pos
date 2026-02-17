import 'package:dio/dio.dart';
import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/cart/data/cart_detail_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery/data/filter_provider.dart';
import 'package:divine_pos/features/jewellery/data/listing_provider.dart';
import 'package:divine_pos/features/jewellery_customize/provider/jewellery_notifier.dart';
import 'package:divine_pos/shared/utils/http_client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jewellery_customize/data/jewellery_detail_model.dart';
import '../service/jewellery_calculation_service.dart';
import '../../jewellery_customize/data/jewellery_calc_state.dart';

final jewelleryCalcProvider =
    AsyncNotifierProvider<JewelleryCalcNotifier, JewelleryCalcState>(
      JewelleryCalcNotifier.new,
    );

class JewelleryCalcNotifier extends AsyncNotifier<JewelleryCalcState> {
  late Dio _dio; // ✅ captured once, never re-read via ref

  @override
  Future<JewelleryCalcState> build() async {
    _dio = ref.read(httpClientProvider);

    // ✅ ADD THIS — tells you exactly when and why it's disposed
    ref.onDispose(() {
      debugPrint('⚠️ jewelleryCalcProvider DISPOSED — stack:');
      debugPrint(StackTrace.current.toString());
    });

    return const JewelleryCalcState();
  }

  // ✅ Uses _dio directly — zero ref dependency
  Future<double> _fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) {
    return JewelleryDetailNotifier.fetchPriceStatic(
      dio: _dio,
      itemGroup: itemGroup,
      slab: slab,
      shape: shape,
      color: color,
      quality: quality,
    );
  }

  Future<void> loadDetail(String productCode, String branch) async {
    if (!ref.mounted) return;

    // ✅ capture notifier before await
    final detailNotifier = ref.read(jewelleryDetailProvider.notifier);
    final detail = await detailNotifier.fetchDetail(productCode, branch);

    if (!ref.mounted) return;
    if (detail == null) return;

    final current = state.value ?? const JewelleryCalcState();
    state = AsyncData(current.copyWith(detail: detail));

    if (!ref.mounted) return;
    await _recalculatePrice();
  }

  Future<void> _recalculatePrice() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || current.detail == null) return;
    final detail = current.detail!;

    // --- sync setup ---
    final solitaireDetails = JewelleryCalculationService.getSolitaireDetails(
      bom: detail.bom,
    );

    final String shapeCode = solitaireDetails['shapeCode'] as String;
    final double caratFrom = solitaireDetails['caratFrom'] as double;
    final double caratTo = solitaireDetails['caratTo'] as double;
    final String colorFrom = solitaireDetails['colorFrom'] as String;
    final String colorTo = solitaireDetails['colorTo'] as String;
    final String clarityFrom = solitaireDetails['clarityFrom'] as String;
    final String clarityTo = solitaireDetails['clarityTo'] as String;

    final String caratRange = '$caratFrom-$caratTo';
    final String colorRange = '$colorFrom-$colorTo';
    final String clarityRange = '$clarityFrom-$clarityTo';
    final String shapeName = JewelleryCalculationService.mapShapeCodeToName(
      shapeCode,
    );

    final goldWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'GOLD',
      'METAL',
    );
    final platinumWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'PLATINUM',
      'METAL',
    );
    final activeMetalColor = detail.metalColor.split(',').first.trim();
    final activeMetalPurity = detail.metalPurity.split(',').first.trim();

    // --- async calls — guarded after each ---
    final metalAmount = await _calculateMetalAmountFromApi(
      detail: detail,
      metalColor: activeMetalColor,
      metalPurity: activeMetalPurity,
      goldWeight: goldWeight,
      platinumWeight: platinumWeight,
      qty: current.selectedQty,
    );
    if (!ref.mounted) return; // ✅

    final netMetalWeight = JewelleryCalculationService.getNetMetalWeight(
      detail.bom,
    );
    final perGram = (netMetalWeight) > 0 ? metalAmount / netMetalWeight : 0.0;

    final totalSidePcs = JewelleryCalculationService.getPcs(
      detail.bom,
      'DIAMOND',
      'STONE',
    );
    final totalSideWeight = JewelleryCalculationService.getWeight(
      detail.bom,
      'DIAMOND',
      'STONE',
    );
    final sideParts = (current.selectedSideDiamondQuality ?? 'IJ-SI').split(
      '-',
    );

    final double sidePrice = await _fetchPrice(
      itemGroup: 'DIAMOND',
      slab: '',
      shape: '',
      color: sideParts.isNotEmpty ? sideParts[0] : null,
      quality: sideParts.length > 1 ? sideParts[1] : null,
    );
    if (!ref.mounted) return; // ✅

    final sideDiamond =
        await JewelleryCalculationService.calculateSideDiamondPrice(
          price: sidePrice,
          totalSideCts: totalSideWeight,
          qty: current.selectedQty,
        );
    if (!ref.mounted) return; // ✅

    final totalSolitairePcs = JewelleryCalculationService.getPcs(
      detail.bom,
      'SOLITAIRE',
      'STONE',
    );

    double parseCt(String s) => double.tryParse(s.trim()) ?? 0.10;
    final minCt = current.caratRange == null
        ? parseCt('0.18')
        : parseCt(caratRange.replaceAll('ct', '').split('-').first);
    final maxCt = current.caratRange == null
        ? parseCt('0.22')
        : parseCt(caratRange.replaceAll('ct', '').split('-').last);

    final double rateFrom = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(colorFrom),
      quality: clarityFrom,
    );
    if (!ref.mounted) return; // ✅

    final double rateTo = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(colorTo),
      quality: clarityTo,
    );
    if (!ref.mounted) return; // ✅

    final pcs = totalSolitairePcs;
    final solFrom = rateFrom * minCt * pcs * current.selectedQty;
    final solTo = rateTo * maxCt * pcs * current.selectedQty;

    state = AsyncData(
      current.copyWith(
        solitaireShape: shapeName,
        caratRange: caratRange,
        colorRange: colorRange,
        clarityRange: clarityRange,
        totalSolitairePcs: totalSolitairePcs,
        netMetalWeight: netMetalWeight,
        metalAmount: metalAmount,
        metalprice: perGram,
        totalSidePcs: totalSidePcs,
        totalSideWeight: totalSideWeight,
        sideDiamondAmount: sideDiamond,
        solitaireAmountFrom: solFrom,
        solitaireAmountTo: solTo,
        approxPriceFrom: metalAmount + sideDiamond + solFrom,
        approxPriceTo: metalAmount + sideDiamond + solTo,
      ),
    );
  }

  Future<double> _calculateMetalAmountFromApi({
    required JewelleryDetail detail,
    required String metalColor,
    required String metalPurity,
    required double goldWeight,
    required double platinumWeight,
    required int qty,
  }) async {
    if (metalColor.isEmpty || metalPurity.isEmpty) return 0.0;

    final goldColor = metalColor.contains('+')
        ? JewelleryCalculationService.getMetalColor('GOLD', metalColor)
        : metalColor;
    final selectedQty = qty > 0 ? qty : 1;

    double goldPrice = 0;
    double platinumPrice = 0;

    if (goldWeight > 1) {
      goldPrice = await _fetchPrice(
        // ✅ uses _dio
        itemGroup: 'GOLD',
        slab: '',
        shape: '',
        color: goldColor,
        quality: JewelleryCalculationService.getValidPurity(
          'gold',
          metalPurity,
        ),
      );
    } else if (goldWeight > 0 && goldWeight <= 1) {
      goldPrice = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    if (platinumWeight > 0) {
      final platinumColor = JewelleryCalculationService.getMetalColor(
        'PLATINUM',
        metalColor,
      );
      platinumPrice = await _fetchPrice(
        // ✅ uses _dio
        itemGroup: 'PLATINUM',
        slab: '',
        shape: '',
        color: platinumColor,
        quality: metalPurity,
      );
    }

    double goldAmount = goldWeight > 0
        ? goldWeight * goldPrice * selectedQty
        : 0;
    final platinumAmount = platinumWeight > 0
        ? platinumWeight * platinumPrice * selectedQty
        : 0;

    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    return goldAmount + platinumAmount;
  }

  //customer branch
  Future<String> resolveCustomerBranch() async {
    final filterState = ref.read(filterProvider);

    final selectedBranch = filterState.productBranch;
    if (selectedBranch?.isNotEmpty == true) {
      return selectedBranch!;
    }

    final auth = ref.read(authProvider);
    final pjcode = auth.user?.pjcode ?? '';
    final storeState = ref.read(storeProvider);

    // reuse cached store if already fetched
    if (storeState.selectedStore?.nickName != null) {
      return storeState.selectedStore!.nickName!;
    }

    if (pjcode.isNotEmpty) {
      await ref.read(storeProvider.notifier).getPJStore(pjcode: pjcode);
      return ref.read(storeProvider).selectedStore?.nickName ?? '';
    }

    return '';
  }

  Future<CartDetail?> buildCartPayload({
    required CustomerDetail customer,
    required String branch,
  }) async {
    // from calc
    final s = state.value;
    if (s == null || s.detail == null) return null;

    final d = s.detail!; // from jewellery detail

    /// ---------- VALIDATIONS (same as JS) ----------
    if ((s.netMetalWeight ?? 0) <= 0) {
      throw Exception('Metal weight not calculated');
    }

    if ((s.metalAmount ?? 0) <= 0) {
      throw Exception('Metal amount not calculated');
    }

    if ((s.metalprice ?? 0) <= 0) {
      throw Exception('Metal price invalid');
    }

    if (d.currentStatus == 'Discarded') {
      throw Exception('Product Code is Discarded');
    }

    if (s.solitaireShape == null ||
        s.caratRange == null ||
        s.colorRange == null ||
        s.clarityRange == null) {
      throw Exception('Customise solitaire to add in cart');
    }

    debugPrint('Customer dETAILS: ${customer.name}, ${customer.id}');
    //final branch = await _resolveCustomerBranch();

    final dt = DateTime.now().add(const Duration(days: 15)).toUtc();

    /// ---------- BUILD PAYLOAD (mirror JS) ----------
    return CartDetail(
      // username: customer.name, // or login user
      // orderFrom: 'app',
      orderFor: 'Retail Customer',
      customerId: customer.id,
      customerCode: '',
      customerName: customer.name,
      customerBranch: branch,
      productType: 'jewellery',
      orderType: 'RCO',

      productCategory: d.productCategory,
      productSubCategory: d.productSubCategory,
      collection: d.collection,
      expDlvDate: DateTime.now()
          .add(const Duration(days: 15))
          .toUtc()
          .toIso8601String(),

      oldVarient: d.oldVariant,

      productCode: d.itemNumber,

      solitairePcs: s.totalSolitairePcs ?? 1, //
      productQty: s.selectedQty ?? 1,

      productAmtMin: d.productPrice?.toDouble(),

      productAmtMax: d.productPrice?.toDouble(),

      solitaireShape: s.solitaireShape ?? '',
      solitaireSlab: s.caratRange?.replaceAll('ct', '').replaceAll(' ', ''), //

      solitaireColor: s.colorRange,

      solitaireQuality: s.clarityRange,
      solitairePremSize: '', // not avaiable field in customise screen
      solitairePremPct: 0, // not avaiable field in customise screen

      solitaireAmtMin: (s.solitaireAmountFrom ?? 0).roundToDouble(),
      solitaireAmtMax: (s.solitaireAmountTo ?? 0).roundToDouble(),

      metalType: s.selectedMetalPurity == '950PT' ? 'PLATINUM' : 'GOLD',
      metalPurity: s.selectedMetalPurity ?? '',
      metalColor: s.selectedMetalColor ?? '',
      metalWeight: s.netMetalWeight ?? 0,

      metalPrice: (s.metalprice ?? 0).roundToDouble(),

      mountAmtMin: (((s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0)))
          .roundToDouble(),
      mountAmtMax: (((s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0)))
          .roundToDouble(),

      sizeFrom: s.ringSize,
      sizeTo: null,

      sideStonePcs: s.totalSidePcs ?? 0,
      sideStoneCts: s.totalSideWeight ?? 0,
      sideStoneColor: (s.selectedSideDiamondQuality ?? '').split('-').first,
      sideStoneQuality: (s.selectedSideDiamondQuality ?? '').split('-').last,
      cartRemarks: '',
      orderRemarks: '',
      //imageUrl: '',
      style: d.style,
      wearStyle: d.wearStyle,
      look: d.look,
      portfolioType: d.portfolioType,
      gender: d.gender,
    );
  }
}

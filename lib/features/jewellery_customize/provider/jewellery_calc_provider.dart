import 'package:divine_pos/features/auth/data/auth_notifier.dart';
import 'package:divine_pos/features/cart/data/cart_detail_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:divine_pos/features/jewellery/data/filter_provider.dart';
import 'package:divine_pos/features/jewellery/data/listing_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/jewellery_detail_model.dart';
import '../data/jewellery_filter.dart';
import '../services/jewellery_calculation_service.dart';
import '../data/jewellery_calc_state.dart';
import '../provider/jewellery_detail_provider.dart';

/// AsyncNotifier provider that keeps all pricing / filter state
final jewelleryCalcProvider =
    AsyncNotifierProvider.autoDispose<
      JewelleryCalcNotifier,
      JewelleryCalcState
    >(JewelleryCalcNotifier.new);

class JewelleryCalcNotifier extends AsyncNotifier<JewelleryCalcState> {
  @override
  Future<JewelleryCalcState> build() async {
    // start with empty state
    return const JewelleryCalcState();
  }

  /// Load detail from API and trigger initial price calculation
  Future<void> loadDetail(String productCode) async {
    final detailNotifier = ref.read(jewelleryDetailProvider.notifier);
    await detailNotifier.fetchJewelleryDetail(productCode);

    final detail = ref.read(jewelleryDetailProvider).value;
    if (detail == null) return;

    final current = state.value ?? const JewelleryCalcState();
    state = AsyncData(current.copyWith(detail: detail));
    await _recalculatePrice();
  }

  /// Apply filters coming back from CustomizeSolitaire (JewelleryFilter)
  void applyFilter(JewelleryFilter filter) {
    final current = state.value;
    if (current == null) return;

    final priceRange = filter.price != null
        ? '₹${filter.price!.startValue} - ${filter.price!.endValue}'
        : null;

    final caratRange = filter.carat != null
        ? '${filter.carat!.startValue} - ${filter.carat!.endValue} ct'
        : null;

    final updated = current.copyWith(
      ringSize: filter.ringSize,
      selectedMetalColor: filter.metalColor,
      selectedMetalPurity: filter.metalPurity,
      selectedSideDiamondQuality: filter.sideDiamondQuality,
      priceRange: priceRange,
      caratRange: caratRange,
      colorRange: filter.color?.displayRange,
      clarityRange: filter.clarity?.displayRange,
    );

    state = AsyncData(updated);
    _recalculatePrice();
  }

  /// Call price API via JewelleryDetailNotifier
  Future<double> _fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) {
    debugPrint(
      'Fetching price for $itemGroup with slab: $slab, shape: $shape, color: $color, quality: $quality',
    );

    return ref
        .read(jewelleryDetailProvider.notifier)
        .fetchPrice(
          itemGroup: itemGroup,
          slab: slab,
          shape: shape,
          color: color,
          quality: quality,
        );
  }

  /// Main pricing calculation, ported from screen
  Future<void> _recalculatePrice() async {
    final current = state.value;
    if (current == null || current.detail == null) return;
    final detail = current.detail!;

    // 1) BASE SIZE & CARAT
    final base = JewelleryCalculationService.getBaseSizeCarat(detail);
    final baseSize = current.baseSize ?? base.baseSize;
    final baseCarat = current.baseCarat ?? base.baseCarat;
    final ringSize = current.ringSize ?? baseSize?.toStringAsFixed(0);

    // 2) DEFAULT SOLITAIRE SHAPE
    final shapeCode = JewelleryCalculationService.getDefaultSolitaireShapeCode(
      variants: detail.variants,
      bom: detail.bom,
    );

    final get_shape = JewelleryCalculationService.mapShapeCodeToName(shapeCode);

    // 3) METAL WEIGHTS
    final goldWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'GOLD',
      'METAL',
    );
    final platinumWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'PLATINUM',
      'METAL',
    );

    // 4) METAL AMOUNT
    final activeMetalColor =
        current.selectedMetalColor ?? detail.metalColor.split(',').first.trim();
    final activeMetalPurity =
        current.selectedMetalPurity ??
        detail.metalPurity.split(',').first.trim();
    debugPrint(
      'Active metal color: $activeMetalColor, purity: $activeMetalPurity',
    );

    final metal = await _calculateMetalAmountFromApi(
      detail: detail,
      metalColor: activeMetalColor,
      metalPurity: activeMetalPurity,
      goldWeight: goldWeight,
      platinumWeight: platinumWeight,
      qty: current.selectedQty,
    );

    debugPrint('Calculated metal amount: $metal');

    final netMetalWeight = JewelleryCalculationService.getNetMetalWeight(
      detail.variants,
      detail.bom,
    );

    final perGram = (netMetalWeight ?? 0) > 0
        ? metal / (netMetalWeight ?? 1)
        : 0.0;

    // 5) SIDE DIAMOND
    final totalSidePcs = JewelleryCalculationService.getPcs(
      detail.variants,
      detail.bom,
      'DIAMOND',
      'STONE',
    );
    final totalSideWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'DIAMOND',
      'STONE',
    );

    final sideParts = (current.selectedSideDiamondQuality ?? 'IJ-SI').split(
      '-',
    );

    final double sideprice = await _fetchPrice(
      itemGroup: 'DIAMOND',
      slab: '',
      shape: '',
      color: sideParts.isNotEmpty ? sideParts[0] : null,
      quality: sideParts.length > 1 ? sideParts[1] : null,
    );

    final sideDiamond =
        await JewelleryCalculationService.calculateSideDiamondPrice(
          price: sideprice,
          totalSideCts: (totalSideWeight?.toDouble() ?? 0.0),
          qty: current.selectedQty,
        );

    // 6) SOLITAIRE SELECTION (use filter range when present)
    final caratFromStr = baseCarat ?? '0.10';

    double parseCt(String s) => double.tryParse(s.trim()) ?? 0.10;

    double getMinCt() {
      if (current.caratRange == null) return parseCt('0.18');
      final parts = current.caratRange!
          .replaceAll('ct', '')
          .split('-')
          .map((e) => e.trim())
          .toList();
      if (parts.length < 2) return parseCt('0.18');
      return parseCt(parts.first);
    }

    double getMaxCt() {
      if (current.caratRange == null) return parseCt('0.22');
      final parts = current.caratRange!
          .replaceAll('ct', '')
          .split('-')
          .map((e) => e.trim())
          .toList();
      if (parts.length < 2) return getMinCt();
      return parseCt(parts.last);
    }

    final double minCt = getMinCt();
    final double maxCt = getMaxCt();

    // COLOR & CLARITY: from = left, to = right in "D - H"
    final selectedColorFrom = current.colorRange != null
        ? current.colorRange!.split('-').first.trim()
        : 'G';
    final selectedColorTo = current.colorRange != null
        ? current.colorRange!.split('-').last.trim()
        : selectedColorFrom;

    final selectedClarityFrom = current.clarityRange != null
        ? current.clarityRange!.split('-').first.trim()
        : 'VS';
    final selectedClarityTo = current.clarityRange != null
        ? current.clarityRange!.split('-').last.trim()
        : selectedClarityFrom;

    // 7) TOTAL SOLITAIRE PCS
    final totalSolitairePcs = JewelleryCalculationService.getPcs(
      detail.variants ?? [],
      detail.bom ?? [],
      'SOLITAIRE',
      'STONE',
    );

    // // 8) BASIC SOLITAIRE RATE
    // final double rateFromPerCtRaw = await _fetchPrice(
    //   itemGroup: 'SOLITAIRE',
    //   slab: minCt.toStringAsFixed(2),
    //   shape: shapeCode,
    //   color: selectedColorTo,
    //   quality: selectedClarityTo,
    // );

    // final double rateToPerCtRaw = await _fetchPrice(
    //   itemGroup: 'SOLITAIRE',
    //   slab: maxCt.toStringAsFixed(2),
    //   shape: shapeCode,
    //   color: selectedColorFrom,
    //   quality: selectedClarityFrom,
    // );

    // // 9) PREMIUM
    // const double premiumPct = 0.0;
    // final double rateFromWithPremium =
    //     rateFromPerCtRaw + rateFromPerCtRaw * (premiumPct / 100);
    // final double rateToWithPremium =
    //     rateToPerCtRaw + rateToPerCtRaw * (premiumPct / 100);

    // // 10) MULTI‑SIZE OR SINGLE‑SIZE SOLITAIRE
    // final int rowCount = JewelleryCalculationService.getSolitaireRowCount(
    //   detail.variants ?? [],
    //   detail.bom ?? [],
    // );

    // double solFrom = 0;
    // double solTo = 0;

    // if (rowCount > 1) {
    //   final result =
    //       JewelleryCalculationService.calculateSolitaireAmountRangeLocal(
    //         detail: detail,
    //         qty: current.selectedQty,
    //         rateFromPerCt: rateFromWithPremium,
    //         rateToPerCt: rateToWithPremium,
    //       );
    //   solFrom = result.solFrom;
    //   solTo = result.solTo;
    // } else {
    //   final pcs = (totalSolitairePcs ?? 0);
    //   final minAmountPerCt = rateFromWithPremium;
    //   final maxAmountPerCt = rateToWithPremium;

    //   solFrom = minAmountPerCt * minCt * pcs * current.selectedQty;
    //   solTo = maxAmountPerCt * maxCt * pcs * current.selectedQty;
    // }

    // 8) BASIC SOLITAIRE RATE (single-size के लिए)
    final double rateFromPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: selectedColorFrom,
      quality: selectedClarityFrom,
    );

    final double rateToPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: selectedColorTo,
      quality: selectedClarityTo,
    );

    // 9) PREMIUM
    final double premiumPct = 0.00; // currently 0, can be made dynamic later

    final double rateFromWithPremium =
        rateFromPerCtRaw + rateFromPerCtRaw * (premiumPct / 100);
    final double rateToWithPremium =
        rateToPerCtRaw + rateToPerCtRaw * (premiumPct / 100);

    // 10) MULTI‑SIZE OR SINGLE‑SIZE SOLITAIRE
    final int rowCount = JewelleryCalculationService.getSolitaireRowCount(
      detail.variants ?? [],
      detail.bom ?? [],
    );

    double solFrom = 0;
    double solTo = 0;

    if (rowCount > 1) {
      // MULTI‑SIZE: JS वाले BOM loop जैसा
      final result =
          await JewelleryCalculationService.calculateSolitaireAmountRangeLocal(
            detail: detail,
            qty: current.selectedQty,
            premiumPct: premiumPct,
            fetchPrice:
                ({
                  required String itemGroup,
                  String? slab,
                  String? shape,
                  String? color,
                  String? quality,
                }) {
                  return _fetchPrice(
                    itemGroup: itemGroup,
                    slab: slab,
                    shape: shape,
                    color: color,
                    quality: quality,
                  );
                },
            userMinCt: minCt, // JS: parseFloat(carat[0])
            userColorFrom: selectedColorFrom,
            userColorTo: selectedColorTo,
            userClarityFrom: selectedClarityFrom,
            userClarityTo: selectedClarityTo,
          );
      solFrom = result.solFrom;
      solTo = result.solTo;
    } else {
      // SINGLE‑SIZE (तुम्हारा पुराना logic ही)
      final pcs = (totalSolitairePcs ?? 0);
      final minAmountPerCt = rateFromWithPremium;
      final maxAmountPerCt = rateToWithPremium;

      solFrom = minAmountPerCt * minCt * pcs * current.selectedQty;
      solTo = maxAmountPerCt * maxCt * pcs * current.selectedQty;
    }

    // 11) DIVINE MOUNT ADJUSTMENT
    if (detail.productSizeFrom != '-' && baseSize != null) {
      final currentSize = double.tryParse(ringSize ?? '') ?? baseSize;
      final factor = JewelleryCalculationService.calculateDivineMountAdjustment(
        carat: caratFromStr.trim(),
        size: currentSize,
        baseRingSize: baseSize,
        qty: current.selectedQty,
      );
      solFrom *= factor;
      solTo *= factor;
    }

    // 12) FINAL AMOUNTS
    final approxFrom = metal + sideDiamond + solFrom;
    final approxTo = metal + sideDiamond + solTo;

    final msg = JewelleryCalculationService.getMultiSolitaireMessage(
      variants: detail.variants,
      bom: detail.bom,
      totalPcs: totalSolitairePcs ?? 0,
    );

    final updated = current.copyWith(
      baseSize: baseSize,
      baseCarat: baseCarat,
      ringSize: ringSize,
      metalAmount: metal,
      netMetalWeight: netMetalWeight,
      metalprice: perGram,

      sideDiamondAmount: sideDiamond,
      solitaireAmountFrom: solFrom,
      solitaireAmountTo: solTo,
      approxPriceFrom: approxFrom,
      approxPriceTo: approxTo,

      totalSidePcs: totalSidePcs,
      totalSideWeight: totalSideWeight,
      totalSolitairePcs: totalSolitairePcs,
      solitaireMessage: msg.isEmpty ? null : msg,
      solitaireShape: get_shape,
    );

    state = AsyncData(updated);
  }

  /// Metal amount calculation (gold + platinum)
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

    // GOLD pricing
    if (goldWeight > 1) {
      goldPrice = await _fetchPrice(
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

    debugPrint(
      'Gold weight: $goldWeight, price: $goldPrice, color: $goldColor, purity: ${JewelleryCalculationService.getValidPurity('gold', metalPurity)}',
    );
    // PLATINUM pricing
    if (platinumWeight > 0) {
      final platinumColor = JewelleryCalculationService.getMetalColor(
        'PLATINUM',
        metalColor,
      );

      platinumPrice = await _fetchPrice(
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

    // <= 1 gm rule
    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    return goldAmount + platinumAmount;
  }

  //customer branch
  Future<String> _resolveCustomerBranch() async {
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

    /// ---------- BUILD PAYLOAD (mirror JS) ----------
    return CartDetail(
      orderFor: 'Retail Customer',
      customerId: customer.id,
      customerCode: '',
      customerName: customer.name,
      customerBranch: await _resolveCustomerBranch(),
      productType: 'jewellery',
      orderType: 'rco',

      productCategory: d.productCategory,
      productSubCategory: d.productSubCategory,
      collection: d.collection,
      expDlvDate: '',
      oldVarient: d.oldVariant,

      productCode: d.itemNumber,
      solitairePcs: s.totalSolitairePcs, //
      productQty: s.selectedQty,

      // productAmtMin: s.approxPriceFrom ?? 0, //product_amt_min
      // productAmtMax: s.approxPriceTo ?? 0, //product_amt_max
      productAmtMin: d.productPrice == null || d.productPrice == 0
          ? s.approxPriceFrom ?? 0
          : d.productPrice,

      productAmtMax: d.productPrice == null || d.productPrice == 0
          ? s.approxPriceTo ?? 0
          : d.productPrice,

      solitaireShape: s.solitaireShape ?? '',
      solitaireSlab: s.caratRange, //
      solitaireColor: s.colorRange,
      solitaireQuality: s.clarityRange,
      solitairePremSize: null, // not avaiable field in customise screen
      solitairePremPct: 0, // not avaiable field in customise screen
      solitaireAmtMin: s.solitaireAmountFrom ?? 0,
      solitaireAmtMax: s.solitaireAmountTo ?? 0,

      metalType: s.selectedMetalPurity == '950PT' ? 'PLATINUM' : 'GOLD',
      metalPurity: s.selectedMetalPurity ?? '',
      metalColor: s.selectedMetalColor ?? '',
      metalWeight: s.netMetalWeight ?? 0,
      metalPrice: s.metalprice,
      mountAmtMin: (s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0),
      mountAmtMax: (s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0),

      sizeFrom: s.ringSize,
      sizeTo: '-',

      sideStonePcs: s.totalSidePcs ?? 0,
      sideStoneCts: s.totalSideWeight ?? 0,
      sideStoneColor: (s.selectedSideDiamondQuality ?? '').split('-').first,
      sideStoneQuality: (s.selectedSideDiamondQuality ?? '').split('-').last,
      cartRemarks: '',
      orderRemarks: '',
      style: d.style,
      wearStyle: d.wearStyle,
      look: d.look,
      portfolioType: d.portfolioType,
      gender: d.gender,
    );
  }
}

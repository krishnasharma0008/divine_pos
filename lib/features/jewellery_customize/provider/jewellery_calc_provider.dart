import 'package:divine_pos/features/cart/data/cart_detail_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
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

  /// Main pricing calculation
  Future<void> _recalculatePrice() async {
    final current = state.value;
    if (current == null || current.detail == null) return;
    final detail = current.detail!;

    // 1) BASE SIZE & CARAT
    final base = JewelleryCalculationService.getBaseSizeCarat(detail);
    final baseSize = current.baseSize ?? base.baseSize;
    final baseCarat = current.baseCarat ?? base.baseCarat;
    final caratFromStr = baseCarat ?? '0.10';
    final ringSize = current.ringSize ?? baseSize?.toStringAsFixed(0);
    final currentSize = double.tryParse(ringSize ?? '') ?? (baseSize ?? 0);

    // 2) DEFAULT SOLITAIRE SHAPE
    final shapeCode = JewelleryCalculationService.getDefaultSolitaireShapeCode(
      variants: detail.variants,
      bom: detail.bom,
    );
    final getShape = JewelleryCalculationService.mapShapeCodeToName(shapeCode);

    // ─────────────────────────────────────────────────────────────
    // 2a) DERIVE INITIAL SOLITAIRE DEFAULTS FROM BOM
    // ─────────────────────────────────────────────────────────────
    String? bomDefaultCaratRange;
    String? bomDefaultColorRange;
    String? bomDefaultClarityRange;

    final activeVariant = detail.variants.firstWhere(
      (v) => v.isBaseVariant == true,
      orElse: () => detail.variants.first,
    );
    final activeVariantId = activeVariant.variantId;

    final bomList = detail.bom
        .where(
          (b) =>
              b.variantId == activeVariantId &&
              (b.itemGroup ?? '').trim().toUpperCase() == 'SOLITAIRE' &&
              (b.itemType ?? '').trim().toUpperCase() == 'STONE',
        )
        .toList();

    if (bomList.isNotEmpty) {
      final caratRangeParts = <String>[];
      final colorRangeParts = <String>[];
      final clarityRangeParts = <String>[];

      for (final row in bomList) {
        // bomVariantName: SOL-RND-0.10-0.13[-color-clarity]
        final parts = row.bomVariantName
            .split('-')
            .map((e) => e.trim())
            .toList();

        if (parts.length < 4) continue;

        final caratFrom = parts[2]; // '0.10'
        final caratTo = parts[3]; // '0.13'
        final caratFromVal = double.tryParse(caratFrom) ?? 0.0;
        final caratToVal = double.tryParse(caratTo) ?? 0.0;

        caratRangeParts.add('$caratFrom-$caratTo');

        // Color/clarity — from BOM name if present, else carat fallback
        final bomColor = parts.length >= 5 ? parts[4] : '';
        final bomClarity = parts.length >= 6 ? parts[5] : '';

        if (bomColor.isNotEmpty && bomClarity.isNotEmpty) {
          colorRangeParts.add(bomColor);
          clarityRangeParts.add(bomClarity);
        } else if (caratFromVal >= 0.10 && caratToVal <= 0.17) {
          colorRangeParts.add('EF');
          clarityRangeParts.add('VVS');
        } else if (caratFromVal >= 0.18 && caratToVal <= 2.99) {
          colorRangeParts.add('E');
          clarityRangeParts.add('VVS1');
        }

        debugPrint(
          'BOM row → shape=${parts.length > 1 ? parts[1] : '?'} '
          'carat=$caratFrom-$caratTo '
          'color=${colorRangeParts.last} '
          'clarity=${clarityRangeParts.last}',
        );
      }

      if (caratRangeParts.isNotEmpty) {
        // Single row  → '0.10-0.13 ct'
        // Multi rows  → '0.10-0.13, 0.80-0.89 ct'  (matches multiCaratLabel format)
        bomDefaultCaratRange = '${caratRangeParts.join(', ')} ct';
      }

      if (colorRangeParts.isNotEmpty) {
        // Single → 'EF - EF'
        // Multi  → 'EF - EF, E - E'
        bomDefaultColorRange = colorRangeParts.map((c) => '$c - $c').join(', ');
      }

      if (clarityRangeParts.isNotEmpty) {
        bomDefaultClarityRange = clarityRangeParts
            .map((c) => '$c - $c')
            .join(', ');
      }
    }
    //--------------------------------

    // 3) BASE METAL WEIGHTS (from BOM, for base size)
    final baseGoldWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'GOLD',
      'METAL',
    );
    final basePlatinumWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'PLATINUM',
      'METAL',
    );

    // 3a) DIVINE MOUNT ADJUSTMENT — apply size factor BEFORE the API call ✅
    double goldWeight = baseGoldWeight;
    double platinumWeight = basePlatinumWeight;

    if (detail.productSizeFrom != '-' && baseSize != null) {
      final factor = JewelleryCalculationService.calculateDivineMountAdjustment(
        carat: caratFromStr.trim(),
        size: currentSize,
        baseRingSize: baseSize,
        qty: current.selectedQty,
      );
      goldWeight = baseGoldWeight * factor;
      platinumWeight = basePlatinumWeight * factor;

      debugPrint(
        'Size adjustment: baseSize=$baseSize, currentSize=$currentSize, '
        'factor=$factor, goldWeight=$baseGoldWeight→$goldWeight',
      );
    }

    // 4) METAL AMOUNT — receives adjusted weights ✅
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

    final perGram = netMetalWeight > 0 ? metal / netMetalWeight : 0.0;

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
          totalSideCts: totalSideWeight,
          qty: current.selectedQty,
        );

    debugPrint('Side diamond amount: $sideDiamond');

    // 6) SOLITAIRE SELECTION (use filter range when present)
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
      detail.variants,
      detail.bom,
      'SOLITAIRE',
      'STONE',
    );

    // 8) BASIC SOLITAIRE RATE (single-size)
    final double rateFromPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(selectedColorFrom),
      quality: selectedClarityFrom,
    );

    debugPrint(
      'Fetching price for SOLITAIRE with slab: $minCt, shape: $shapeCode, '
      'color: $selectedColorFrom, quality: $selectedClarityFrom => $rateFromPerCtRaw',
    );

    final double rateToPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(selectedColorTo),
      quality: selectedClarityTo,
    );

    debugPrint(
      'Fetching price for SOLITAIRE with slab: $maxCt, shape: $shapeCode, '
      'color: $selectedColorTo, quality: $selectedClarityTo => $rateToPerCtRaw',
    );

    // 9) PREMIUM (currently 0, can be made dynamic later)
    final double rateFromWithPremium = rateFromPerCtRaw;
    final double rateToWithPremium = rateToPerCtRaw;

    // 10) MULTI-SIZE OR SINGLE-SIZE SOLITAIRE
    final int rowCount = JewelleryCalculationService.getSolitaireRowCount(
      detail.variants,
      detail.bom,
    );

    double solFrom = 0;
    double solTo = 0;
    String? multiShapeLabel;
    String? multiCaratLabel;
    String? multipcsLabel;
    String? multiColorLabel;
    String? multiClarityLabel;

    if (rowCount > 1) {
      final result =
          await JewelleryCalculationService.calculateSolitaireAmountRangeLocal(
            detail: detail,
            qty: current.selectedQty,
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
            userMinCt: minCt,
            userMaxCt: maxCt,
            userColorFrom: selectedColorFrom,
            userColorTo: selectedColorTo,
            userClarityFrom: selectedClarityFrom,
            userClarityTo: selectedClarityTo,
          );
      solFrom = result.solFrom;
      solTo = result.solTo;
      multiShapeLabel = result.shapeLabel;
      multiCaratLabel = result.caratLabel;
      multipcsLabel = result.pcsLabel;
      multiColorLabel = result.colourLabel;
      multiClarityLabel = result.clarityLabel;
      // debugPrint('Multi Shape : $multiShapeLabel');
      // debugPrint('Multi Carat : $multiCaratLabel');
      // debugPrint('Multi Pcs : $multipcsLabel');
      // debugPrint('Multi Color : $multiColorLabel');
      // debugPrint('Multi Clarity : $multiClarityLabel');
    } else {
      final pcs = totalSolitairePcs;
      solFrom = rateFromWithPremium * minCt * pcs * current.selectedQty;
      solTo = rateToWithPremium * maxCt * pcs * current.selectedQty;
    }

    // 11) FINAL AMOUNTS
    final approxFrom = metal + sideDiamond + solFrom;
    final approxTo = metal + sideDiamond + solTo;

    final msg = JewelleryCalculationService.getMultiSolitaireMessage(
      variants: detail.variants,
      bom: detail.bom,
      totalPcs: totalSolitairePcs,
    );

    debugPrint('Row Count: $rowCount');

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
      solitaireShape: rowCount > 1 ? multiShapeLabel : getShape,
      caratRange: rowCount > 1 ? multiCaratLabel : current.caratRange,
      SolitairePcs: rowCount > 1 ? multipcsLabel : current.SolitairePcs,
      colorRange: rowCount > 1 ? multiColorLabel : current.colorRange,
      clarityRange: rowCount > 1 ? multiClarityLabel : current.clarityRange,
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
      'Gold weight: $goldWeight, price: $goldPrice, color: $goldColor, '
      'purity: ${JewelleryCalculationService.getValidPurity('gold', metalPurity)}',
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

    // <= 1 gm rule: use fixed price regardless of API rate
    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    return goldAmount + platinumAmount;
  }

  Future<CartDetail?> buildCartPayload({
    required CustomerDetail Ordercustomer,
    required String customercode,
    required String customername,
    required String branch,
    required int? customerid,
  }) async {
    final s = state.value;
    if (s == null || s.detail == null) return null;

    final d = s.detail!;

    final skipValidation =
        d.productCategory == 'COIN' ||
        d.productSubCategory == 'Solitaire Coin' ||
        d.productSubCategory == 'Locket';

    // ---------- VALIDATIONS ----------
    if (!skipValidation) {
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
    }

    debugPrint('Customer details: ${Ordercustomer.name}, ${Ordercustomer.id}');

    final dt = DateTime.now().add(const Duration(days: 15)).toUtc();

    // ---------- BUILD PAYLOAD ----------
    return CartDetail(
      orderFor: 'Retail Customer',
      customerId: customerid, //new customer id from DB
      customerCode: customercode, //new customer code from DB
      customerName: customername, //new customer name from DB
      customerBranch: branch, //new branch from DB
      productType: 'jewellery',
      orderType: 'RCO',

      productCategory: d.productCategory,
      productSubCategory: d.productSubCategory,
      collection: d.collection,
      expDlvDate: dt.toIso8601String(),

      oldVarient: d.oldVariant,
      productCode: d.itemNumber,
      designno: d.designno,

      solitairePcs: s.totalSolitairePcs ?? 1,
      productQty: s.selectedQty,

      productAmtMin: (d.productPrice == null || d.productPrice == 0)
          ? (s.approxPriceFrom ?? 0).roundToDouble()
          : d.productPrice?.toDouble(),
      productAmtMax: (d.productPrice == null || d.productPrice == 0)
          ? (s.approxPriceTo ?? 0).roundToDouble()
          : d.productPrice?.toDouble(),

      solitaireShape: s.solitaireShape ?? '',
      solitaireSlab: s.caratRange?.replaceAll('ct', '').replaceAll(' ', ''),

      solitaireColor: () {
        final parts = (s.colorRange ?? '')
            .split('-')
            .map((e) => e.trim())
            .toList();
        if (parts.length < 2) return s.colorRange;
        return '${parts.last}-${parts.first}';
      }(),
      solitaireQuality: () {
        final parts = (s.clarityRange ?? '')
            .split('-')
            .map((e) => e.trim())
            .toList();
        if (parts.length < 2) return s.clarityRange;
        return '${parts.last}-${parts.first}';
      }(),
      solitairePremSize: '',
      solitairePremPct: 0,

      solitaireAmtMin: (s.solitaireAmountFrom ?? 0).roundToDouble(),
      solitaireAmtMax: (s.solitaireAmountTo ?? 0).roundToDouble(),

      metalType: s.selectedMetalPurity == '950PT' ? 'PLATINUM' : 'GOLD',
      metalPurity: s.selectedMetalPurity ?? '',
      metalColor: s.selectedMetalColor ?? '',
      metalWeight: s.netMetalWeight ?? 0,
      metalPrice: (s.metalprice ?? 0).roundToDouble(),

      mountAmtMin: ((s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0))
          .roundToDouble(),
      mountAmtMax: ((s.metalAmount ?? 0) + (s.sideDiamondAmount ?? 0))
          .roundToDouble(),

      sizeFrom: s.ringSize,
      sizeTo: null,

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
      end_customer_id: Ordercustomer.id ?? 0,
      end_customer_name: Ordercustomer.name ?? '',
    );
  }
}

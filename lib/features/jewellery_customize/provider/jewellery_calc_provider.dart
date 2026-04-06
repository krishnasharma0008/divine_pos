import 'package:divine_pos/features/cart/data/cart_detail_model.dart';
import 'package:divine_pos/features/cart/data/customer_detail_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/jewellery_detail_model.dart';
import '../data/jewellery_filter.dart';
import '../data/variant_model.dart';
import '../data/bom_model.dart';
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

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD DETAIL
  // ─────────────────────────────────────────────────────────────────────────

  /// Entry point called from the screen's initState.
  ///
  /// Scenario 1 (store product): lyingwith is present.
  ///   - 1st fetch  → detail  (pinned size, actual weight, actual stone)
  ///   - 2nd fetch  → calcDetail (full size range, all variants, catalogue BOM)
  ///   - Initial price  uses detail.bom  (actual store item data)
  ///   - Customise      uses calcDetail  (full catalogue data)
  ///   - Reset          returns to detail.bom pricing
  ///
  /// Scenario 2 (catalogue): lyingwith is null.
  ///   - 1st fetch only → detail (full variants + BOM)
  ///   - All calculations use detail
  Future<void> loadDetail(String productCode, String? lyingwith) async {
    final detailNotifier = ref.read(jewelleryDetailProvider.notifier);

    // ── Step 1: fetch display data by product_code ──────────────────────────
    await detailNotifier.fetchJewelleryDetail(
      productCode,
      lyingwith: lyingwith,
    );

    final detail = ref.read(jewelleryDetailProvider).value;
    if (detail == null) return;

    var current = state.value ?? const JewelleryCalcState();
    current = current.copyWith(detail: detail);
    state = AsyncData(current);

    // ── Step 2: store product only — fetch full catalogue data by designno ──
    if (lyingwith != null && lyingwith.trim().isNotEmpty) {
      final designno = detail.designno;
      if (designno == null || designno.trim().isEmpty) {
        debugPrint('⚠️ designno is null — skipping calcDetail fetch');
      } else {
        try {
          debugPrint('🔍 Fetching calcDetail by designno: $designno');
          final calcDetail = await detailNotifier.fetchByDesignno(designno);

          if (calcDetail != null) {
            current = current.copyWith(calcDetail: calcDetail);
            state = AsyncData(current);
            debugPrint(
              '✅ calcDetail loaded — '
              'designno: ${calcDetail.designno}, '
              'variants: ${calcDetail.variants.length}, '
              'bom: ${calcDetail.bom.length}',
            );
          } else {
            debugPrint('⚠️ fetchByDesignno returned null for: $designno');
          }
        } catch (e, st) {
          // Non-fatal: fall back to using detail for all calculations.
          debugPrint('⚠️ designno fetch failed: $e\n$st');
        }
      }
    }

    await _recalculatePrice();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APPLY FILTER (from CustomizeSolitaire drawer)
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> resetPriceToInitial() async {
    final current = state.value;
    if (current == null) return;

    // Resetting to initial values makes isCustomised → false,
    // which routes _recalculatePrice back to detail.bom for store products.
    state = AsyncData(
      current.copyWith(
        caratRange: current.initialCaratRange,
        colorRange: current.initialColorRange,
        clarityRange: current.initialClarityRange,
        ringSize: current.initialRingSize,
        selectedMetalColor: current.initialMetalColor,
        selectedMetalPurity: current.initialMetalPurity,
        selectedSideDiamondQuality: current.initialSideDiamondQuality,
      ),
    );

    await _recalculatePrice();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRICE CALCULATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _recalculatePrice() async {
    final current = state.value;
    if (current == null || current.detail == null) return;

    // detail   = 1st fetch  (store copy / catalogue product)
    // calcDetail = 2nd fetch (full catalogue master, store products only)
    // cd       = calcDetail when available, else detail
    final detail = current.detail!;
    final cd = current.calcDetail ?? detail;

    // ── SOURCE ROUTING ──────────────────────────────────────────────────────
    //
    // isStoreProduct = true   → Scenario 1 (lyingwith was present)
    // isStoreProduct = false  → Scenario 2 (catalogue only)
    //
    // useDetailBom  = true   → price from detail.bom (actual store item data)
    //                          covers: initial load + after reset for store products
    // useDetailBom  = false  → price from calcDetail.bom (catalogue BOM)
    //                          covers: after customise for store products, + all catalogue
    final isStoreProduct = current.calcDetail != null;
    final useDetailBom = isStoreProduct && !current.isCustomised;

    final pricingVariants = useDetailBom ? <Variant>[] : cd.variants;
    final pricingBom = useDetailBom ? detail.bom : cd.bom;

    debugPrint(
      '📐 isStoreProduct=$isStoreProduct, '
      'isCustomised=${current.isCustomised}, '
      'useDetailBom=$useDetailBom',
    );

    // ── 1) BASE SIZE & CARAT ────────────────────────────────────────────────
    // Always derived from cd (has real base variant data).
    final base = JewelleryCalculationService.getBaseSizeCarat(cd);
    final baseSize = current.baseSize ?? base.baseSize;
    final baseCarat = current.baseCarat ?? base.baseCarat;
    final caratFromStr = baseCarat ?? '0.10';

    // ── 2) SIZE RANGE (slider) ──────────────────────────────────────────────
    // Always from cd — full master range for the ring-size slider.
    final sizeFrom = current.sizeFrom ?? int.tryParse(cd.productSizeFrom);
    final sizeTo = current.sizeTo ?? int.tryParse(cd.productSizeTo);

    // ── 3) DEFAULT SELECTED RING SIZE ───────────────────────────────────────
    // Store product → detail.productSizeFrom = pinned store size ("19")
    // Catalogue     → base variant size from cd ("15")
    final ringSize =
        current.ringSize ??
        (isStoreProduct && detail.productSizeFrom.isNotEmpty
            ? detail.productSizeFrom
            : baseSize?.toStringAsFixed(0));

    final currentSize = double.tryParse(ringSize ?? '') ?? (baseSize ?? 0.0);

    // ── 4) DEFAULT SOLITAIRE SHAPE ──────────────────────────────────────────
    // Always from cd — richer shape data.
    final shapeCode = JewelleryCalculationService.getDefaultSolitaireShapeCode(
      variants: cd.variants,
      bom: cd.bom,
    );
    final getShape = JewelleryCalculationService.mapShapeCodeToName(shapeCode);

    // ── 5) DERIVE BOM DEFAULTS FOR SOLITAIRE ────────────────────────────────
    // For initial carat / color / clarity ranges shown in the UI.
    String? bomDefaultCaratRange;
    String? bomDefaultColorRange;
    String? bomDefaultClarityRange;

    // BOM rows for the active base variant (or variantless if no variants).
    final List<Bom> defaultBomList;
    if (pricingVariants.isEmpty) {
      defaultBomList = pricingBom
          .where(
            (b) =>
                b.itemGroup.trim().toUpperCase() == 'SOLITAIRE' &&
                b.itemType.trim().toUpperCase() == 'STONE',
          )
          .toList();
    } else {
      final activeVariant = pricingVariants.firstWhere(
        (v) => v.isBaseVariant,
        orElse: () => pricingVariants.first,
      );
      defaultBomList = pricingBom
          .where(
            (b) =>
                b.variantId == activeVariant.variantId &&
                b.itemGroup.trim().toUpperCase() == 'SOLITAIRE' &&
                b.itemType.trim().toUpperCase() == 'STONE',
          )
          .toList();
    }

    if (defaultBomList.isNotEmpty) {
      final caratRangeParts = <String>[];
      final colorRangeParts = <String>[];
      final clarityRangeParts = <String>[];

      for (final row in defaultBomList) {
        final parts = row.bomVariantName
            .split('-')
            .map((e) => e.trim())
            .toList();
        if (parts.length < 4) continue;

        final caratFrom = parts[2];
        final caratTo = parts[3];
        final caratFromVal = double.tryParse(caratFrom) ?? 0.0;
        final caratToVal = double.tryParse(caratTo) ?? 0.0;

        caratRangeParts.add('$caratFrom-$caratTo');

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
          'color=${colorRangeParts.isNotEmpty ? colorRangeParts.last : '-'} '
          'clarity=${clarityRangeParts.isNotEmpty ? clarityRangeParts.last : '-'}',
        );
      }

      if (caratRangeParts.isNotEmpty) {
        bomDefaultCaratRange = '${caratRangeParts.join(', ')} ct';
      }
      if (colorRangeParts.isNotEmpty) {
        bomDefaultColorRange = colorRangeParts.map((c) => '$c - $c').join(', ');
      }
      if (clarityRangeParts.isNotEmpty) {
        bomDefaultClarityRange = clarityRangeParts
            .map((c) => '$c - $c')
            .join(', ');
      }
    }

    final resolvedCaratRange = current.caratRange ?? bomDefaultCaratRange;
    final resolvedColorRange = current.colorRange ?? bomDefaultColorRange;
    final resolvedClarityRange = current.clarityRange ?? bomDefaultClarityRange;

    // Metal defaults from cd (catalogue always has the authoritative list).
    final resolvedMetalColor =
        current.selectedMetalColor ?? cd.metalColor.split(',').first.trim();
    final resolvedMetalPurity =
        current.selectedMetalPurity ?? cd.metalPurity.split(',').first.trim();
    final resolvedSideDiamondQuality =
        current.selectedSideDiamondQuality ?? 'IJ-SI';
    final resolvedRingSize = current.ringSize ?? ringSize;

    // ── 6) METAL WEIGHTS ────────────────────────────────────────────────────
    // useDetailBom → actual store item weight  (variantless path, e.g. 8.453g)
    // else         → calcDetail base variant weight (e.g. 9.68g) + size adjust
    final baseGoldWeight = JewelleryCalculationService.getWeight(
      pricingVariants,
      pricingBom,
      'GOLD',
      'METAL',
    );
    final basePlatinumWeight = JewelleryCalculationService.getWeight(
      pricingVariants,
      pricingBom,
      'PLATINUM',
      'METAL',
    );

    // ── 7) SIZE ADJUSTMENT ──────────────────────────────────────────────────
    // Only apply when pricing from catalogue data (not the pinned store item).
    double goldWeight = baseGoldWeight;
    double platinumWeight = basePlatinumWeight;

    if (!useDetailBom && cd.productSizeFrom != '-' && baseSize != null) {
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

    // ── 8) METAL AMOUNT ─────────────────────────────────────────────────────
    final metalAmount = await _calculateMetalAmountFromApi(
      detail: detail,
      metalColor: resolvedMetalColor,
      metalPurity: resolvedMetalPurity,
      goldWeight: goldWeight,
      platinumWeight: platinumWeight,
      qty: current.selectedQty,
    );

    debugPrint('Calculated metal amount: $metalAmount');

    final netMetalWeight = JewelleryCalculationService.getNetMetalWeight(
      pricingVariants,
      pricingBom,
    );

    final perGram = netMetalWeight > 0 ? metalAmount / netMetalWeight : 0.0;

    // ── 9) SIDE DIAMOND ─────────────────────────────────────────────────────
    final totalSidePcs = JewelleryCalculationService.getPcs(
      pricingVariants,
      pricingBom,
      'DIAMOND',
      'STONE',
    );
    final totalSideWeight = JewelleryCalculationService.getWeight(
      pricingVariants,
      pricingBom,
      'DIAMOND',
      'STONE',
    );

    final sideParts = resolvedSideDiamondQuality.split('-');
    final sideprice = await _fetchPrice(
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

    // ── 10) CARAT RANGE PARSING ─────────────────────────────────────────────
    double getMinCt() {
      if (resolvedCaratRange == null) return 0.18;
      final parts = resolvedCaratRange
          .replaceAll('ct', '')
          .split('-')
          .map((e) => e.trim())
          .toList();
      return double.tryParse(parts.first) ?? 0.18;
    }

    double getMaxCt() {
      if (resolvedCaratRange == null) return 0.22;
      final parts = resolvedCaratRange
          .replaceAll('ct', '')
          .split('-')
          .map((e) => e.trim())
          .toList();
      if (parts.length < 2) return getMinCt();
      return double.tryParse(parts.last) ?? getMinCt();
    }

    final double minCt = getMinCt();
    final double maxCt = getMaxCt();

    // ── 11) COLOR & CLARITY PARSING ─────────────────────────────────────────
    final selectedColorFrom = resolvedColorRange != null
        ? resolvedColorRange.split('-').first.trim()
        : 'G';
    final selectedColorTo = resolvedColorRange != null
        ? resolvedColorRange.split('-').last.trim()
        : selectedColorFrom;

    final selectedClarityFrom = resolvedClarityRange != null
        ? resolvedClarityRange.split('-').first.trim()
        : 'VS';
    final selectedClarityTo = resolvedClarityRange != null
        ? resolvedClarityRange.split('-').last.trim()
        : selectedClarityFrom;

    // ── 12) TOTAL SOLITAIRE PCS ─────────────────────────────────────────────
    final totalSolitairePcs = JewelleryCalculationService.getPcs(
      pricingVariants,
      pricingBom,
      'SOLITAIRE',
      'STONE',
    );

    // ── 13) SOLITAIRE RATES (single-size base fetch) ────────────────────────
    final double rateFromPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(selectedColorFrom),
      quality: selectedClarityFrom,
    );

    debugPrint(
      'Solitaire rate from: slab=$minCt, shape=$shapeCode, '
      'color=$selectedColorFrom, clarity=$selectedClarityFrom → $rateFromPerCtRaw',
    );

    final double rateToPerCtRaw = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: JewelleryCalculationService.getSolitaireColor(selectedColorTo),
      quality: selectedClarityTo,
    );

    debugPrint(
      'Solitaire rate to: slab=$maxCt, shape=$shapeCode, '
      'color=$selectedColorTo, clarity=$selectedClarityTo → $rateToPerCtRaw',
    );

    // ── 14) MULTI-SIZE vs SINGLE-SIZE SOLITAIRE ─────────────────────────────
    final int rowCount = JewelleryCalculationService.getSolitaireRowCount(
      pricingVariants,
      pricingBom,
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
            detail: _syntheticDetail(detail, pricingVariants, pricingBom),
            qty: current.selectedQty,
            fetchPrice:
                ({
                  required String itemGroup,
                  String? slab,
                  String? shape,
                  String? color,
                  String? quality,
                }) => _fetchPrice(
                  itemGroup: itemGroup,
                  slab: slab,
                  shape: shape,
                  color: color,
                  quality: quality,
                ),
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
    } else {
      final pcs = totalSolitairePcs;
      solFrom = rateFromPerCtRaw * minCt * pcs * current.selectedQty;
      solTo = rateToPerCtRaw * maxCt * pcs * current.selectedQty;
    }

    // ── 15) FINAL APPROX AMOUNTS ────────────────────────────────────────────
    final approxFrom = metalAmount + sideDiamond + solFrom;
    final approxTo = metalAmount + sideDiamond + solTo;

    final msg = JewelleryCalculationService.getMultiSolitaireMessage(
      variants: pricingVariants,
      bom: pricingBom,
      totalPcs: totalSolitairePcs,
    );

    debugPrint('Row count: $rowCount | approx: $approxFrom – $approxTo');

    // ── 16) WRITE STATE ─────────────────────────────────────────────────────
    final updated = current.copyWith(
      // Sizes
      sizeFrom: sizeFrom,
      sizeTo: sizeTo,
      ringSize: ringSize,
      baseSize: baseSize,
      baseCarat: baseCarat,

      // Selections
      selectedMetalColor: resolvedMetalColor,
      selectedMetalPurity: resolvedMetalPurity,
      selectedSideDiamondQuality: resolvedSideDiamondQuality,

      // Ranges
      caratRange: rowCount > 1 ? multiCaratLabel : resolvedCaratRange,
      colorRange: rowCount > 1 ? multiColorLabel : resolvedColorRange,
      clarityRange: rowCount > 1 ? multiClarityLabel : resolvedClarityRange,

      // Snapshot initial values (only on first calculation)
      initialRingSize: current.initialRingSize ?? resolvedRingSize,
      initialMetalColor: current.initialMetalColor ?? resolvedMetalColor,
      initialMetalPurity: current.initialMetalPurity ?? resolvedMetalPurity,
      initialSideDiamondQuality:
          current.initialSideDiamondQuality ?? resolvedSideDiamondQuality,
      initialCaratRange: current.initialCaratRange ?? resolvedCaratRange,
      initialColorRange: current.initialColorRange ?? resolvedColorRange,
      initialClarityRange: current.initialClarityRange ?? resolvedClarityRange,

      // Amounts
      metalAmount: metalAmount,
      netMetalWeight: netMetalWeight,
      metalprice: perGram,
      sideDiamondAmount: sideDiamond,
      solitaireAmountFrom: solFrom,
      solitaireAmountTo: solTo,
      approxPriceFrom: approxFrom,
      approxPriceTo: approxTo,

      // Counts
      totalSidePcs: totalSidePcs,
      totalSideWeight: totalSideWeight,
      totalSolitairePcs: totalSolitairePcs,

      // Message / shape
      solitaireMessage: msg.isEmpty ? null : msg,
      solitaireShape: rowCount > 1 ? multiShapeLabel : getShape,
      SolitairePcs: rowCount > 1 ? multipcsLabel : current.SolitairePcs,
    );

    state = AsyncData(updated);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds a thin wrapper so calculateSolitaireAmountRangeLocal can read
  /// the correct variants + bom without changing its signature.
  JewelleryDetail _syntheticDetail(
    JewelleryDetail base,
    List<Variant> variants,
    List<Bom> bom,
  ) {
    return JewelleryDetail(
      itemId: base.itemId,
      itemNumber: base.itemNumber,
      designno: base.designno,
      productName: base.productName,
      productCategory: base.productCategory,
      productSubCategory: base.productSubCategory,
      subCategory2: base.subCategory2,
      subCategory3: base.subCategory3,
      subCategory4: base.subCategory4,
      style: base.style,
      wearStyle: base.wearStyle,
      look: base.look,
      status: base.status,
      productDescription: base.productDescription,
      remark: base.remark,
      productRangeFrom: base.productRangeFrom,
      productRangeTo: base.productRangeTo,
      oldVariant: base.oldVariant,
      productRangeFromMin: base.productRangeFromMin,
      productRangeToMax: base.productRangeToMax,
      productSizeFrom: base.productSizeFrom,
      productSizeTo: base.productSizeTo,
      metalColor: base.metalColor,
      metalPurity: base.metalPurity,
      currentStatus: base.currentStatus,
      portfolioType: base.portfolioType,
      collection: base.collection,
      gender: base.gender,
      variantApprovedDate: base.variantApprovedDate,
      metalPriceLessOneGms: base.metalPriceLessOneGms,
      productPrice: base.productPrice,
      laying_with: base.laying_with,
      lying_with_id: base.lying_with_id,
      lying_with_name: base.lying_with_name,
      lying_with_nickname: base.lying_with_nickname,
      ctsSizeSlab: base.ctsSizeSlab,
      images: base.images,
      variants: variants, // ← swapped
      bom: bom, // ← swapped
    );
  }

  /// Price API call routed through JewelleryDetailNotifier.
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

  /// Metal amount calculation (gold + platinum).
  Future<double> _calculateMetalAmountFromApi({
    required JewelleryDetail detail,
    required String metalColor,
    required String metalPurity,
    required double goldWeight,
    required double platinumWeight,
    required int qty,
  }) async {
    if (metalColor.isEmpty || metalPurity.isEmpty) return 0.0;

    final selectedQty = qty > 0 ? qty : 1;

    final goldColor = metalColor.contains('+')
        ? JewelleryCalculationService.getMetalColor('GOLD', metalColor)
        : metalColor;

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

    // ≤ 1 g rule: fixed price per item, still multiplied by qty
    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble() * selectedQty;
    }

    return goldAmount + platinumAmount;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CART PAYLOAD
  // ─────────────────────────────────────────────────────────────────────────

  Future<CartDetail?> buildCartPayload({
    required CustomerDetail orderCustomer,
    required String customerCode,
    required String customerName,
    required String branch,
    required int? customerId,
  }) async {
    final s = state.value;
    if (s == null || s.detail == null) return null;

    final d = s.detail!;

    final skipValidation =
        d.productCategory == 'COIN' ||
        d.productSubCategory == 'Solitaire Coin' ||
        d.productSubCategory == 'Locket';

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

    debugPrint('Customer: ${orderCustomer.name} (${orderCustomer.id})');

    final dt = DateTime.now().add(const Duration(days: 15)).toUtc();

    return CartDetail(
      orderFor: 'Retail Customer',
      customerId: customerId,
      customerCode: customerCode,
      customerName: customerName,
      customerBranch: branch,
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
      end_customer_id: orderCustomer.id ?? 0,
      end_customer_name: orderCustomer.name ?? '',
    );
  }
}

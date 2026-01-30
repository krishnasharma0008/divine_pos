import 'package:divine_pos/shared/routes/route_pages.dart';
import 'package:divine_pos/shared/widgets/text.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/scale_size.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_bar.dart';
import '../../../shared/utils/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_preview_with_thumbnails.dart'; //gallery
import 'tab_row.dart'; //tab panel
import 'customize_solitaire.dart';
import '../presentation/widget/continue_cart_popup.dart';
import '../data/jewellery_detail_model.dart';
import '../provider/jewellery_detail_provider.dart';
import '../services/jewellery_calculation_service.dart'; // for calculation

class JewelleryCustomiseScreen extends ConsumerStatefulWidget {
  final String productCode;

  const JewelleryCustomiseScreen({super.key, required this.productCode});

  @override
  ConsumerState<JewelleryCustomiseScreen> createState() =>
      _JewelleryCustomiseScreenState();
}

class _JewelleryCustomiseScreenState
    extends ConsumerState<JewelleryCustomiseScreen> {
  int activeTab = 0;

  int? priceStartIndex;
  int? priceEndIndex;

  String? priceStartValue;
  String? priceEndValue;

  // double? caratStart;
  // double? caratEnd;
  int? caratStartIndex;
  int? caratEndIndex;

  String? caratStartValue;
  String? caratEndValue;

  int? colorStartIndex;
  int? colorEndIndex;
  String? colorStart;
  String? colorEnd;

  int? clarityStartIndex;
  int? clarityEndIndex;
  String? clarityStart;
  String? clarityEnd;

  String? ringSize;
  String? selectedMetalColor;
  String? selectedMetalPurity;
  String? selectedSideDiamondQuality;

  // Display strings
  String? priceRange;
  String? caratRange;
  String? colorRange;
  String? clarityRange;

  //for calculation
  int selectedQty = 1;
  // double? baseSize;
  // String? baseCarat;
  double? netMetalWeight;
  int? totalSidePcs;
  double? totalSideWeight;

  int? totalSolitairePcs;
  double? baseSize;
  String? baseCarat;
  double? metalAmount;
  double? metalPrice;
  double? sideDiamondAmount;
  double? solitaireAmountFrom;
  double? solitaireAmountTo;
  double? approxPriceFrom;
  double? approxPriceTo;
  bool _priceCalculated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(jewelleryDetailProvider.notifier)
          .fetchJewelleryDetail(widget.productCode);
    });
  }

  Future<double> _calculateMetalAmountFromApi({
    required JewelleryDetail detail,
    required String metalColor,
    required String metalPurity,
    required double goldWeight,
    required double platinumWeight,
    required int qty,
  }) async {
    final notifier = ref.read(jewelleryDetailProvider.notifier);

    if (metalColor.isEmpty || metalPurity.isEmpty) {
      return 0.0;
    }

    final goldColor = metalColor.contains('+')
        ? JewelleryCalculationService.getMetalColor('GOLD', metalColor)
        : metalColor;

    final selectedQty = qty > 0 ? qty : 1;

    double goldPrice = 0;
    double platinumPrice = 0;

    // GOLD pricing
    if (goldWeight > 1) {
      goldPrice = await notifier.fetchPrice(
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

    // PLATINUM pricing
    if (platinumWeight > 0) {
      final platinumColor = JewelleryCalculationService.getMetalColor(
        'PLATINUM',
        metalColor,
      );

      platinumPrice = await notifier.fetchPrice(
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

    final totalMetalAmount = goldAmount + platinumAmount;

    return totalMetalAmount;
  }

  Future<void> _recalculatePrice(JewelleryDetail detail) async {
    if (_priceCalculated) return;
    _priceCalculated = true;

    final notifier = ref.read(jewelleryDetailProvider.notifier);

    // 1) BASE SIZE & CARAT
    final base = JewelleryCalculationService.getBaseSizeCarat(detail);
    baseSize ??= base.baseSize;
    baseCarat ??= base.baseCarat;
    ringSize ??= baseSize?.toStringAsFixed(0);

    // 2) DEFAULT SOLITAIRE SHAPE
    final shapeCode = JewelleryCalculationService.getDefaultSolitaireShapeCode(
      variants: detail.variants,
      bom: detail.bom,
    );

    // 3) METAL WEIGHTS
    /// gold weight
    final goldWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'GOLD',
      'METAL',
    );
    // paltinum weight
    final platinumWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'PLATINUM',
      'METAL',
    );

    // 4) METAL AMOUNT
    final activeMetalColor =
        selectedMetalColor ?? detail.metalColor.split(',').first.trim() ?? '';
    final activeMetalPurity =
        selectedMetalPurity ?? detail.metalPurity.split(',').first.trim() ?? '';

    final metal = await _calculateMetalAmountFromApi(
      detail: detail,
      metalColor: activeMetalColor,
      metalPurity: activeMetalPurity,
      goldWeight: goldWeight,
      platinumWeight: platinumWeight,
      qty: selectedQty,
    );

    netMetalWeight = JewelleryCalculationService.getNetMetalWeight(
      detail.variants,
      detail.bom,
    );

    final perGram = (netMetalWeight ?? 0) > 0
        ? metal / (netMetalWeight ?? 1)
        : 0.0;

    // 5) SIDE DIAMOND
    /// TOTAL SIDE PCS
    totalSidePcs = JewelleryCalculationService.getPcs(
      detail.variants,
      detail.bom,
      'DIAMOND',
      'STONE',
    );

    /// TOTAL SIDE WEIGHT
    totalSideWeight = JewelleryCalculationService.getWeight(
      detail.variants,
      detail.bom,
      'DIAMOND',
      'STONE',
    );

    // color-quality
    final parts = (selectedSideDiamondQuality ?? 'IJ-SI').split("-");

    // price per ct FROM
    final double sideprice = await notifier.fetchPrice(
      itemGroup: 'DIAMOND',
      slab: '',
      shape: '',
      color: parts.isNotEmpty ? parts[0] : null,
      quality: parts.length > 1 ? parts[1] : null,
    );

    final sideDiamond =
        await JewelleryCalculationService.calculateSideDiamondPrice(
          price: sideprice ?? 0,
          totalSideCts: (totalSideWeight?.toDouble() ?? 0.0),
          qty: selectedQty ?? 0,
        );

    // 6) SOLITAIRE SELECTION (FROM POPUP OR BASE)
    final caratFromStr = caratStartValue ?? baseCarat ?? "0.30";
    final caratToStr = caratEndValue ?? caratFromStr;

    final double minCt = double.tryParse('0.18') ?? 0.30;
    final double maxCt = double.tryParse('0.22') ?? minCt;

    // JS uses color[1] for "from", color[0] for "to"
    final selectedColorFrom = colorEnd ?? colorStart ?? "G";
    final selectedColorTo = colorStart ?? selectedColorFrom;

    final selectedClarityFrom = clarityEnd ?? clarityStart ?? "VS";
    final selectedClarityTo = clarityStart ?? selectedClarityFrom;

    // 7) TOTAL SOLITAIRE PCS
    totalSolitairePcs = JewelleryCalculationService.getPcs(
      detail.variants ?? [],
      detail.bom ?? [],
      "SOLITAIRE",
      "STONE",
    );

    // 8) BASIC SOLITAIRE RATE (WITHOUT PREMIUM YET)
    final double rateFromPerCtRaw = await notifier.fetchPrice(
      itemGroup: "SOLITAIRE",
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: selectedColorFrom,
      quality: selectedClarityFrom,
    );

    final double rateToPerCtRaw = await notifier.fetchPrice(
      itemGroup: "SOLITAIRE",
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: selectedColorTo,
      quality: selectedClarityTo,
    );

    // 9) PREMIUM
    final double premiumPct = 0.0; // premiumPercentage?.toDouble() ?? 0.0;
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
      // MULTI‑SIZE: mirror the JS BOM loop
      final result =
          JewelleryCalculationService.calculateSolitaireAmountRangeLocal(
            detail: detail,
            //selectedCaratRangeFrom: caratFromStr,
            //selectedCaratRangeTo: caratToStr,
            qty: selectedQty,
            rateFromPerCt: rateFromWithPremium,
            rateToPerCt: rateToWithPremium,
          );
      solFrom = result.solFrom;
      solTo = result.solTo;
    } else {
      // SINGLE‑SIZE (but can be multi‑solitaire i.e. Pcs > 1)
      final pcs = (totalSolitairePcs ?? 0);
      final minAmountPerCt = rateFromWithPremium;
      final maxAmountPerCt = rateToWithPremium;

      solFrom = minAmountPerCt * minCt * pcs * selectedQty;
      solTo = maxAmountPerCt * maxCt * pcs * selectedQty;
    }

    // 11) DIVINE MOUNT ADJUSTMENT
    if (detail.productSizeFrom != "-" && baseSize != null) {
      final currentSize = double.tryParse(ringSize ?? "") ?? baseSize!;
      final factor = JewelleryCalculationService.calculateDivineMountAdjustment(
        carat: caratFromStr.trim(),
        size: currentSize,
        baseRingSize: baseSize!,
        qty: selectedQty,
      );
      solFrom *= factor;
      solTo *= factor;
    }

    // 12) SET STATE
    setState(() {
      metalAmount = metal;
      metalPrice = double.parse(perGram.toStringAsFixed(2));
      sideDiamondAmount = sideDiamond;
      solitaireAmountFrom = solFrom;
      solitaireAmountTo = solTo;
      approxPriceFrom = metal + sideDiamond + solFrom;
      approxPriceTo = metal + sideDiamond + solTo;
    });
  }

  @override
  Widget build(BuildContext context) {
    //    debugPrint('SCREEN productCode: "${widget.productCode}"');
    final r = ScaleSize.aspectRatio;
    final detailAsync = ref.watch(jewelleryDetailProvider);
    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(
          child: Text(
            err.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (detail) {
        if (detail == null) {
          return const Scaffold(
            body: Center(child: Center(child: CircularProgressIndicator())),
          );
        }

        // ✅ AUTO CALCULATE ON PAGE LOAD
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_priceCalculated) {
            _recalculatePrice(detail);
          }
        });

        // ✅ IMAGE LOGIC BELONGS HERE
        final allImages = detail.images ?? [];
        final defaultMetalColor = detail.metalColor.split(',').first.trim();
        final defaultMetalPurity = detail.metalPurity.split(',').first.trim();

        final activeColor = selectedMetalColor ?? defaultMetalColor;
        final activePurity = selectedMetalPurity ?? defaultMetalPurity;

        final displayedImages = activeColor == null
            ? allImages
            : allImages
                  .where(
                    (img) =>
                        (img.color ?? '').toLowerCase() ==
                        activeColor.toLowerCase(),
                  )
                  .toList();

        final msg = JewelleryCalculationService.getMultiSolitaireMessage(
          variants: detail.variants,
          bom: detail.bom,
          totalPcs: totalSolitairePcs ?? 0,
        );

        if (msg.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(msg)));
          });
        }

        //debugPrint('Displayed Images Count: ${displayedImages}');

        return Scaffold(
          //extendBody: true,
          backgroundColor: Colors.white,
          appBar: MyAppBar(
            appBarLeading: AppBarLeading.back,
            showLogo: false,
            actions: [
              //AppBarActionConfig(type: AppBarAction.search, onTap: () {}),
              //   AppBarActionConfig(
              //     type: AppBarAction.notification,
              //     badgeCount: 1,
              //     onTap: () => context.push('/notifications'),
              //   ),
              //   AppBarActionConfig(
              //     type: AppBarAction.profile,
              //     onTap: () => context.push('/profile'),
              //   ),
              AppBarActionConfig(
                type: AppBarAction.cart,
                badgeCount: 0,
                //onTap: () => context.push('/cart'),
                onTap: () => GoRouter.of(
                  context,
                ).pushReplacement(RoutePages.cart.routePath),
              ),
            ],
          ),
          //drawer: const SideDrawer(),
          body: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  /// SCROLLABLE MIDDLE
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * r),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LEFT — 65%
                            Expanded(
                              flex: 6,
                              child: ImagePreviewWithThumbnails(
                                images: displayedImages,
                                title: detail.collection,
                                description: detail.productDescription,
                                productCode: widget.productCode,
                                uid: detail.productName,
                                r: r,
                              ),
                            ),

                            SizedBox(width: 16 * r),

                            /// RIGHT — 35%
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 40 * r),
                                  SizedBox(
                                    width: 335 * r,
                                    child: Text(
                                      'Customize your Divine jewellery',
                                      style: TextStyle(
                                        fontSize: 20 * r,
                                        fontFamily: 'Rushter Glory',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 18 * r),
                                  DeliveryBadge(r: r),
                                  SizedBox(height: 23 * r),
                                  DetailsScreen(
                                    r: r,
                                    priceRange: priceRange,
                                    caratRange: caratRange,
                                    colorRange: colorRange,
                                    clarityRange: clarityRange,
                                    ringSize: ringSize,
                                    totalMetalWeight: netMetalWeight ?? 0.0,
                                    metalColors:
                                        selectedMetalColor ??
                                        defaultMetalColor!,
                                    metalPurity:
                                        selectedMetalPurity ??
                                        defaultMetalPurity!,
                                    totalSidePcs: totalSidePcs?.toInt() ?? 0,
                                    totalSideWeight: totalSideWeight ?? 0.0,
                                    sideDiamondQuality:
                                        selectedSideDiamondQuality,

                                    // all amount
                                    metalAmount: metalAmount,
                                    sideDiamondAmount: sideDiamondAmount,
                                    solitaireAmountFrom: solitaireAmountFrom,
                                    solitaireAmountTo: solitaireAmountTo,
                                    approxPriceFrom: approxPriceFrom,
                                    approxPriceTo: approxPriceTo,
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(right: 34 * r),
                                    child: SizedBox(
                                      width: 483 * r,
                                      height: 41 * r,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20 * r,
                                          ),

                                          // ✅ THIS IS THE onTap
                                          onTap: () async {
                                            final metalColors =
                                                detail.metalColor.split(',') ??
                                                ['Yellow'];
                                            final metalPurities =
                                                detail.metalPurity.split(',') ??
                                                ['18K'];

                                            final result =
                                                await showDialog<
                                                  Map<String, dynamic>
                                                >(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (_) => CustomizeSolitaire(
                                                    metalColors:
                                                        metalColors, // metal dropdown options
                                                    metalPurity: metalPurities,
                                                    detail: detail,

                                                    totalSidePcs:
                                                        totalSidePcs?.toInt() ??
                                                        0,
                                                    totalSideWeight:
                                                        totalSideWeight ?? 0.0,

                                                    initialValues: {
                                                      if (priceStartIndex !=
                                                              null &&
                                                          priceEndIndex != null)
                                                        'price': {
                                                          'startIndex':
                                                              priceStartIndex,
                                                          'endIndex':
                                                              priceEndIndex,
                                                        },

                                                      // CARAT
                                                      if (caratStartIndex !=
                                                              null &&
                                                          caratEndIndex != null)
                                                        'carat': {
                                                          'startIndex':
                                                              caratStartIndex,
                                                          'endIndex':
                                                              caratEndIndex,
                                                        },

                                                      // ✅ pass indices for color
                                                      if (colorStartIndex !=
                                                              null &&
                                                          colorEndIndex != null)
                                                        'color': {
                                                          'startIndex':
                                                              colorStartIndex,
                                                          'endIndex':
                                                              colorEndIndex,
                                                        },

                                                      // ✅ pass indices for clarity
                                                      if (clarityStartIndex !=
                                                              null &&
                                                          clarityEndIndex !=
                                                              null)
                                                        'clarity': {
                                                          'startIndex':
                                                              clarityStartIndex,
                                                          'endIndex':
                                                              clarityEndIndex,
                                                        },

                                                      // RING SIZE
                                                      'ringSizeFrom': detail
                                                          .productSizeFrom,
                                                      'ringSizeTo':
                                                          detail.productSizeTo,
                                                      if (ringSize != null)
                                                        'ringSize': ringSize,

                                                      'availableColors': detail
                                                          .images
                                                          .map((e) => e.color)
                                                          .toList(),
                                                      'metalColor':
                                                          selectedMetalColor,
                                                      'metalPurity':
                                                          selectedMetalPurity,

                                                      'sideDiamondQuality':
                                                          selectedSideDiamondQuality,
                                                    },
                                                  ),
                                                );

                                            if (!mounted || result == null) {
                                              return;
                                            }

                                            setState(() {
                                              // PRICE
                                              priceStartIndex =
                                                  result['price']?['startIndex'];
                                              priceEndIndex =
                                                  result['price']?['endIndex'];

                                              priceStartValue =
                                                  result['price']?['startValue'];
                                              priceEndValue =
                                                  result['price']?['endValue'];

                                              priceRange =
                                                  (priceStartValue != null &&
                                                      priceEndValue != null)
                                                  ? '₹$priceStartValue - ₹$priceEndValue'
                                                  : null;

                                              // CARAT
                                              caratStartIndex =
                                                  result['carat']?['startIndex'];
                                              caratEndIndex =
                                                  result['carat']?['endIndex'];

                                              caratStartValue =
                                                  result['carat']?['startValue'];
                                              caratEndValue =
                                                  result['carat']?['endValue'];

                                              caratRange =
                                                  (caratStartValue != null &&
                                                      caratEndValue != null)
                                                  ? '$caratStartValue - $caratEndValue ct'
                                                  : null;

                                              // COLOR
                                              colorStartIndex =
                                                  result['color']?['startIndex'];
                                              colorEndIndex =
                                                  result['color']?['endIndex'];

                                              colorStart =
                                                  result['color']?['start']; // ✅ FIX
                                              colorEnd =
                                                  result['color']?['end']; // ✅ FIX

                                              colorRange =
                                                  colorStart != null &&
                                                      colorEnd != null
                                                  ? '$colorStart - $colorEnd'
                                                  : null;

                                              // CLARITY
                                              clarityStartIndex =
                                                  result['clarity']?['startIndex'];
                                              clarityEndIndex =
                                                  result['clarity']?['endIndex'];

                                              clarityStart =
                                                  result['clarity']?['start']; // ✅ FIX
                                              clarityEnd =
                                                  result['clarity']?['end']; // ✅ FIX

                                              clarityRange =
                                                  clarityStart != null &&
                                                      clarityEnd != null
                                                  ? '$clarityStart - $clarityEnd'
                                                  : null;

                                              ringSize = result['ringSize'];

                                              // metal color
                                              selectedMetalColor =
                                                  result['metalColor'];

                                              // metal purity
                                              selectedMetalPurity =
                                                  result['metalPurity'];

                                              // Filter images by selected color
                                              final allImages =
                                                  detail.images ?? [];
                                              final selectedColor =
                                                  result['color']?['start'];

                                              _priceCalculated = false;
                                            });
                                            await _recalculatePrice(
                                              detail,
                                            ); //recalculate price
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Customization applied',
                                                ),
                                                backgroundColor: Color(
                                                  0xFF90DCD0,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },

                                          //child: const Text('Customize Solitaire'),
                                          child: Stack(
                                            children: [
                                              /// Outer border
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: const BorderSide(
                                                        width: 1,
                                                        color: Color(
                                                          0xFF6C5022,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              /// Main button
                                              Positioned(
                                                left: 4 * r,
                                                top: 4 * r,
                                                bottom: 4 * r,
                                                right: 84 * r,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFCBC4AE,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15 * r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: MyText(
                                                    'Start customizing',
                                                    style: TextStyle(
                                                      color: Color(0xFF6C5022),
                                                      fontSize: 14 * r,
                                                      fontFamily: 'Montserrat',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              /// Arrow image button
                                              Positioned(
                                                top: 4 * r,
                                                bottom: 4 * r,
                                                right: 4 * r,
                                                width: 72 * r,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFF6C5022,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15 * r,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/jewellery_pdp/cus-ticon.png',
                                                    width: 18 * r,
                                                    height: 18 * r,
                                                  ),
                                                ),
                                              ),
                                              //),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// MAIN BOTTOM BAR
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25 * r),
                    topRight: Radius.circular(25 * r),
                  ),
                  child: Container(
                    height: 82 * r,
                    padding: EdgeInsets.symmetric(horizontal: 40 * r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEE4DD),
                      border: Border(
                        top: BorderSide(color: Color(0xFF90DCD0), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// PRICE TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //const Spacer(),
                            MyText(
                              'Approx.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20 * r,
                                color: const Color(0xFF757575),
                                fontFamily: 'Montserrat',
                                height: 1.35 * r,
                                letterSpacing: 0.40 * r,
                              ),
                            ),
                            SizedBox(width: 30 * r),
                            Row(
                              children: [
                                MyText(
                                  approxPriceFrom != null
                                      ? '₹${approxPriceFrom!.toStringAsFixed(0)}'
                                      : '--',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    height: 0.90 * r,
                                    letterSpacing: 0.60 * r,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                MyText(
                                  '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    height: 0.90 * r,
                                    letterSpacing: 0.60 * r,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  approxPriceTo != null
                                      ? '₹${approxPriceTo!.toStringAsFixed(0)}'
                                      : '--',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30 * r,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    height: 0.90 * r,
                                    letterSpacing: 0.60 * r,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// CONTINUE BUTTON
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => const ContinueCartPopup(),
                            );
                          },

                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 258 * r,
                            height: 52 * r,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30 * r,
                              vertical: 6 * r,
                            ),
                            decoration: ShapeDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment(0.0, 0.5),
                                end: Alignment(0.96, 1.12),
                                colors: [Color(0xFFBEE4DD), Color(0xA5D1B193)],
                              ),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFACA584),
                                ),
                                borderRadius: BorderRadius.circular(20 * r),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x7C000000),
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: MyText(
                                'Continue ',
                                style: TextStyle(
                                  color: const Color(0xFF6C5022),
                                  fontSize: 20 * r,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// ✅ WHITE GAP (8px) BELOW BOTTOM BAR
                        //Container(height: 8, width: double.infinity, color: Colors.white),
                      ],
                    ),
                  ),

                  //white  backgroundColor: Colors.white
                ),

                // 8 px white gap below bottom bar
                const SizedBox(
                  height: 4,
                  child: ColoredBox(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DeliveryBadge extends StatelessWidget {
  final double r;
  const DeliveryBadge({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 271 * r,
      height: 36 * r,
      decoration: BoxDecoration(
        color: const Color(0xFFBEE4DD),
        borderRadius: BorderRadius.circular(10 * r),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          // Left text
          Expanded(
            child: Center(
              child: MyText(
                'Made to order',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // White separator
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 6 * r),
            color: Colors.white,
          ),

          // Right text
          Expanded(
            child: Center(
              child: MyText(
                'Est delivery 15 days',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6C5022),
                  fontSize: 12 * r,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'jewellery_detail_model.dart';

class JewelleryCalcState {
  // Display detail fetched by productcode. Used for images, name, price etc.
  final JewelleryDetail? detail;

  // Calculation detail fetched by designno. Has full Variants/BOM.
  // All pricing calculations use this when available, falling back to detail.
  final JewelleryDetail? calcDetail;

  final double? metalprice;
  final double? metalAmount;
  final double? sideDiamondAmount;
  final double? solitaireAmountFrom;
  final double? solitaireAmountTo;
  final double? approxPriceFrom;
  final double? approxPriceTo;
  final double? netMetalWeight;

  final int? totalSidePcs;
  final double? totalSideWeight;
  final int? totalSolitairePcs;
  final String? SolitairePcs;

  final double? baseSize;
  final String? baseCarat;

  final int? sizeFrom;
  final int? sizeTo;

  final String? ringSize;
  final String? selectedMetalColor;
  final String? selectedMetalPurity;
  final String? selectedSideDiamondQuality;
  final int selectedQty;

  final String? priceRange;
  final String? caratRange;
  final String? colorRange;
  final String? clarityRange;
  final String? solitaireMessage;
  final String? solitaireShape;

  // Initial values for reset + customisation detection
  final String? initialCaratRange;
  final String? initialColorRange;
  final String? initialClarityRange;
  final String? initialRingSize;
  final String? initialMetalColor;
  final String? initialMetalPurity;
  final String? initialSideDiamondQuality;

  final int
  initialSizeFrom; // Default to 1 if not provided, as it's a common minimum ring size
  final int
  initialSizeTo; // Default to 30 if not provided, as it's a common maximum ring size

  final bool istoreproduct;
  final String? laying_with;

  // final bool
  // shouldCalculateApproxPriceTo; // Flag to determine if approxPriceTo should be calculated

  const JewelleryCalcState({
    this.detail,
    this.calcDetail,
    this.metalprice,
    this.metalAmount,
    this.sideDiamondAmount,
    this.solitaireAmountFrom,
    this.solitaireAmountTo,
    this.approxPriceFrom,
    this.approxPriceTo,
    this.netMetalWeight,
    this.totalSidePcs,
    this.totalSideWeight,
    this.totalSolitairePcs,
    this.SolitairePcs,
    this.baseSize,
    this.baseCarat,
    this.sizeFrom,
    this.sizeTo,
    this.ringSize,
    this.selectedMetalColor,
    this.selectedMetalPurity,
    this.selectedSideDiamondQuality,
    this.selectedQty = 1,
    this.priceRange,
    this.caratRange,
    this.colorRange,
    this.clarityRange,
    this.solitaireMessage,
    this.solitaireShape,
    this.initialCaratRange,
    this.initialColorRange,
    this.initialClarityRange,
    this.initialRingSize,
    this.initialMetalColor,
    this.initialMetalPurity,
    this.initialSideDiamondQuality,
    this.initialSizeFrom = 1, // Default values for ring size range
    this.initialSizeTo = 30, // Default values for ring size range
    this.istoreproduct = false,
    this.laying_with,
    //this.shouldCalculateApproxPriceTo = true, // Default to true
  });

  JewelleryCalcState copyWith({
    JewelleryDetail? detail,
    JewelleryDetail? calcDetail,
    double? metalprice,
    double? metalAmount,
    double? sideDiamondAmount,
    double? solitaireAmountFrom,
    double? solitaireAmountTo,
    double? approxPriceFrom,
    double? approxPriceTo,
    double? netMetalWeight,
    int? totalSidePcs,
    double? totalSideWeight,
    int? totalSolitairePcs,
    String? SolitairePcs,
    double? baseSize,
    String? baseCarat,
    int? sizeFrom,
    int? sizeTo,
    String? ringSize,
    String? selectedMetalColor,
    String? selectedMetalPurity,
    String? selectedSideDiamondQuality,
    int? selectedQty,
    String? priceRange,
    String? caratRange,
    String? colorRange,
    String? clarityRange,
    String? solitaireMessage,
    String? solitaireShape,
    String? initialCaratRange,
    String? initialColorRange,
    String? initialClarityRange,
    String? initialRingSize,
    String? initialMetalColor,
    String? initialMetalPurity,
    String? initialSideDiamondQuality,
    int? initialSizeFrom,
    int? initialSizeTo,

    bool? istoreproduct,
    String? laying_with,
    // bool?
    // shouldCalculateApproxPriceTo, // Allow overriding the approxPriceTo calculation flag
  }) {
    return JewelleryCalcState(
      detail: detail ?? this.detail,
      calcDetail: calcDetail ?? this.calcDetail,
      metalprice: metalprice ?? this.metalprice,
      metalAmount: metalAmount ?? this.metalAmount,
      sideDiamondAmount: sideDiamondAmount ?? this.sideDiamondAmount,
      solitaireAmountFrom: solitaireAmountFrom ?? this.solitaireAmountFrom,
      solitaireAmountTo: solitaireAmountTo ?? this.solitaireAmountTo,
      approxPriceFrom: approxPriceFrom ?? this.approxPriceFrom,
      approxPriceTo: approxPriceTo ?? this.approxPriceTo,
      netMetalWeight: netMetalWeight ?? this.netMetalWeight,
      totalSidePcs: totalSidePcs ?? this.totalSidePcs,
      totalSideWeight: totalSideWeight ?? this.totalSideWeight,
      totalSolitairePcs: totalSolitairePcs ?? this.totalSolitairePcs,
      SolitairePcs: SolitairePcs ?? this.SolitairePcs,
      baseSize: baseSize ?? this.baseSize,
      baseCarat: baseCarat ?? this.baseCarat,
      sizeFrom: sizeFrom ?? this.sizeFrom,
      sizeTo: sizeTo ?? this.sizeTo,
      ringSize: ringSize ?? this.ringSize,
      selectedMetalColor: selectedMetalColor ?? this.selectedMetalColor,
      selectedMetalPurity: selectedMetalPurity ?? this.selectedMetalPurity,
      selectedSideDiamondQuality:
          selectedSideDiamondQuality ?? this.selectedSideDiamondQuality,
      selectedQty: selectedQty ?? this.selectedQty,
      priceRange: priceRange ?? this.priceRange,
      caratRange: caratRange ?? this.caratRange,
      colorRange: colorRange ?? this.colorRange,
      clarityRange: clarityRange ?? this.clarityRange,
      solitaireMessage: solitaireMessage ?? this.solitaireMessage,
      solitaireShape: solitaireShape ?? this.solitaireShape,
      initialCaratRange: initialCaratRange ?? this.initialCaratRange,
      initialColorRange: initialColorRange ?? this.initialColorRange,
      initialClarityRange: initialClarityRange ?? this.initialClarityRange,
      initialRingSize: initialRingSize ?? this.initialRingSize,
      initialMetalColor: initialMetalColor ?? this.initialMetalColor,
      initialMetalPurity: initialMetalPurity ?? this.initialMetalPurity,
      initialSideDiamondQuality:
          initialSideDiamondQuality ?? this.initialSideDiamondQuality,
      initialSizeFrom: initialSizeFrom ?? this.initialSizeFrom,
      initialSizeTo: initialSizeTo ?? this.initialSizeTo,
      istoreproduct: istoreproduct ?? this.istoreproduct,
      laying_with: laying_with ?? this.laying_with,
      // shouldCalculateApproxPriceTo:
      //     shouldCalculateApproxPriceTo ?? this.shouldCalculateApproxPriceTo,
    );
  }

  bool get isCustomised {
    if (initialCaratRange == null ||
        initialColorRange == null ||
        initialClarityRange == null) {
      return false;
    }

    return caratRange != initialCaratRange ||
        colorRange != initialColorRange ||
        clarityRange != initialClarityRange ||
        ringSize != initialRingSize ||
        selectedMetalColor != initialMetalColor ||
        selectedMetalPurity != initialMetalPurity ||
        selectedSideDiamondQuality != initialSideDiamondQuality;
  }
}

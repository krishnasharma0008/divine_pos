import 'jewellery_detail_model.dart';

class JewelleryCalcState {
  final JewelleryDetail? detail;
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
  final double? baseSize;
  final String? baseCarat;
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

  const JewelleryCalcState({
    this.detail,
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
    this.baseSize,
    this.baseCarat,
    this.ringSize,
    this.selectedMetalColor,
    this.selectedMetalPurity,
    this.selectedSideDiamondQuality,
    this.priceRange,
    this.caratRange,
    this.colorRange,
    this.clarityRange,
    this.selectedQty = 1,
    this.solitaireMessage,
    this.solitaireShape,
  });

  JewelleryCalcState copyWith({
    JewelleryDetail? detail,
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
    double? baseSize,
    String? baseCarat,
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
  }) {
    return JewelleryCalcState(
      detail: detail ?? this.detail,
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
      baseSize: baseSize ?? this.baseSize,
      baseCarat: baseCarat ?? this.baseCarat,
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
    );
  }
}

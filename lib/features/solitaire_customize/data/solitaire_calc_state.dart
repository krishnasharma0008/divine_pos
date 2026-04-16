import 'solitaire_detail_model.dart';

class SolitaireCalcState {
  final SolitaireDetail? detail;

  final double? solitaireAmountFrom;
  final double? solitaireAmountTo;

  final double? approxPriceFrom;
  final double? approxPriceTo;

  final int selectedQty;

  final String? priceRange;
  final String? caratRange;
  final String? colorRange;
  final String? clarityRange;
  final String? solitaireShape;

  // Initial values for reset + customisation detection
  final String? initialCaratRange;
  final String? initialColorRange;
  final String? initialClarityRange;

  final bool isCustomized;

  const SolitaireCalcState({
    this.detail,
    this.solitaireAmountFrom,
    this.solitaireAmountTo,
    this.approxPriceFrom,
    this.approxPriceTo,
    this.selectedQty = 1,
    this.priceRange,
    this.caratRange,
    this.colorRange,
    this.clarityRange,
    this.solitaireShape,
    this.initialCaratRange,
    this.initialColorRange,
    this.initialClarityRange,
    this.isCustomized = false,
  });

  SolitaireCalcState copyWith({
    SolitaireDetail? detail,
    double? solitaireAmountFrom,
    double? solitaireAmountTo,
    double? approxPriceFrom,
    double? approxPriceTo,
    int? selectedQty,
    String? priceRange,
    String? caratRange,
    String? colorRange,
    String? clarityRange,
    String? solitaireShape,
    String? initialCaratRange,
    String? initialColorRange,
    String? initialClarityRange,
    bool? isCustomized,
  }) {
    return SolitaireCalcState(
      detail: detail ?? this.detail,
      solitaireAmountFrom: solitaireAmountFrom ?? this.solitaireAmountFrom,
      solitaireAmountTo: solitaireAmountTo ?? this.solitaireAmountTo,
      approxPriceFrom: approxPriceFrom ?? this.approxPriceFrom,
      approxPriceTo: approxPriceTo ?? this.approxPriceTo,
      selectedQty: selectedQty ?? this.selectedQty,
      priceRange: priceRange ?? this.priceRange,
      caratRange: caratRange ?? this.caratRange,
      colorRange: colorRange ?? this.colorRange,
      clarityRange: clarityRange ?? this.clarityRange,
      solitaireShape: solitaireShape ?? this.solitaireShape,
      initialCaratRange: initialCaratRange ?? this.initialCaratRange,
      initialColorRange: initialColorRange ?? this.initialColorRange,
      initialClarityRange: initialClarityRange ?? this.initialClarityRange,
      isCustomized: isCustomized ?? this.isCustomized,
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
        clarityRange != initialClarityRange;
  }
}

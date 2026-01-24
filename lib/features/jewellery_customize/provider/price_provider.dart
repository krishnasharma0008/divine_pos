// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/jewellery_calculation_service.dart';
// import 'jewellery_detail_provider.dart';
// import 'qty_provider.dart';
// import 'ring_size_provider.dart';
// import 'metal_provider.dart';
// import 'side_diamond_provider.dart';

// class PriceSummary {
//   final double metalAmount;
//   final double sideDiamondAmount;

//   const PriceSummary({
//     required this.metalAmount,
//     required this.sideDiamondAmount,
//   });

//   double get total => metalAmount + sideDiamondAmount;

//   factory PriceSummary.empty() =>
//       const PriceSummary(metalAmount: 0, sideDiamondAmount: 0);
// }

// final priceSummaryProvider = Provider<PriceSummary>((ref) {
//   final detail = ref.watch(jewelleryDetailProvider);
//   if (detail == null) return PriceSummary.empty();

//   final qty = ref.watch(qtyProvider);
//   final sizeDiff = ref.watch(ringSizeDiffProvider);

//   final goldPrice = ref.watch(goldPriceProvider);
//   final platinumPrice = ref.watch(platinumPriceProvider);
//   final sideDiamondPrice = ref.watch(sideDiamondPriceProvider);

//   final goldWeight = JewelleryCalculationService.adjustWeight(
//     baseWeight: JewelleryCalculationService.getWeight(
//       detail.variants,
//       detail.bom,
//       'METAL',
//       'GOLD',
//     ),
//     sizeDiff: sizeDiff,
//   );

//   final platinumWeight = JewelleryCalculationService.adjustWeight(
//     baseWeight: JewelleryCalculationService.getWeight(
//       detail.variants,
//       detail.bom,
//       'METAL',
//       'PLATINUM',
//     ),
//     sizeDiff: sizeDiff,
//   );

//   final sideWeight = JewelleryCalculationService.getWeight(
//     detail.variants,
//     detail.bom,
//     'SIDE',
//     'STONE',
//   );

//   return PriceSummary(
//     metalAmount: JewelleryCalculationService.calculateMetalAmount(
//       goldWeight: goldWeight,
//       goldPrice: goldPrice,
//       platinumWeight: platinumWeight,
//       platinumPrice: platinumPrice,
//       qty: qty,
//     ),
//     sideDiamondAmount: JewelleryCalculationService.calculateSideDiamondAmount(
//       weight: sideWeight,
//       price: sideDiamondPrice,
//       qty: qty,
//     ),
//   );
// });

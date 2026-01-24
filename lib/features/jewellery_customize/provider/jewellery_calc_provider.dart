// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/jewellery_api_service.dart';
// import '../data/jewellery_detail_model.dart';
// import '../services/jewellery_calculation_service.dart'; // you will create

// class JewelleryCalcState {
//   final JewelleryDetail? detail;
//   final int qty;
//   final double? baseSize;
//   final String? baseCarat;
//   final int totalSolitairePcs;
//   final double goldWeight;
//   final double platinumWeight;
//   final int sidePcs;
//   final double sideWeight;
//   final double? metalAmount;
//   final double? sideAmount;

//   const JewelleryCalcState({
//     this.detail,
//     this.qty = 1,
//     this.baseSize,
//     this.baseCarat,
//     this.totalSolitairePcs = 0,
//     this.goldWeight = 0,
//     this.platinumWeight = 0,
//     this.sidePcs = 0,
//     this.sideWeight = 0,
//     this.metalAmount,
//     this.sideAmount,
//   });

//   JewelleryCalcState copyWith({
//     JewelleryDetail? detail,
//     int? qty,
//     double? baseSize,
//     String? baseCarat,
//     int? totalSolitairePcs,
//     double? goldWeight,
//     double? platinumWeight,
//     int? sidePcs,
//     double? sideWeight,
//     double? metalAmount,
//     double? sideAmount,
//   }) {
//     return JewelleryCalcState(
//       detail: detail ?? this.detail,
//       qty: qty ?? this.qty,
//       baseSize: baseSize ?? this.baseSize,
//       baseCarat: baseCarat ?? this.baseCarat,
//       totalSolitairePcs: totalSolitairePcs ?? this.totalSolitairePcs,
//       goldWeight: goldWeight ?? this.goldWeight,
//       platinumWeight: platinumWeight ?? this.platinumWeight,
//       sidePcs: sidePcs ?? this.sidePcs,
//       sideWeight: sideWeight ?? this.sideWeight,
//       metalAmount: metalAmount ?? this.metalAmount,
//       sideAmount: sideAmount ?? this.sideAmount,
//     );
//   }
// }

// final jewelleryCalcProvider =
//     NotifierProvider<JewelleryCalcNotifier, AsyncValue<JewelleryCalcState>>(
//       JewelleryCalcNotifier.new,
//     );

// class JewelleryCalcNotifier extends Notifier<AsyncValue<JewelleryCalcState>> {
//   late final JewelleryApiService _api;

//   @override
//   AsyncValue<JewelleryCalcState> build() {
//     _api = ref.read(jewelleryApiServiceProvider);
//     return const AsyncValue.data(JewelleryCalcState());
//   }

//   Future<void> init(String productCode) async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       // 1) fetch detail
//       final detail = await _api.getJewelleryProductDetail(
//         productCode: productCode,
//       );

//       // 2) base size & carat
//       final base = JewelleryCalculationService.getBaseSizeCarat(detail);

//       // 3) pcs & weights
//       final totalSolitairePcs = JewelleryCalculationService.getPcs(
//         detail.variants,
//         detail.bom,
//         'SOLITAIRE',
//         'STONE',
//       );
//       final goldWeight = JewelleryCalculationService.getWeight(
//         detail.variants,
//         detail.bom,
//         'GOLD',
//         'METAL',
//       );
//       final platinumWeight = JewelleryCalculationService.getWeight(
//         detail.variants,
//         detail.bom,
//         'PLATINUM',
//         'METAL',
//       );
//       final sidePcs = JewelleryCalculationService.getPcs(
//         detail.variants,
//         detail.bom,
//         'DIAMOND',
//         'STONE',
//       );
//       final sideWeight = JewelleryCalculationService.getWeight(
//         detail.variants,
//         detail.bom,
//         'DIAMOND',
//         'STONE',
//       );

//       // 4) initial metal + side amounts (use your logic)
//       final metalAmount =
//           await JewelleryCalculationService.calculateMetalAmount(
//             metalColor: detail.metalColor,
//             metalPurity: detail.metalPurity.split(',').first.trim(),
//             goldWeight: goldWeight,
//             platinumWeight: platinumWeight,
//             qty: 1,
//             mode: 'Init',
//           );

//       final sideAmount =
//           await JewelleryCalculationService.calculateSideDiamondPrice(
//             totalSideCts: sideWeight,
//             colorClarity: '', // fill from UI / cart when you have it
//             qty: 1,
//           );

//       return JewelleryCalcState(
//         detail: detail,
//         qty: 1,
//         baseSize: base.baseSize,
//         baseCarat: base.baseCarat,
//         totalSolitairePcs: totalSolitairePcs,
//         goldWeight: goldWeight,
//         platinumWeight: platinumWeight,
//         sidePcs: sidePcs,
//         sideWeight: sideWeight,
//         metalAmount: metalAmount,
//         sideAmount: sideAmount,
//       );
//     });
//   }

//   void updateQty(int qty) {
//     state = state.when(
//       data: (s) => AsyncValue.data(s.copyWith(qty: qty)),
//       loading: () => state,
//       error: (e, st) => state,
//     );
//   }
// }

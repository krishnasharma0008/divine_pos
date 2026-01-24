// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/jewellery_calculation_service.dart';
// import 'jewellery_detail_provider.dart';

// final solitaireMessageProvider = Provider<String>((ref) {
//   final detail = ref.watch(jewelleryDetailProvider);
//   if (detail?.variants == null || detail!.bom.isEmpty) return '';

//   // Count base variant SOLITAIRE stones
//   final baseSolitaireCount = detail.variants
//       .where((v) => v.isBaseVariant)
//       .expand(
//         (v) => detail.bom.where(
//           (b) =>
//               b.variantId == v.variantId &&
//               b.itemGroup == 'SOLITAIRE' &&
//               b.itemType == 'STONE',
//         ),
//       )
//       .length;

//   // Total SOLITAIRE stones across all variants
//   final totalSolitairePcs = JewelleryCalculationService.getPcs(
//     detail.variants,
//     detail.bom,
//     'SOLITAIRE',
//     'STONE',
//   );

//   // Determine message
//   return _getSolitaireMessage(baseSolitaireCount, totalSolitairePcs);
// });

// String _getSolitaireMessage(int baseCount, int totalCount) {
//   if (baseCount > 1) {
//     return 'This is multi size - solitaire product';
//   } else if (totalCount > 1) {
//     return 'This is multi - solitaire product';
//   }
//   return '';
// }

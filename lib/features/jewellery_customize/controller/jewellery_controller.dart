// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../provider/jewellery_detail_provider.dart';
// import '../provider/qty_provider.dart';
// import '../provider/metal_provider.dart';
// import '../provider/ring_size_provider.dart';
// import '../provider/side_diamond_provider.dart';
// import '../data/jewellery_detail_model.dart';

// final jewelleryControllerProvider = Provider<JewelleryController>((ref) {
//   return JewelleryController(ref);
// });

// class JewelleryController {
//   final Ref ref;
//   JewelleryController(this.ref);

//   // Product Detail
//   Future<void> setDetail(JewelleryDetail detail) async {
//     await ref
//         .read(jewelleryDetailProvider.notifier)
//         .fetchDetail(detail.productCode ?? '');
//   }

//   // Quantity
//   void setQty(int qty) {
//     ref.read(qtyProvider.notifier).state = qty;
//   }

//   // Metal
//   void setMetalPurity(String purity) {
//     ref.read(metalPurityProvider.notifier).state = purity;
//   }

//   void setMetalColor(String color) {
//     ref.read(metalColorProvider.notifier).state = color;
//   }

//   // Ring Size
//   void setRingSizeDiff(double diff) {
//     ref.read(ringSizeDiffProvider.notifier).state = diff;
//   }

//   // Side Diamond
//   void setSideDiamondClarity(String clarity) {
//     ref.read(sideDiamondClarityProvider.notifier).state = clarity;
//   }

//   // 🆕 Batch Update (Riverpod 3.0.3 optimized)
//   void updateAll({
//     JewelleryDetail? detail,
//     int? qty,
//     String? metalPurity,
//     String? metalColor,
//     double? ringSizeDiff,
//     String? sideDiamondClarity,
//   }) async {
//     if (detail != null) await setDetail(detail);
//     if (qty != null) setQty(qty);
//     if (metalPurity != null) setMetalPurity(metalPurity);
//     if (metalColor != null) setMetalColor(metalColor);
//     if (ringSizeDiff != null) setRingSizeDiff(ringSizeDiff);
//     if (sideDiamondClarity != null) setSideDiamondClarity(sideDiamondClarity);
//   }

//   // 🆕 Current Values (Riverpod 3.0.3 safe reads)
//   AsyncValue<JewelleryDetail?> get detail => ref.read(jewelleryDetailProvider);
//   int get qty => ref.read(qtyProvider);
//   String get metalPurity => ref.read(metalPurityProvider);
//   String get metalColor => ref.read(metalColorProvider);
//   double get ringSizeDiff => ref.read(ringSizeDiffProvider);
//   String get sideDiamondClarity => ref.read(sideDiamondClarityProvider);
// }

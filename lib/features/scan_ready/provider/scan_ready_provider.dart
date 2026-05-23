import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jewellery_customize/data/jewellery_calc_state.dart';
import '../../jewellery_customize/provider/jewellery_calc_provider.dart';
import '../data/product_model.dart';
import 'package:divine_pos/features/auth/data/auth_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ScanReadyState {
  final List<ProductModel> products;
  final bool isLoading;

  const ScanReadyState({this.products = const [], this.isLoading = false});

  ScanReadyState copyWith({List<ProductModel>? products, bool? isLoading}) =>
      ScanReadyState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final scanReadyProvider =
    AsyncNotifierProvider<ScanReadyNotifier, ScanReadyState>(
      ScanReadyNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ScanReadyNotifier extends AsyncNotifier<ScanReadyState> {
  late final String _lyingWith;

  static const int _maxProducts = 4;

  @override
  Future<ScanReadyState> build() async {
    // ref is only valid inside build() and methods — never at class-field level.
    final authRepo = ref.read(authProvider);
    final raw = authRepo.user?.pjcode ?? '';
    _lyingWith = raw.split(',').first.trim();

    return const ScanReadyState();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void clearAll() {
    state = const AsyncData(ScanReadyState());
  }

  void removeProduct(ProductModel removed) {
    final current = state.value;
    if (current == null) return;

    final updated = current.products.where((p) {
      if (removed.itemno?.trim().isNotEmpty == true &&
          p.itemno?.trim().isNotEmpty == true) {
        return p.itemno!.trim() != removed.itemno!.trim();
      }
      if (removed.designno?.trim().isNotEmpty == true &&
          p.designno?.trim().isNotEmpty == true) {
        return p.designno!.trim() != removed.designno!.trim();
      }
      return p.id != removed.id;
    }).toList();

    state = AsyncData(current.copyWith(products: updated));
  }

  Future<ProductModel> addByScannedCode(String productCode) async {
    final code = productCode.trim();
    if (code.isEmpty) throw Exception('Invalid QR code');

    final current = state.value ?? const ScanReadyState();

    if (current.products.length >= _maxProducts) {
      throw Exception('Maximum $_maxProducts products can be compared');
    }

    state = AsyncData(current.copyWith(isLoading: true));

    final sub = ref.listen(jewelleryCalcProvider, (_, __) {});

    try {
      // Reset any state left from a previous scan.
      ref.invalidate(jewelleryCalcProvider);

      await ref
          .read(jewelleryCalcProvider.notifier)
          .loadDetail(code, _lyingWith);

      // Read immediately after await — provider is still alive because sub
      // is open.
      final calcState = ref.read(jewelleryCalcProvider).value;

      if (calcState == null || calcState.detail == null) {
        throw Exception('No product found for: $code');
      }

      // Duplicate check.
      final alreadyAdded = current.products.any((p) {
        final sameItem =
            p.itemno?.trim().isNotEmpty == true &&
            calcState.detail!.itemNumber.trim().isNotEmpty &&
            p.itemno!.trim() == calcState.detail!.itemNumber.trim();

        final sameDesign =
            p.designno?.trim().isNotEmpty == true &&
            calcState.detail!.designno?.trim().isNotEmpty == true &&
            p.designno!.trim() == calcState.detail!.designno!.trim();

        return sameItem || sameDesign;
      });

      if (alreadyAdded) {
        throw Exception('This product is already in the comparison.');
      }

      final product = _toProductModel(calcState);

      final updated = [...current.products, product];
      state = AsyncData(ScanReadyState(products: updated, isLoading: false));

      debugPrint(
        '✅ Compare: added ${product.designno ?? product.itemno} '
        '| price ₹${product.productAmtMin?.toStringAsFixed(0)} – '
        '₹${product.productAmtMax?.toStringAsFixed(0)}',
      );

      return product;
    } catch (e) {
      state = AsyncData(current.copyWith(isLoading: false));
      rethrow;
    } finally {
      // Always release the keep-alive so autoDispose can work normally
      // for the next scan.
      sub.close();
    }
  }

  // ── JewelleryCalcState → ProductModel ──────────────────────────────────────
  static ProductModel _toProductModel(JewelleryCalcState s) {
    final d = s.detail!;

    final sideParts = (s.selectedSideDiamondQuality ?? '').split('-');
    final sideColor = sideParts.isNotEmpty ? sideParts.first.trim() : '';
    final sideQuality = sideParts.length > 1 ? sideParts.last.trim() : '';

    return ProductModel(
      id: 0,

      itemno: d.itemNumber,
      designno: d.designno,

      // First URL from the first ProductImage in the images list.
      // images → List<ProductImage>, each has List<String> imageUrls.
      imageUrl: d.images.firstOrNull?.imageUrls.firstOrNull,

      productCategory: d.productCategory,
      productSubCategory: d.productSubCategory,

      productAmtMin: s.approxPriceFrom,
      productAmtMax: s.approxPriceTo ?? s.approxPriceFrom,

      solitaireShape: s.solitaireShape,
      solitaireSlab: s.caratRange?.replaceAll('ct', '').replaceAll(' ', ''),
      solitaireColor: s.colorRange,
      solitaireQuality: s.clarityRange,
      solitairePcs: s.totalSolitairePcs,
      solitaireAmtMin: s.solitaireAmountFrom,
      solitaireAmtMax: s.solitaireAmountTo ?? s.solitaireAmountFrom,

      metalType: (s.selectedMetalPurity ?? '') == '950PT' ? 'PLATINUM' : 'GOLD',
      metalColor: s.selectedMetalColor,
      metalPurity: s.selectedMetalPurity,
      metalWeight: s.netMetalWeight,
      metalPrice: s.metalAmount,

      sideStonePcs: s.totalSidePcs,
      sideStoneCtw: s.totalSideWeight,
      sideStoneColor: sideColor,
      sideStoneQuality: sideQuality,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../verify_track/data/verify_track_model.dart';
import '../../verify_track/provider/verify_track_providers.dart';
import '../data/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReadyProductState {
  final List<ProductModel> products;
  final bool isLoading;

  const ReadyProductState({this.products = const [], this.isLoading = false});

  ReadyProductState copyWith({List<ProductModel>? products, bool? isLoading}) =>
      ReadyProductState(
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final readyProductProvider =
    AsyncNotifierProvider<ReadyProductNotifier, ReadyProductState>(
      ReadyProductNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ReadyProductNotifier extends AsyncNotifier<ReadyProductState> {
  static const int _maxProducts = 4;

  @override
  Future<ReadyProductState> build() async => const ReadyProductState();

  // ── Public API ─────────────────────────────────────────────────────────────

  void clearAll() {
    state = const AsyncData(ReadyProductState());
  }

  void removeProduct(ProductModel removed) {
    final current = state.value;
    if (current == null) return;

    final updated = current.products.where((p) {
      // Match by UID (itemno) first, then designno, then fallback to id.
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

    final current = state.value ?? const ReadyProductState();

    if (current.products.length >= _maxProducts) {
      throw Exception('Maximum $_maxProducts products can be compared');
    }

    state = AsyncData(current.copyWith(isLoading: true));

    try {
      // ── Fetch from VerifyTrack API ─────────────────────────────────────
      final response = await ref
          .read(verifyTrackRepositoryProvider)
          .getVerifyTrackByUid(uid: code);

      if (!response.isSuccess || response.data == null) {
        throw Exception('No product found for: $code');
      }

      final data = response.data!;

      debugPrint(
        '✅ Fetched product for code "$code": '
        'itemno=${data.uid}, designNo=${data.designNo}, '
        'category=${data.category}, price=${data.currentPrice}, Mount=${data.mountDetails1}',
      );
      // ── Duplicate check ───────────────────────────────────────────────
      final alreadyAdded = current.products.any(
        (p) =>
            (p.itemno?.trim().isNotEmpty == true &&
                p.itemno!.trim() == data.uid.trim()) ||
            (p.designno?.trim().isNotEmpty == true &&
                p.designno!.trim() == data.designNo.trim()),
      );

      if (alreadyAdded) {
        throw Exception('This product is already in the comparison.');
      }

      final product = _toProductModel(data);

      final updated = [...current.products, product];
      state = AsyncData(ReadyProductState(products: updated, isLoading: false));

      // debugPrint(
      //   '✅ Compare: added ${product.designno ?? product.itemno} '
      //   '| price ₹${product.productAmtMax?.toStringAsFixed(0)}',
      // );

      return product;
    } catch (e) {
      state = AsyncData(current.copyWith(isLoading: false));
      rethrow;
    }
  }

  // ── VerifyTrackByUid → ProductModel ────────────────────────────────────────

  static ProductModel _toProductModel(VerifyTrackByUid d) {
    // ── Solitaire ────────────────────────────────────────────────────────
    // Use first slt_detail entry for shape / colour / clarity;
    // aggregate weight and pcs from the totals.
    final firstSlt = d.sltDetails.isNotEmpty ? d.sltDetails.first : null;

    final solitaireShape = firstSlt != null && firstSlt.shape.trim().isNotEmpty
        ? firstSlt.shape.trim()
        : null;
    final solitaireColor = firstSlt != null && firstSlt.colour.trim().isNotEmpty
        ? firstSlt.colour.trim()
        : null;
    final solitaireQuality =
        firstSlt != null && firstSlt.clarity.trim().isNotEmpty
        ? firstSlt.clarity.trim()
        : null;

    // sltTotalCts stored as "0.030" — kept as-is for the slab field.
    final solitaireSlab = d.sltTotalCts > 0
        ? d.sltTotalCts.toStringAsFixed(3)
        : null;

    // ── Side diamonds ─────────────────────────────────────────────────────
    // sdColourClarity is a combined string e.g. "IJ SI1" or "IJ-SI1".
    // Split on space or hyphen; first token → colour, second → clarity.
    String? sdColor;
    String? sdQuality;
    final sdRaw = d.sdColourClarity.trim();
    if (sdRaw.isNotEmpty) {
      final parts = sdRaw.split(RegExp(r'[\s\-]+'));
      sdColor = parts.isNotEmpty ? parts.first : null;
      sdQuality = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    // ── Size ──────────────────────────────────────────────────────────────
    // jewellerySize may be a single value ("12") or a range ("12-14").
    String? sizeFrom;
    String? sizeTo;
    final sizeRaw = d.jewellerySize.trim();
    if (sizeRaw.isNotEmpty) {
      final sizeParts = sizeRaw.split('-');
      sizeFrom = sizeParts.first.trim();
      sizeTo = sizeParts.length > 1 ? sizeParts.last.trim() : null;
    }

    return ProductModel(
      id: 0, // No integer ID in VerifyTrackByUid; UID is the identifier.
      // UID → itemno  |  designNo → designno
      itemno: d.uid.isNotEmpty ? d.uid : null,
      designno: d.designNo.isNotEmpty ? d.designNo : null,

      // Image: prefer the primary image field; fall back to first in list.
      imageUrl: d.image.isNotEmpty
          ? d.image
          : (d.images.isNotEmpty ? d.images.first : null),

      // Category / collection
      productCategory: d.category.isNotEmpty ? d.category : null,
      collection: d.collection.isNotEmpty ? d.collection : null,
      productType: d.productType.isNotEmpty ? d.productType : null,

      // Pricing  —  currentPrice is the live MRP.
      productAmtMin: d.currentPrice > 0 ? d.currentPrice : null,
      productAmtMax: d.currentPrice > 0 ? d.currentPrice : null,

      // Mount amount comes from metalTotalCurrentPrice.
      mountAmtMin: d.metalTotalCurrentPrice > 0
          ? d.metalTotalCurrentPrice
          : null,
      mountAmtMax: d.metalTotalCurrentPrice > 0
          ? d.metalTotalCurrentPrice
          : null,

      // Solitaire
      solitaireShape: solitaireShape,
      solitaireSlab: solitaireSlab,
      solitaireColor: solitaireColor,
      solitaireQuality: solitaireQuality,
      solitairePcs: d.sltTotalPcs > 0 ? d.sltTotalPcs : null,
      solitaireAmtMin: d.sltTotalCurrentPrice > 0
          ? d.sltTotalCurrentPrice
          : null,
      solitaireAmtMax: d.sltTotalCurrentPrice > 0
          ? d.sltTotalCurrentPrice
          : null,

      // Metal  —  API gives net weight and total metal price.
      // No purity / color / type returned by this endpoint.
      mountDetails1: d.mountDetails1.isNotEmpty ? d.mountDetails1 : null,
      metalWeight: d.netWt > 0 ? d.netWt : null,
      metalPrice: d.metalTotalCurrentPrice > 0
          ? d.metalTotalCurrentPrice
          : null,

      // Side diamonds
      sideStonePcs: d.sdPcs > 0 ? d.sdPcs : null,
      sideStoneCtw: d.sdCts > 0 ? d.sdCts : null,
      sideStoneColor: sdColor,
      sideStoneQuality: sdQuality,

      // Size
      sizeFrom: sizeFrom,
      sizeTo: sizeTo,
    );
  }

  void longPrint(Object? obj) {
    const chunkSize = 800;
    final str = obj.toString();
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      debugPrint(str.substring(i, end));
    }
  }
}

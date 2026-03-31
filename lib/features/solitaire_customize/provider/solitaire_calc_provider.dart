import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solitaire_detail_model.dart';
import '../data/solitaire_filter.dart';
import '../data/solitaire_calc_state.dart';
import 'solitaire_detail_provider.dart';

final solitaireCalcProvider =
    AsyncNotifierProvider.autoDispose<
      SolitaireCalcNotifier,
      SolitaireCalcState
    >(SolitaireCalcNotifier.new);

class SolitaireCalcNotifier extends AsyncNotifier<SolitaireCalcState> {
  @override
  Future<SolitaireCalcState> build() async {
    final detail = ref.read(solitaireDetailProvider).value;
    return SolitaireCalcState(
      detail: detail,
      solitaireShape: detail?.shape ?? 'RND',
    );
  }

  // ---------------------------------------------------------------------------
  // Calculate from a SolitaireDetail directly (initial load + Default Value)
  // ---------------------------------------------------------------------------
  Future<void> calculateFromDetail(SolitaireDetail detail) async {
    debugPrint(
      "calculateFromDetail → shape:${detail.shape} "
      "weight:${detail.weight} color:${detail.color} "
      "clarity:${detail.clarity} pcs:${detail.pcs}",
    );

    final calcState = SolitaireCalcState(
      detail: detail,
      solitaireShape: detail.shape,
      caratRange: '${detail.weight} - ${detail.weight} ct',
      colorRange: detail.color,
      clarityRange: detail.clarity,
      isCustomized: false,
    );

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await _recalculatePrice(calcState);
    });
  }

  // ---------------------------------------------------------------------------
  // Apply a customization filter from the drawer.
  //
  // Returns:
  //   true  → something changed, API was called, UI should show snackbar
  //   false → nothing changed, API was skipped, UI should stay silent
  // ---------------------------------------------------------------------------
  Future<bool> applyFilter(SolitaireFilter filter) async {
    debugPrint("applyFilter → ${filter.toJson()}");

    final current = state.value;
    if (current == null) return false;

    // Build the values the filter would produce
    final newShape = filter.shape;
    final newCaratRange = filter.carat != null
        ? '${filter.carat!.startValue} - ${filter.carat!.endValue} ct'
        : null;
    final newColorRange = filter.color?.displayRange;
    final newClarityRange = filter.clarity?.displayRange;

    // If every meaningful field matches what is already in state the user
    // tapped "Apply Customization" without changing anything — skip the API.
    final nothingChanged =
        newShape == current.solitaireShape &&
        newCaratRange == current.caratRange &&
        newColorRange == current.colorRange &&
        newClarityRange == current.clarityRange;

    if (nothingChanged) {
      debugPrint("applyFilter → nothing changed, skipping recalculation");
      return false;
    }

    final updated = current.copyWith(
      solitaireShape: newShape,
      priceRange: filter.price != null
          ? '₹${filter.price!.startValue} - ${filter.price!.endValue}'
          : null,
      caratRange: newCaratRange,
      colorRange: newColorRange,
      clarityRange: newClarityRange,
    );

    state = const AsyncLoading();

    // state = await AsyncValue.guard(() async {
    //   return await _recalculatePrice(updated);
    // });

    state = await AsyncValue.guard(() async {
      final result = await _recalculatePrice(updated);
      return result.copyWith(isCustomized: true); // ← mark
    });

    return true;
  }

  // ---------------------------------------------------------------------------
  // Internal: single price API call
  // ---------------------------------------------------------------------------
  Future<double> _fetchPrice({
    required String itemGroup,
    String? slab,
    String? shape,
    String? color,
    String? quality,
  }) {
    return ref
        .read(solitaireDetailProvider.notifier)
        .fetchPrice(
          itemGroup: itemGroup,
          slab: slab,
          shape: shape,
          color: color,
          quality: quality,
        );
  }

  // ---------------------------------------------------------------------------
  // Internal: full price recalculation
  // ---------------------------------------------------------------------------
  Future<SolitaireCalcState> _recalculatePrice(
    SolitaireCalcState current,
  ) async {
    final detail = current.detail;

    // When detail is null (opened without an item), still calculate
    // using the values set by the filter — just use pcs=1, qty=1.
    final shapeCode = current.solitaireShape ?? detail?.shape ?? 'RND';

    double parseCt(String s) => double.tryParse(s.trim()) ?? 0.10;

    double minCt = detail?.weight ?? 0.18;
    double maxCt = detail?.weight ?? 0.22;

    if (current.caratRange != null) {
      final parts = current.caratRange!
          .replaceAll('ct', '')
          .split('-')
          .map((e) => e.trim())
          .toList();
      if (parts.length == 2) {
        minCt = parseCt(parts.first);
        maxCt = parseCt(parts.last);
      }
    }

    final selectedColorFrom =
        current.colorRange?.split('-').first.trim() ?? detail?.color ?? 'G';
    final selectedColorTo =
        current.colorRange?.split('-').last.trim() ?? selectedColorFrom;

    final selectedClarityFrom =
        current.clarityRange?.split('-').first.trim() ??
        detail?.clarity ??
        'VS';
    final selectedClarityTo =
        current.clarityRange?.split('-').last.trim() ?? selectedClarityFrom;

    // Use detail pcs if available, else 1
    final pcs = (detail?.pcs ?? 1) > 0 ? (detail?.pcs ?? 1) : 1;
    final qty = current.selectedQty;

    final rateFrom = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: minCt.toStringAsFixed(2),
      shape: shapeCode,
      color: getSolitaireColor(selectedColorFrom),
      quality: selectedClarityFrom,
    );

    final rateTo = await _fetchPrice(
      itemGroup: 'SOLITAIRE',
      slab: maxCt.toStringAsFixed(2),
      shape: shapeCode,
      color: getSolitaireColor(selectedColorTo),
      quality: selectedClarityTo,
    );

    final solFrom = rateFrom * minCt * pcs * qty;
    final solTo = rateTo * maxCt * pcs * qty;

    return current.copyWith(
      approxPriceFrom: solFrom,
      approxPriceTo: solTo,
      solitaireAmountFrom: solFrom,
      solitaireAmountTo: solTo,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static String mapShapeCodeToName(String code) {
    const shapeMap = {
      'RND': 'Round',
      'PRN': 'Princess',
      'OVL': 'Oval',
      'PER': 'Pear',
      'RADQ': 'Radiant',
      'CUSQ': 'Cushion',
      'HRT': 'Heart',
      'MAQ': 'Marquise',
    };
    return shapeMap[code] ?? 'Round';
  }

  static String getSolitaireColor(String color) {
    if (color == 'Yellow Vivid') return 'VDY';
    if (color == 'Yellow Intense') return 'INY';
    return color;
  }
}

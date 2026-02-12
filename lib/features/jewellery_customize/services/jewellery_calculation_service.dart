import '../data/jewellery_detail_model.dart';
import '../data/variant_model.dart';
import '../data/bom_model.dart';

class JewelleryCalculationService {
  /// -----------------------------
  /// PCS / WEIGHT HELPERS
  /// -----------------------------

  static int getPcs(
    List<Variant> variants,
    List<Bom> bom,
    String itemGroup,
    String itemType,
  ) {
    return variants
        .where((v) => v.isBaseVariant == 1 || v.isBaseVariant == true)
        .fold<int>(0, (acc, variant) {
          final matchingBom = bom.where(
            (b) =>
                b.variantId == variant.variantId &&
                (b.itemGroup ?? '').toUpperCase() == itemGroup.toUpperCase() &&
                (b.itemType ?? '').toUpperCase() == itemType.toUpperCase(),
          );
          return acc + matchingBom.fold<int>(0, (s, b) => s + b.pcs);
        });
  }

  static double getWeight(
    List<Variant> variants,
    List<Bom> bom,
    String itemGroup,
    String itemType,
  ) {
    return variants
        .where((v) => v.isBaseVariant == 1 || v.isBaseVariant == true)
        .fold<double>(0, (acc, variant) {
          final matchingBom = bom.where(
            (b) =>
                b.variantId == variant.variantId &&
                (b.itemGroup ?? '').toUpperCase() == itemGroup.toUpperCase() &&
                (b.itemType ?? '').toUpperCase() == itemType.toUpperCase(),
          );
          return acc + matchingBom.fold<double>(0, (s, b) => s + b.weight);
        });
  }

  static double getNetMetalWeight(List<Variant> variants, List<Bom> bom) {
    return getWeight(variants, bom, 'GOLD', 'METAL') +
        getWeight(variants, bom, 'PLATINUM', 'METAL');
  }

  /// -----------------------------
  /// BASE SIZE / CARAT
  /// -----------------------------

  static ({double? baseSize, String? baseCarat}) getBaseSizeCarat(
    JewelleryDetail detail,
  ) {
    if (detail.productSizeFrom == '-') {
      return (baseSize: null, baseCarat: null);
    }

    final baseVariants = detail.variants
        .where((v) => v.isBaseVariant == 1 || v.isBaseVariant == true)
        .toList();

    final baseSize = baseVariants
        .map((v) => double.tryParse(v.size))
        .whereType<double>()
        .cast<double?>()
        .firstOrNull;

    final baseCarat = baseVariants
        .map((v) => v.solitaireSlab.isNotEmpty ? v.solitaireSlab : null)
        .whereType<String>()
        .cast<String?>()
        .firstOrNull;

    return (baseSize: baseSize, baseCarat: baseCarat);
  }

  /// -----------------------------
  /// DEFAULT SOLITAIRE SHAPE
  /// -----------------------------

  static String getDefaultSolitaireShapeCode({
    required List<Variant> variants,
    required List<Bom> bom,
  }) {
    final shapeCodes = variants
        .where((v) => v.isBaseVariant == 1 || v.isBaseVariant == true)
        .expand((variant) {
          return bom.where(
            (b) =>
                b.variantId == variant.variantId &&
                b.itemGroup == 'SOLITAIRE' &&
                b.itemType == 'STONE',
          );
        })
        .map((b) => b.bomVariantName)
        .whereType<String>()
        .map((name) {
          final parts = name.split('-');
          return parts.length > 1 ? parts[1] : null;
        })
        .whereType<String>()
        .toSet()
        .toList();

    // Return the raw code: RND, PRN, etc.
    return shapeCodes.isNotEmpty ? shapeCodes.first : 'RND';
  }

  // Optional: pretty label for UI
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
    if (color == "Yellow Vivid") {
      return "VDY";
    } else if (color == "Yellow Intense") {
      return "INY";
    }
    return color;
  }

  /// -----------------------------
  /// MESSAGES
  /// -----------------------------

  static int getSolitaireRowCount(List<Variant> variants, List<Bom> bom) {
    return variants
        .where((v) => v.isBaseVariant == 1 || v.isBaseVariant == true)
        .fold<int>(0, (acc, variant) {
          final matchingBom = bom.where(
            (b) =>
                b.variantId == variant.variantId &&
                b.itemGroup == 'SOLITAIRE' &&
                b.itemType == 'STONE',
          );
          return acc + matchingBom.length;
        });
  }

  static String getMultiSolitaireMessage({
    required List<Variant> variants,
    required List<Bom> bom,
    required int totalPcs,
  }) {
    final rowCount = getSolitaireRowCount(variants, bom);

    if (rowCount > 1) return 'This is multi size - solitaire product';
    if (totalPcs > 1) return 'This is multi - solitaire product';
    return '';
  }

  /// -----------------------------
  /// DIVINE MOUNT ADJUSTMENT
  /// -----------------------------
  /// Returns a multiplicative factor based on size difference.
  static double calculateDivineMountAdjustment({
    required String carat,
    required double size,
    required double baseRingSize,
    required int qty,
  }) {
    // 3% per size difference (tune if needed)
    const adjustPercentPerSize = 3 / 100; // 3%

    final sizeDifference = size - baseRingSize;
    final factor = 1 + (sizeDifference * adjustPercentPerSize);

    return factor;
  }

  /// -----------------------------
  /// METAL & SIDE DIAMOND
  /// -----------------------------

  static String getValidPurity(String metal, String purity) {
    if (metal.toLowerCase() == 'gold' && purity == '950PT') {
      return '18KT';
    }
    return purity;
  }

  static String getMetalColor(String metal, String color) {
    final normalizedMetal = metal.trim().toLowerCase();
    final normalizedColor = color.trim().toLowerCase();

    // Platinum → always White
    if (normalizedMetal == 'platinum') {
      return 'White';
    }

    if (normalizedMetal == 'gold') {
      if (normalizedColor.contains('yellow gold') ||
          normalizedColor.contains('yellow')) {
        return 'Yellow';
      } else if (normalizedColor.contains('rose gold') ||
          normalizedColor.contains('rose')) {
        return 'Rose';
      } else if (normalizedColor.contains('white gold') ||
          normalizedColor.contains('white')) {
        return 'White';
      }
    }

    return '';
  }

  static Future<double> calculateSideDiamondPrice({
    required double price,
    required double totalSideCts,
    required int qty,
  }) async {
    return totalSideCts * price * qty;
  }

  /// -----------------------------
  /// SOLITAIRE AMOUNT RANGE (LOCAL)
  /// -----------------------------
  ///

  static Future<({double solFrom, double solTo})>
  calculateSolitaireAmountRangeLocal({
    required JewelleryDetail detail,
    required int qty,
    required double premiumPct,
    required Future<double> Function({
      required String itemGroup,
      String? slab,
      String? shape,
      String? color,
      String? quality,
    })
    fetchPrice,
    required double? userMinCt, // parseFloat(carat[0])
    required String? userColorFrom, // color[0]
    required String? userColorTo, // color[1]
    required String? userClarityFrom, // clarity[0]
    required String? userClarityTo, // clarity[1]
  }) async {
    double amountFrom = 0;
    double amountTo = 0;

    final variants = detail.variants ?? [];
    if (variants.isEmpty) return (solFrom: 0.0, solTo: 0.0);

    // JS: Variant_id === data.variantId (हम यहाँ base variant ले रहे हैं;
    // अगर तुम variantId state में रख रहे हो तो उसे यहाँ pass कर सकते हो)
    final activeVariant = variants.firstWhere(
      (v) => v.isBaseVariant == 1 || v.isBaseVariant == true,
      orElse: () => variants.first,
    );
    final activeVariantId = activeVariant.variantId;

    final bomList = detail.bom.where(
      (b) =>
          b.variantId == activeVariantId &&
          (b.itemGroup ?? '').trim().toUpperCase() == 'SOLITAIRE' &&
          (b.itemType ?? '').trim().toUpperCase() == 'STONE',
    );

    for (final row in bomList) {
      final name = row.bomVariantName ?? '';
      final parts = name.trim().split('-').map((p) => p.trim()).toList();
      if (parts.length < 4) continue;

      final shape = parts[1]; // RND / PER / PRN / OVL ...
      final bomCaratFrom = double.tryParse(parts[2]) ?? 0.0;
      final bomCaratTo = double.tryParse(parts[3]) ?? 0.0;
      final pcs = row.pcs.toDouble();

      // -------- JS वाले 4 rules ----------
      String bomColorMin = '';
      String bomColorMax = '';
      String bomClarityMin = '';
      String bomClarityMax = '';

      final cFrom = bomCaratFrom;
      final cTo = bomCaratTo;

      if ((shape == 'PER' || shape == 'PRN' || shape == 'OVL') &&
          cFrom >= 0.10 &&
          cTo <= 0.17) {
        // Fancy 0.10–0.17
        bomColorMin = 'GH';
        bomColorMax = 'EF';
        bomClarityMin = 'VS';
        bomClarityMax = 'VVS';
      } else if ((shape == 'PER' || shape == 'PRN' || shape == 'OVL') &&
          cFrom >= 0.18 &&
          cTo <= 0.22) {
        // Fancy 0.18–0.22
        bomColorMin = 'K';
        bomColorMax = 'D';
        bomClarityMin = 'SI1';
        bomClarityMax = 'IF';
      } else if (shape == 'RND' && cFrom >= 0.10 && cTo <= 0.17) {
        // Round 0.10–0.17
        bomColorMin = 'IJ';
        bomColorMax = 'EF';
        bomClarityMin = 'SI';
        bomClarityMax = 'VVS';
      } else if (shape == 'RND' && cFrom >= 0.18 && cTo <= 0.22) {
        // Round 0.18–0.22
        bomColorMin = 'K';
        bomColorMax = 'D';
        bomClarityMin = 'SI2';
        bomClarityMax = 'IF';
      }

      // -------- user selection override logic (JS जैसा) ----------
      // JS cond: parseFloat(carat[0]) === bomCaratFrom ? user color/clarity : bom defaults
      final bool isUserSlab =
          userMinCt != null && (userMinCt - bomCaratFrom).abs() < 0.0001;

      final fromColor =
          isUserSlab && userColorTo != null && userColorTo.isNotEmpty
          ? userColorTo
          : bomColorMin;
      final toColor =
          isUserSlab && userColorFrom != null && userColorFrom.isNotEmpty
          ? userColorFrom
          : bomColorMax;

      final fromClarity =
          isUserSlab && userClarityTo != null && userClarityTo.isNotEmpty
          ? userClarityTo
          : bomClarityMin;
      final toClarity =
          isUserSlab && userClarityFrom != null && userClarityFrom.isNotEmpty
          ? userClarityFrom
          : bomClarityMax;

      if (fromColor.isEmpty ||
          toColor.isEmpty ||
          fromClarity.isEmpty ||
          toClarity.isEmpty) {
        // अगर rules से कुछ भी नहीं मिला तो इस row को skip कर दो
        continue;
      }

      // -------- price fetch per BOM row ----------
      final priceFrom = await fetchPrice(
        itemGroup: 'SOLITAIRE',
        slab: bomCaratFrom.toStringAsFixed(2),
        shape: shape,
        color: JewelleryCalculationService.getSolitaireColor(fromColor),
        quality: fromClarity,
      );

      final priceTo = await fetchPrice(
        itemGroup: 'SOLITAIRE',
        slab: bomCaratTo.toStringAsFixed(2),
        shape: shape,
        color: JewelleryCalculationService.getSolitaireColor(toColor),
        quality: toClarity,
      );

      final premiumMinPrice = priceFrom + priceFrom * (premiumPct / 100);
      final premiumMaxPrice = priceTo + priceTo * (premiumPct / 100);

      amountFrom += premiumMinPrice * bomCaratFrom * qty * pcs;
      amountTo += premiumMaxPrice * bomCaratTo * qty * pcs;
    }

    return (solFrom: amountFrom, solTo: amountTo);
  }

  // static ({double solFrom, double solTo}) calculateSolitaireAmountRangeLocal({
  //   required JewelleryDetail detail,
  //   required int qty,
  //   required double rateFromPerCt, // already with premium
  //   required double rateToPerCt, // already with premium
  // }) {
  //   double amountFrom = 0;
  //   double amountTo = 0;

  //   final variants = detail.variants ?? [];
  //   if (variants.isEmpty) {
  //     return (solFrom: 0, solTo: 0);
  //   }

  //   final activeVariant = variants.firstWhere(
  //     (v) => v.isBaseVariant == 1 || v.isBaseVariant == true,
  //     orElse: () => variants.first,
  //   );
  //   final activeVariantId = activeVariant.variantId;

  //   final bomList = detail.bom.where(
  //     (b) =>
  //         b.variantId == activeVariantId &&
  //         (b.itemGroup ?? '').trim().toUpperCase() == 'SOLITAIRE' &&
  //         (b.itemType ?? '').trim().toUpperCase() == 'STONE',
  //   );

  //   for (final row in bomList) {
  //     final name = row.bomVariantName ?? '';
  //     final parts = name.trim().split('-').map((p) => p.trim()).toList();
  //     if (parts.length < 4) continue;

  //     final bomCaratFrom = double.tryParse(parts[2]) ?? 0.0;
  //     final bomCaratTo = double.tryParse(parts[3]) ?? 0.0;
  //     final pcs = row.pcs.toDouble();

  //     amountFrom += rateFromPerCt * bomCaratFrom * pcs * qty;
  //     amountTo += rateToPerCt * bomCaratTo * pcs * qty;
  //   }

  //   return (solFrom: amountFrom, solTo: amountTo);
  // }
}

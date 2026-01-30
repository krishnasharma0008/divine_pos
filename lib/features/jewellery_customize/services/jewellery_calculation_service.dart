
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

  static ({double solFrom, double solTo}) calculateSolitaireAmountRangeLocal({
    required JewelleryDetail detail,
    required int qty,
    required double rateFromPerCt, // already with premium
    required double rateToPerCt, // already with premium
  }) {
    double amountFrom = 0;
    double amountTo = 0;

    final variants = detail.variants ?? [];
    if (variants.isEmpty) {
      return (solFrom: 0, solTo: 0);
    }

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

      final bomCaratFrom = double.tryParse(parts[2]) ?? 0.0;
      final bomCaratTo = double.tryParse(parts[3]) ?? 0.0;
      final pcs = row.pcs.toDouble();

      amountFrom += rateFromPerCt * bomCaratFrom * pcs * qty;
      amountTo += rateToPerCt * bomCaratTo * pcs * qty;
    }

    return (solFrom: amountFrom, solTo: amountTo);
  }
}

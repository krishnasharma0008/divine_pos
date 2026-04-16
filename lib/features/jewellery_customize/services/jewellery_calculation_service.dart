import 'package:flutter/widgets.dart';

import '../data/jewellery_detail_model.dart';
import '../data/variant_model.dart';
import '../data/bom_model.dart';

class JewelleryCalculationService {
  // ─────────────────────────────────────────────────────────────────────────
  // PCS / WEIGHT HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns total pcs for [itemGroup] + [itemType] from the base variant.
  /// When [variants] is empty the BOM rows have no Variant_id, so all matching
  /// rows are summed directly (variantless path).
  static int getPcs(
    List<Variant> variants,
    List<Bom> bom,
    String itemGroup,
    String itemType,
  ) {
    if (variants.isEmpty) {
      return bom
          .where(
            (b) =>
                b.itemGroup.toUpperCase() == itemGroup.toUpperCase() &&
                b.itemType.toUpperCase() == itemType.toUpperCase(),
          )
          .fold<int>(0, (acc, b) => acc + b.pcs);
    }

    return variants.where((v) => v.isBaseVariant).fold<int>(0, (acc, variant) {
      final matching = bom.where(
        (b) =>
            b.variantId == variant.variantId &&
            b.itemGroup.toUpperCase() == itemGroup.toUpperCase() &&
            b.itemType.toUpperCase() == itemType.toUpperCase(),
      );
      return acc + matching.fold<int>(0, (s, b) => s + b.pcs);
    });
  }

  /// Returns total weight for [itemGroup] + [itemType] from the base variant.
  static double getWeight(
    List<Variant> variants,
    List<Bom> bom,
    String itemGroup,
    String itemType,
  ) {
    if (variants.isEmpty) {
      return bom
          .where(
            (b) =>
                b.itemGroup.toUpperCase() == itemGroup.toUpperCase() &&
                b.itemType.toUpperCase() == itemType.toUpperCase(),
          )
          .fold<double>(0, (acc, b) => acc + b.weight);
    }

    return variants.where((v) => v.isBaseVariant).fold<double>(0, (
      acc,
      variant,
    ) {
      final matching = bom.where(
        (b) =>
            b.variantId == variant.variantId &&
            b.itemGroup.toUpperCase() == itemGroup.toUpperCase() &&
            b.itemType.toUpperCase() == itemType.toUpperCase(),
      );
      return acc + matching.fold<double>(0, (s, b) => s + b.weight);
    });
  }

  /// Gold + Platinum combined weight.
  static double getNetMetalWeight(List<Variant> variants, List<Bom> bom) {
    return getWeight(variants, bom, 'GOLD', 'METAL') +
        getWeight(variants, bom, 'PLATINUM', 'METAL');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BASE SIZE / CARAT
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts the base ring size and solitaire slab from [detail].
  ///
  /// - No variants: size from productSizeFrom, carat from first SOLITAIRE BOM.
  /// - With variants: size + slab from the base variant.
  static ({double? baseSize, String? baseCarat}) getBaseSizeCarat(
    JewelleryDetail detail,
  ) {
    if (detail.productSizeFrom == '-') {
      return (baseSize: null, baseCarat: null);
    }

    if (detail.variants.isEmpty) {
      final baseSize = double.tryParse(detail.productSizeFrom);
      final bomCarat = detail.bom
          .where(
            (b) =>
                b.itemGroup.toUpperCase() == 'SOLITAIRE' &&
                b.itemType.toUpperCase() == 'STONE',
          )
          .map((b) {
            final parts = b.bomVariantName.split('-');
            return parts.length >= 4 ? '${parts[2]}-${parts[3]}' : null;
          })
          .whereType<String>()
          .firstOrNull;
      return (baseSize: baseSize, baseCarat: bomCarat);
    }

    final baseVariants = detail.variants.where((v) => v.isBaseVariant).toList();

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

  // ─────────────────────────────────────────────────────────────────────────
  // DEFAULT SOLITAIRE SHAPE
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the shape code (e.g. 'RND') from the base variant's SOLITAIRE BOM.
  static String getDefaultSolitaireShapeCode({
    required List<Variant> variants,
    required List<Bom> bom,
  }) {
    final Iterable<Bom> solitaireBom;

    if (variants.isEmpty) {
      solitaireBom = bom.where(
        (b) => b.itemGroup == 'SOLITAIRE' && b.itemType == 'STONE',
      );
    } else {
      solitaireBom = variants
          .where((v) => v.isBaseVariant)
          .expand(
            (variant) => bom.where(
              (b) =>
                  b.variantId == variant.variantId &&
                  b.itemGroup == 'SOLITAIRE' &&
                  b.itemType == 'STONE',
            ),
          );
    }

    final shapeCodes = solitaireBom
        .map((b) => b.bomVariantName)
        .map((name) {
          final parts = name.split('-');
          return parts.length > 1 ? parts[1] : null;
        })
        .whereType<String>()
        .toSet()
        .toList();

    return shapeCodes.isNotEmpty ? shapeCodes.first : 'RND';
  }

  /// Maps a shape code to its UI display name.
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

  // ─────────────────────────────────────────────────────────────────────────
  // SOLITAIRE COLOR MAPPING
  // ─────────────────────────────────────────────────────────────────────────

  static String getSolitaireColor(String color) {
    if (color == 'Yellow Vivid') return 'VDY';
    if (color == 'Yellow Intense') return 'INY';
    return color;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // METAL HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  static String getValidPurity(String metal, String purity) {
    if (metal.toLowerCase() == 'gold' && purity == '950PT') return '18KT';
    return purity;
  }

  static String getMetalColor(String metal, String color) {
    final m = metal.trim().toLowerCase();
    final c = color.trim().toLowerCase();

    if (m == 'platinum') return 'White';

    if (m == 'gold') {
      if (c.contains('yellow')) return 'Yellow';
      if (c.contains('rose')) return 'Rose';
      if (c.contains('white')) return 'White';
    }

    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MULTI-SOLITAIRE MESSAGE
  // ─────────────────────────────────────────────────────────────────────────

  static int getSolitaireRowCount(List<Variant> variants, List<Bom> bom) {
    if (variants.isEmpty) {
      return bom
          .where((b) => b.itemGroup == 'SOLITAIRE' && b.itemType == 'STONE')
          .length;
    }
    return variants.where((v) => v.isBaseVariant).fold<int>(0, (acc, variant) {
      final matching = bom.where(
        (b) =>
            b.variantId == variant.variantId &&
            b.itemGroup == 'SOLITAIRE' &&
            b.itemType == 'STONE',
      );
      return acc + matching.length;
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

  // ─────────────────────────────────────────────────────────────────────────
  // DIVINE MOUNT ADJUSTMENT
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a multiplicative weight factor based on ring size difference.
  /// 3 % per size step from the base size.
  static double calculateDivineMountAdjustment({
    required String carat,
    required double size,
    required double baseRingSize,
    required int qty,
  }) {
    const adjustPercentPerSize = 3 / 100;
    final sizeDifference = size - baseRingSize;
    return 1 + (sizeDifference * adjustPercentPerSize);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SIDE DIAMOND
  // ─────────────────────────────────────────────────────────────────────────

  static Future<double> calculateSideDiamondPrice({
    required double price,
    required double totalSideCts,
    required int qty,
  }) async {
    return totalSideCts * price * qty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLITAIRE AMOUNT RANGE (multi-BOM row)
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates solitaire from/to amounts for products that have multiple
  /// SOLITAIRE STONE BOM rows (multi-size solitaire or multi-stone products).
  ///
  /// The [detail] passed in should already have the correct [variants] + [bom]
  /// for the active pricing scenario (store item detail or catalogue calcDetail).
  static Future<
    ({
      double solFrom,
      double solTo,
      String shapeLabel,
      String caratLabel,
      String pcsLabel,
      String colourLabel,
      String clarityLabel,
    })
  >
  calculateSolitaireAmountRangeLocal({
    required JewelleryDetail detail,
    required int qty,
    required bool isCustomised,
    required Future<double> Function({
      required String itemGroup,
      String? slab,
      String? shape,
      String? color,
      String? quality,
    })
    fetchPrice,
    required double? userMinCt,
    required double userMaxCt,
    required String? userColorFrom,
    required String? userColorTo,
    required String? userClarityFrom,
    required String? userClarityTo,
  }) async {
    double amountFrom = 0;
    double amountTo = 0;
    final List<String> shapes = [];
    final List<String> carats = [];
    final List<String> pcss = [];
    final List<String> mcolour = [];
    final List<String> mclarity = [];

    final variants = detail.variants;

    // Resolve the list of SOLITAIRE STONE BOM rows.
    final List<Bom> bomList;
    if (variants.isEmpty) {
      // Variantless path: all SOLITAIRE STONE rows are relevant.
      bomList = detail.bom
          .where(
            (b) =>
                b.itemGroup.trim().toUpperCase() == 'SOLITAIRE' &&
                b.itemType.trim().toUpperCase() == 'STONE',
          )
          .toList();
    } else {
      final activeVariant = variants.firstWhere(
        (v) => v.isBaseVariant,
        orElse: () => variants.first,
      );
      bomList = detail.bom
          .where(
            (b) =>
                b.variantId == activeVariant.variantId &&
                b.itemGroup.trim().toUpperCase() == 'SOLITAIRE' &&
                b.itemType.trim().toUpperCase() == 'STONE',
          )
          .toList();
    }

    if (bomList.isEmpty) {
      return (
        solFrom: 0.0,
        solTo: 0.0,
        shapeLabel: '',
        caratLabel: '',
        pcsLabel: '',
        colourLabel: '',
        clarityLabel: '',
      );
    }

    for (final row in bomList) {
      final name = row.bomVariantName;
      final parts = name.trim().split('-').map((p) => p.trim()).toList();
      if (parts.length < 4) continue;

      final shapeCode = parts[1];
      final carat = '${parts[2]}-${parts[3]}';
      final bomCaratFrom = double.tryParse(parts[2]) ?? 0.0;
      final bomCaratTo = double.tryParse(parts[3]) ?? 0.0;
      final pcs = row.pcs.toDouble();

      shapes.add(mapShapeCodeToName(shapeCode));
      carats.add(carat);
      pcss.add(row.pcs.toString());

      // Default color / clarity bounds per shape + carat range.
      String bomColorMin = '';
      String bomColorMax = '';
      String bomClarityMin = '';
      String bomClarityMax = '';

      final isFancy =
          shapeCode == 'PER' || shapeCode == 'PRN' || shapeCode == 'OVL';
      final isSolus =
          shapeCode == 'RADQ' || shapeCode == 'CUSQ' || shapeCode == 'HRT';

      String fromColor = '';
      String toColor = '';
      String fromClarity = '';
      String toClarity = '';

      if (isCustomised == false) {
        debugPrint('Entering non-customised logic branch');
        if (isFancy && bomCaratFrom >= 0.10 && bomCaratTo <= 0.17) {
          bomColorMin = 'GH';
          bomColorMax = 'EF';
          bomClarityMin = 'VS';
          bomClarityMax = 'VVS';
        } else if (isFancy && bomCaratFrom >= 0.18 && bomCaratTo <= 0.22) {
          bomColorMin = 'H';
          bomColorMax = 'D';
          bomClarityMin = 'VS2';
          bomClarityMax = 'IF';
        } else if (shapeCode == 'RND' &&
            bomCaratFrom >= 0.10 &&
            bomCaratTo <= 0.17) {
          bomColorMin = 'IJ';
          bomColorMax = 'EF';
          bomClarityMin = 'SI';
          bomClarityMax = 'VVS';
        } else if (shapeCode == 'RND' &&
            bomCaratFrom >= 0.18 &&
            bomCaratTo <= 0.22) {
          bomColorMin = 'E';
          bomColorMax = 'D';
          bomClarityMin = 'VVS1';
          bomClarityMax = 'IF';
        } else if (isSolus && bomCaratFrom >= 0.18 && bomCaratTo <= 1.5) {
          bomColorMin = 'VDY';
          bomColorMax = 'VDY';
          bomClarityMin = 'VS';
          bomClarityMax = 'VVS';
        }

        fromColor = getSolitaireColor(bomColorMin);
        toColor = getSolitaireColor(bomColorMax);
        fromClarity = bomClarityMin;
        toClarity = bomClarityMax;
      } else {
        debugPrint('Entering customised logic branch');
        if (isFancy && bomCaratFrom >= 0.10 && bomCaratTo <= 0.17) {
          bomColorMin = 'GH';
          bomColorMax = 'EF';
          bomClarityMin = 'VS';
          bomClarityMax = 'VVS';
        } else if (isFancy && bomCaratFrom >= 0.18 && bomCaratTo <= 0.22) {
          bomColorMin = 'K';
          bomColorMax = 'D';
          bomClarityMin = 'SI1';
          bomClarityMax = 'IF';
        } else if (shapeCode == 'RND' &&
            bomCaratFrom >= 0.10 &&
            bomCaratTo <= 0.17) {
          bomColorMin = 'IJ';
          bomColorMax = 'EF';
          bomClarityMin = 'SI';
          bomClarityMax = 'VVS';
        }

        fromColor = getSolitaireColor(
          userMaxCt == bomCaratTo ? (userColorFrom ?? '') : bomColorMin,
        );
        toColor = getSolitaireColor(
          userMinCt == bomCaratFrom ? (userColorTo ?? '') : bomColorMax,
        );
        fromClarity = userMaxCt == bomCaratTo
            ? (userClarityFrom ?? '')
            : bomClarityMin;
        toClarity = userMinCt == bomCaratFrom
            ? (userClarityTo ?? '')
            : bomClarityMax;
      }

      // User selection overrides BOM defaults when carat matches.
      // final String fromColor = getSolitaireColor(
      //   userMaxCt == bomCaratTo ? (userColorFrom ?? '') : bomColorMin,
      // );
      // final String toColor = getSolitaireColor(
      //   userMinCt == bomCaratFrom ? (userColorTo ?? '') : bomColorMax,
      // );
      // final String fromClarity = userMaxCt == bomCaratTo
      //     ? (userClarityFrom ?? '')
      //     : bomClarityMin;
      // final String toClarity = userMinCt == bomCaratFrom
      //     ? (userClarityTo ?? '')
      //     : bomClarityMax;

      final priceFrom = await fetchPrice(
        itemGroup: 'SOLITAIRE',
        slab: bomCaratFrom.toStringAsFixed(2),
        shape: shapeCode,
        color: fromColor,
        quality: fromClarity,
      );

      final priceTo = await fetchPrice(
        itemGroup: 'SOLITAIRE',
        slab: bomCaratTo.toStringAsFixed(2),
        shape: shapeCode,
        color: toColor,
        quality: toClarity,
      );

      debugPrint(
        'BOM row: shape=$shapeCode, carat=$bomCaratFrom-$bomCaratTo, '
        'colorFrom=$fromColor, colorTo=$toColor, '
        'clarityFrom=$fromClarity, clarityTo=$toClarity, '
        'priceFrom=$priceFrom, priceTo=$priceTo',
      );

      mcolour.add('$fromColor-$toColor');
      mclarity.add('$toClarity-$fromClarity');

      amountFrom += priceFrom * bomCaratFrom * qty * pcs;
      amountTo += priceTo * bomCaratTo * qty * pcs;
    }

    return (
      solFrom: amountFrom,
      solTo: amountTo,
      shapeLabel: shapes.join(', '),
      caratLabel: carats.join(', '),
      pcsLabel: pcss.join(', '),
      colourLabel: mcolour.join(', '),
      clarityLabel: mclarity.join(', '),
    );
  }
}

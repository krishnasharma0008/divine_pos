import '../../jewellery_customize/data/bom_model.dart';
import '../../jewellery_customize/data/jewellery_detail_model.dart';
import 'package:flutter/widgets.dart';

class JewelleryCalculationService {
  /// -----------------------------
  /// PCS / WEIGHT HELPERS
  /// -----------------------------

  static int getPcs(List<Bom> bom, String itemGroup, String itemType) {
    return bom
        .where(
          (b) =>
              (b.itemGroup ?? '').toUpperCase() == itemGroup.toUpperCase() &&
              (b.itemType ?? '').toUpperCase() == itemType.toUpperCase(),
        )
        .fold(0, (sum, b) => sum + b.pcs);
  }

  /// -----------------------------
  /// DEFAULT SOLITAIRE SHAPE
  /// -----------------------------
  ///
  // static String getSolitaireShapeCode({required List<Bom> bom}) {
  //   for (final b in bom) {
  //     if ((b.itemGroup ?? '').toUpperCase() == 'SOLITAIRE' &&
  //         (b.itemType ?? '').toUpperCase() == 'STONE') {
  //       final name = b.bomVariantName;
  //       if (name == null || name.isEmpty) continue;

  //       final parts = name.split('-');
  //       if (parts.length > 1 && parts[1].isNotEmpty) {
  //         return parts[1]; // RND, PRN, etc.
  //       }
  //     }
  //   }

  //   return 'RND';
  // }

  static Map<String, dynamic> getSolitaireDetails({required List<Bom> bom}) {
    for (final b in bom) {
      if ((b.itemGroup ?? '').toUpperCase() == 'SOLITAIRE' &&
          (b.itemType ?? '').toUpperCase() == 'STONE') {
        final name = b.bomVariantName;
        if (name == null || name.isEmpty) continue;

        final parts = name.split('-');

        if (parts.length >= 2) {
          final shapeCode = parts[1];

          final bomCaratFrom = parts.length > 2
              ? double.tryParse(parts[2]) ?? 0.0
              : 0.0;

          final bomCaratTo = parts.length > 3
              ? double.tryParse(parts[3]) ?? 0.0
              : 0.0;

          final bomColor = parts.length > 4 ? parts[4] : '';

          final bomClarity = parts.length > 5 ? parts[5] : '';

          return {
            'shapeCode': shapeCode,
            'caratFrom': bomCaratFrom,
            'caratTo': bomCaratTo,
            'colorFrom': bomColor,
            'colorTo': bomColor,
            'clarityFrom': bomClarity,
            'clarityTo': bomClarity,
          };
        }
      }
    }

    return {
      'shapeCode': 'RND',
      'caratFrom': 0.0,
      'caratTo': 0.0,
      'colorFrom': '',
      'colorTo': '',
      'clarityFrom': '',
      'clarityTo': '',
    };
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
  /// METAL & SIDE DIAMOND
  /// -----------------------------
  ///
  /// Metal price = weight * purity factor * metal rate

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

  static double getWeight(List<Bom> bom, String itemGroup, String itemType) {
    final group = itemGroup.toUpperCase();
    final type = itemType.toUpperCase();

    return bom
        .where(
          (b) =>
              (b.itemGroup ?? '').toUpperCase() == group &&
              (b.itemType ?? '').toUpperCase() == type,
        )
        .fold(0.0, (sum, b) => sum + (b.weight ?? 0.0));
  }

  static double getNetMetalWeight(List<Bom> bom) {
    return getWeight(bom, 'GOLD', 'METAL') +
        getWeight(bom, 'PLATINUM', 'METAL');
  }

  /// Metal amount calculation (gold + platinum)
  Future<double> calculateMetalAmountFromApi({
    required JewelleryDetail detail,
    required String metalColor,
    required String metalPurity,
    required double goldWeight,
    required double platinumWeight,
    required int qty,
    required Future<double> Function({
      required String itemGroup,
      String? slab,
      String? shape,
      String? color,
      String? quality,
    })
    fetchPrice,
  }) async {
    if (metalColor.isEmpty || metalPurity.isEmpty) return 0.0;

    final goldColor = metalColor.contains('+')
        ? JewelleryCalculationService.getMetalColor('GOLD', metalColor)
        : metalColor;

    final selectedQty = qty > 0 ? qty : 1;

    double goldPrice = 0;
    double platinumPrice = 0;

    // GOLD pricing
    if (goldWeight > 1) {
      //goldPrice = await _fetchPrice(
      goldPrice = await fetchPrice(
        itemGroup: 'GOLD',
        slab: '',
        shape: '',
        color: goldColor,
        quality: JewelleryCalculationService.getValidPurity(
          'gold',
          metalPurity,
        ),
      );
    } else if (goldWeight > 0 && goldWeight <= 1) {
      goldPrice = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    debugPrint(
      'Gold weight: $goldWeight, price: $goldPrice, color: $goldColor, purity: ${JewelleryCalculationService.getValidPurity('gold', metalPurity)}',
    );
    // PLATINUM pricing
    if (platinumWeight > 0) {
      final platinumColor = JewelleryCalculationService.getMetalColor(
        'PLATINUM',
        metalColor,
      );

      //platinumPrice = await _fetchPrice(
      platinumPrice = await fetchPrice(
        itemGroup: 'PLATINUM',
        slab: '',
        shape: '',
        color: platinumColor,
        quality: metalPurity,
      );
    }

    double goldAmount = goldWeight > 0
        ? goldWeight * goldPrice * selectedQty
        : 0;
    final platinumAmount = platinumWeight > 0
        ? platinumWeight * platinumPrice * selectedQty
        : 0;

    // <= 1 gm rule
    if (goldWeight > 0 && goldWeight <= 1) {
      goldAmount = (detail.metalPriceLessOneGms ?? 0).toDouble();
    }

    return goldAmount + platinumAmount;
  }

  static Future<double> calculateSideDiamondPrice({
    required double price,
    required double totalSideCts,
    required int qty,
  }) async {
    return totalSideCts * price * qty;
  }
}

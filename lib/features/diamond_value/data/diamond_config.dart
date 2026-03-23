import 'package:divine_pos/features/jewellery_customize/data/solitaire_constants.dart';

export 'package:divine_pos/features/jewellery_customize/data/solitaire_constants.dart'
    show
        caratSteps,
        solitaireShapes,
        solusShapes,
        allShapes,
        colors,
        solusColors,
        otherRoundColors,
        otherRoundColorsCarat,
        clarities,
        claritiesRound,
        claritiesRoundCarat;

enum DiamondShape { round, princess, oval, pear, marquise }

/// regular = solitaire shapes (Round/Princess/Oval/Pear/Marquise)
/// vdf     = Yellow Vivid  (solus shapes)
/// iny     = Yellow Intense (solus shapes)
enum ShapeType { regular, vdf, iny }

class DiamondConfig {
  final DiamondShape shape;
  final String yellowShape; // one of solusShapes
  final ShapeType shapeType;
  final int caratIndex;
  final int colorIndex;
  final int clarityIndex;

  DiamondConfig({
    required this.shape,
    this.yellowShape = 'Radiant',
    required this.shapeType,
    required this.caratIndex,
    required this.colorIndex,
    required this.clarityIndex,
  });

  // ---------------------------------------------------------------------------
  // getColorOptions — uses your project constants directly
  // ---------------------------------------------------------------------------
  static List<String> getColorOptions({
    required double caratTo,
    required bool isRound,
    required ShapeType shapeType,
  }) {
    // Yellow Vivid / Yellow Intense → D–K + Yellow Vivid/Intense
    if (shapeType == ShapeType.vdf || shapeType == ShapeType.iny) {
      return [...colors, ...solusColors];
    }
    // Regular + Round + cts < 0.18 → EF, GH, IJ + yellows
    if (isRound && caratTo < 0.18) {
      return [...otherRoundColors, ...solusColors];
    }
    // Regular + Round + cts >= 0.18 → D–K + yellows
    if (isRound) {
      return [...colors, ...solusColors];
    }
    // Regular + non-Round + 0.10–0.17 → EF, GH + yellows
    if (caratTo >= 0.10 && caratTo <= 0.17) {
      return [...otherRoundColorsCarat, ...solusColors];
    }
    // Regular + non-Round + cts >= 0.18 → D–H + yellows
    return [
      ...colors.where((c) => c != 'I' && c != 'J' && c != 'K'),
      ...solusColors,
    ];
  }

  // ---------------------------------------------------------------------------
  // getClarityOptions — uses your project constants directly
  // ---------------------------------------------------------------------------
  static List<String> getClarityOptions({
    required double caratTo,
    required bool isRound,
    required ShapeType shapeType,
  }) {
    // Yellow Vivid / Yellow Intense → VVS, VS
    if (shapeType == ShapeType.vdf || shapeType == ShapeType.iny) {
      return claritiesRoundCarat;
    }
    // Regular + Round + cts < 0.18 → VVS, VS, SI
    if (isRound && caratTo < 0.18) {
      return claritiesRound;
    }
    // Regular + Round + cts >= 0.18 → IF–SI2
    if (isRound) {
      return clarities;
    }
    // Regular + non-Round + 0.10–0.17 → VVS, VS
    if (caratTo >= 0.10 && caratTo <= 0.17) {
      return claritiesRoundCarat;
    }
    // Regular + non-Round + cts >= 0.18 → IF–VS2
    return clarities.sublist(0, 5);
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------
  double get caratDouble => double.parse(caratSteps[caratIndex]);
  bool get isRound =>
      shapeType == ShapeType.regular && shape == DiamondShape.round;
  bool get isYellowColor =>
      shapeType == ShapeType.vdf || shapeType == ShapeType.iny;

  // Cached so the same list instance is returned when nothing changed,
  // preventing listEquals from seeing a "new" list on every build.
  late final List<String> colorOptions = getColorOptions(
    caratTo: caratDouble,
    isRound: isRound,
    shapeType: shapeType,
  );
  late final List<String> clarityOptions = getClarityOptions(
    caratTo: caratDouble,
    isRound: isRound,
    shapeType: shapeType,
  );

  String get caratLabel => caratSteps[caratIndex];
  String get colorLabel =>
      colorOptions[colorIndex.clamp(0, colorOptions.length - 1)];
  String get clarityLabel =>
      clarityOptions[clarityIndex.clamp(0, clarityOptions.length - 1)];

  // ---------------------------------------------------------------------------
  // Safe index helpers — preserve current value when options list changes
  // ---------------------------------------------------------------------------
  int safeColorIndex(List<String> newOptions) {
    final current = colorOptions[colorIndex.clamp(0, colorOptions.length - 1)];
    final idx = newOptions.indexOf(current);
    return idx >= 0 ? idx : 0;
  }

  int safeClarityIndex(List<String> newOptions) {
    final current =
        clarityOptions[clarityIndex.clamp(0, clarityOptions.length - 1)];
    final idx = newOptions.indexOf(current);
    return idx >= 0 ? idx : 0;
  }

  // ---------------------------------------------------------------------------
  // Shape → asset / API code
  // Enums match solitaireShapes + solusShapes exactly
  // ---------------------------------------------------------------------------
  String get shapeAsset {
    if (isYellowColor) {
      switch (yellowShape) {
        case 'Radiant':
          return 'assets/diamond_value/radiant.png';
        case 'Cushion':
          return 'assets/diamond_value/cushion.png';
        case 'Heart':
          return 'assets/diamond_value/heart.png';
        default:
          return 'assets/diamond_value/radiant.png';
      }
    }
    switch (shape) {
      case DiamondShape.round:
        return 'assets/diamond_value/round.png';
      case DiamondShape.princess:
        return 'assets/diamond_value/princess.png';
      case DiamondShape.oval:
        return 'assets/diamond_value/oval.png';
      case DiamondShape.pear:
        return 'assets/diamond_value/pear.png';
      case DiamondShape.marquise:
        return 'assets/diamond_value/marquise.png';
    }
  }

  String? get ringAsset {
    if (shapeType != ShapeType.regular) return null;

    switch (shape) {
      case DiamondShape.round:
        return 'assets/diamond_value/goldring.png';

      case DiamondShape.princess:
      case DiamondShape.oval:
      case DiamondShape.pear:
      case DiamondShape.marquise:
        return 'assets/diamond_value/grayring.png';
    }
  }

  String get shapeCode {
    if (isYellowColor) {
      switch (yellowShape) {
        case 'Radiant':
          return 'RADQ';
        case 'Cushion':
          return 'CUSH';
        case 'Heart':
          return 'HRT';
        default:
          return 'RADQ';
      }
    }
    switch (shape) {
      case DiamondShape.round:
        return 'RND';
      case DiamondShape.princess:
        return 'PRC';
      case DiamondShape.oval:
        return 'OVL';
      case DiamondShape.pear:
        return 'PER';
      case DiamondShape.marquise:
        return 'MRQ';
    }
  }

  String get shapeName {
    if (isYellowColor) {
      return yellowShape; // already a display string
    }
    switch (shape) {
      case DiamondShape.round:
        return 'Round';
      case DiamondShape.princess:
        return 'Princess';
      case DiamondShape.oval:
        return 'Oval';
      case DiamondShape.pear:
        return 'Pear';
      case DiamondShape.marquise:
        return 'Marquise';
    }
  }

  String? getDisplayColor(String? color) {
    return switch (color) {
      'VDY' => 'Yellow Vivid',
      'INY' => 'Yellow Intense',
      null => null,
      _ => color,
    };
  }

  String get diamondCode => '$shapeCode-$caratLabel-$colorLabel-$clarityLabel';

  // ---------------------------------------------------------------------------
  // Price placeholder — replace with real API call
  // ---------------------------------------------------------------------------
  int get price {
    int base = 80000;
    base += caratIndex * 8000;
    base += (9 - colorIndex.clamp(0, 9)) * 2000;
    base += (6 - clarityIndex.clamp(0, 6)) * 1500;
    return base;
  }

  String get priceFormatted {
    final p = price;
    final lakh = p ~/ 100000;
    final remainder = p % 100000;
    final thousand = remainder ~/ 1000;
    final hundreds = remainder % 1000;
    if (lakh > 0) {
      return '₹$lakh,${thousand.toString().padLeft(2, '0')},${hundreds.toString().padLeft(3, '0')}';
    }
    return '₹${_formatINR(p)}';
  }

  static String _formatINR(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    for (var i = rest.length; i > 0; i -= 2) {
      parts.insert(0, rest.substring(i < 2 ? 0 : i - 2, i));
    }
    return '${parts.join(',')},${last3}';
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------
  DiamondConfig copyWith({
    DiamondShape? shape,
    String? yellowShape,
    ShapeType? shapeType,
    int? caratIndex,
    int? colorIndex,
    int? clarityIndex,
  }) {
    return DiamondConfig(
      shape: shape ?? this.shape,
      yellowShape: yellowShape ?? this.yellowShape,
      shapeType: shapeType ?? this.shapeType,
      caratIndex: caratIndex ?? this.caratIndex,
      colorIndex: colorIndex ?? this.colorIndex,
      clarityIndex: clarityIndex ?? this.clarityIndex,
    );
  }
}

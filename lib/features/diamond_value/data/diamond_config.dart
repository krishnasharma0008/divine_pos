enum DiamondShape { round, princess, pear, oval }

class DiamondConfig {
  final DiamondShape shape;
  final int caratIndex;
  final int colorIndex;
  final int clarityIndex;

  DiamondConfig({
    required this.shape,
    required this.caratIndex,
    required this.colorIndex,
    required this.clarityIndex,
  });

  static const caratValues = [
    '0.10',
    '0.14',
    '0.18',
    '0.23',
    '0.30',
    '0.39',
    '0.45',
    '0.50',
    '0.70',
    '0.80',
  ];
  static const colorValues = [
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'Yellow Vivid',
    'Yellow Intense',
  ];
  static const clarityValues = [
    'IF',
    'VVS1',
    'VVS2',
    'VS1',
    'VS2',
    'SI1',
    'SI2',
  ];

  String get caratLabel => caratValues[caratIndex];
  String get colorLabel => colorValues[colorIndex];
  String get clarityLabel => clarityValues[clarityIndex];

  String get shapeCode {
    switch (shape) {
      case DiamondShape.round:
        return 'RND';
      case DiamondShape.princess:
        return 'PRC';
      case DiamondShape.pear:
        return 'PER';
      case DiamondShape.oval:
        return 'OVL';
    }
  }

  String get shapeName {
    switch (shape) {
      case DiamondShape.round:
        return 'Round';
      case DiamondShape.princess:
        return 'Princess';
      case DiamondShape.pear:
        return 'Pear';
      case DiamondShape.oval:
        return 'Oval';
    }
  }

  String get diamondCode {
    final carat = (double.parse(caratLabel) * 10).toStringAsFixed(0);
    return '$shapeCode-$carat.00-$colorLabel-$clarityLabel';
  }

  bool get isRound => shape == DiamondShape.round;

  int get price {
    // Simulated price based on selections
    int base = 80000;
    base += caratIndex * 8000;
    base += (9 - colorIndex) * 2000;
    base += (6 - clarityIndex) * 1500;
    return base;
  }

  String get priceFormatted {
    final p = price;
    if (p >= 100000) {
      final lakh = (p / 100000).toStringAsFixed(2);
      return '₹${lakh.replaceAll('.', ',')}';
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

  DiamondConfig copyWith({
    DiamondShape? shape,
    int? caratIndex,
    int? colorIndex,
    int? clarityIndex,
  }) {
    return DiamondConfig(
      shape: shape ?? this.shape,
      caratIndex: caratIndex ?? this.caratIndex,
      colorIndex: colorIndex ?? this.colorIndex,
      clarityIndex: clarityIndex ?? this.clarityIndex,
    );
  }
}

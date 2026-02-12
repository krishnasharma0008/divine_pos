class JewelleryFilter {
  final PriceRangeFilter? price;
  final CaratRangeFilter? carat;
  final ColorRangeFilter? color;
  final ClarityRangeFilter? clarity;
  final String? ringSize;
  final String? metalColor;
  final String? metalPurity;
  final String? sideDiamondQuality;

  const JewelleryFilter({
    this.price,
    this.carat,
    this.color,
    this.clarity,
    this.ringSize,
    this.metalColor,
    this.metalPurity,
    this.sideDiamondQuality,
  });

  JewelleryFilter copyWith({
    PriceRangeFilter? price,
    CaratRangeFilter? carat,
    ColorRangeFilter? color,
    ClarityRangeFilter? clarity,
    String? ringSize,
    String? metalColor,
    String? metalPurity,
    String? sideDiamondQuality,
  }) {
    return JewelleryFilter(
      price: price ?? this.price,
      carat: carat ?? this.carat,
      color: color ?? this.color,
      clarity: clarity ?? this.clarity,
      ringSize: ringSize ?? this.ringSize,
      metalColor: metalColor ?? this.metalColor,
      metalPurity: metalPurity ?? this.metalPurity,
      sideDiamondQuality: sideDiamondQuality ?? this.sideDiamondQuality,
    );
  }

  Map<String, dynamic> toJson() => {
    'price': price?.toJson(),
    'carat': carat?.toJson(),
    'color': color?.toJson(),
    'clarity': clarity?.toJson(),
    'ringSize': ringSize,
    'metalColor': metalColor,
    'metalPurity': metalPurity,
    'sideDiamondQuality': sideDiamondQuality,
  };

  factory JewelleryFilter.fromJson(Map<String, dynamic> json) =>
      JewelleryFilter(
        price: json['price'] != null
            ? PriceRangeFilter.fromJson(json['price'])
            : null,
        carat: json['carat'] != null
            ? CaratRangeFilter.fromJson(json['carat'])
            : null,
        color: json['color'] != null
            ? ColorRangeFilter.fromJson(json['color'])
            : null,
        clarity: json['clarity'] != null
            ? ClarityRangeFilter.fromJson(json['clarity'])
            : null,
        ringSize: json['ringSize'],
        metalColor: json['metalColor'],
        metalPurity: json['metalPurity'],
        sideDiamondQuality: json['sideDiamondQuality'],
      );
}

class PriceRangeFilter {
  final String startValue;
  final String endValue;
  final int startIndex;
  final int endIndex;

  const PriceRangeFilter({
    required this.startValue,
    required this.endValue,
    required this.startIndex,
    required this.endIndex,
  });

  Map<String, dynamic> toJson() => {
    'startValue': startValue,
    'endValue': endValue,
    'startIndex': startIndex,
    'endIndex': endIndex,
  };

  factory PriceRangeFilter.fromJson(Map<String, dynamic> json) =>
      PriceRangeFilter(
        startValue: json['startValue'] ?? '',
        endValue: json['endValue'] ?? '',
        startIndex: json['startIndex'] ?? 0,
        endIndex: json['endIndex'] ?? 0,
      );
}

class CaratRangeFilter {
  final String startValue;
  final String endValue;
  final int startIndex;
  final int endIndex;

  const CaratRangeFilter({
    required this.startValue,
    required this.endValue,
    required this.startIndex,
    required this.endIndex,
  });

  Map<String, dynamic> toJson() => {
    'startValue': startValue,
    'endValue': endValue,
    'startIndex': startIndex,
    'endIndex': endIndex,
  };

  factory CaratRangeFilter.fromJson(Map<String, dynamic> json) =>
      CaratRangeFilter(
        startValue: json['startValue'] ?? '',
        endValue: json['endValue'] ?? '',
        startIndex: json['startIndex'] ?? 0,
        endIndex: json['endIndex'] ?? 0,
      );
}

class ColorRangeFilter {
  final String start; // UI shows "end-start" but stores start/end
  final String end;
  final int startIndex;
  final int endIndex;

  const ColorRangeFilter({
    required this.start,
    required this.end,
    required this.startIndex,
    required this.endIndex,
  });

  String get displayRange => '$end-$start'; // JS logic: colorEnd-colorStart

  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    'startIndex': startIndex,
    'endIndex': endIndex,
  };

  factory ColorRangeFilter.fromJson(Map<String, dynamic> json) =>
      ColorRangeFilter(
        start: json['start'] ?? '',
        end: json['end'] ?? '',
        startIndex: json['startIndex'] ?? 0,
        endIndex: json['endIndex'] ?? 0,
      );
}

class ClarityRangeFilter {
  final String start;
  final String end;
  final int startIndex;
  final int endIndex;

  const ClarityRangeFilter({
    required this.start,
    required this.end,
    required this.startIndex,
    required this.endIndex,
  });

  String get displayRange => '$end-$start';

  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    'startIndex': startIndex,
    'endIndex': endIndex,
  };

  factory ClarityRangeFilter.fromJson(Map<String, dynamic> json) =>
      ClarityRangeFilter(
        start: json['start'] ?? '',
        end: json['end'] ?? '',
        startIndex: json['startIndex'] ?? 0,
        endIndex: json['endIndex'] ?? 0,
      );
}

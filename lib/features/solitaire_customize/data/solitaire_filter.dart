class SolitaireFilter {
  final String? shape;
  final PriceRangeFilter? price;
  final CaratRangeFilter? carat;
  final ColorRangeFilter? color;
  final ClarityRangeFilter? clarity;

  const SolitaireFilter({
    this.shape,
    this.price,
    this.carat,
    this.color,
    this.clarity,
  });

  SolitaireFilter copyWith({
    String? shape,
    PriceRangeFilter? price,
    CaratRangeFilter? carat,
    ColorRangeFilter? color,
    ClarityRangeFilter? clarity,
  }) {
    return SolitaireFilter(
      shape: shape ?? this.shape,
      price: price ?? this.price,
      carat: carat ?? this.carat,
      color: color ?? this.color,
      clarity: clarity ?? this.clarity,
    );
  }

  Map<String, dynamic> toJson() => {
    'shape': shape,
    'price': price?.toJson(),
    'carat': carat?.toJson(),
    'color': color?.toJson(),
    'clarity': clarity?.toJson(),
  };

  factory SolitaireFilter.fromJson(Map<String, dynamic> json) =>
      SolitaireFilter(
        shape: json['shape'],
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

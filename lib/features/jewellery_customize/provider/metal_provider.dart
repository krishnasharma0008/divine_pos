import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Metal Purity
/// ------------------------------------------------------------
final metalPurityProvider = NotifierProvider<MetalPurityNotifier, String>(
  MetalPurityNotifier.new,
);

class MetalPurityNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setPurity(String value) {
    state = value;
  }
}

/// ------------------------------------------------------------
/// Metal Color
/// ------------------------------------------------------------
final metalColorProvider = NotifierProvider<MetalColorNotifier, String>(
  MetalColorNotifier.new,
);

class MetalColorNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setColor(String value) {
    state = value;
  }
}

/// ------------------------------------------------------------
/// Gold Price
/// ------------------------------------------------------------
final goldPriceProvider = NotifierProvider<GoldPriceNotifier, double>(
  GoldPriceNotifier.new,
);

class GoldPriceNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void setPrice(double price) {
    state = price;
  }
}

/// ------------------------------------------------------------
/// Platinum Price
/// ------------------------------------------------------------
final platinumPriceProvider = NotifierProvider<PlatinumPriceNotifier, double>(
  PlatinumPriceNotifier.new,
);

class PlatinumPriceNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void setPrice(double price) {
    state = price;
  }
}

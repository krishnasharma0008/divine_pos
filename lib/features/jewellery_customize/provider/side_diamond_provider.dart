import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// Side Diamond Price
/// ------------------------------------------------------------
final sideDiamondPriceProvider =
    NotifierProvider<SideDiamondPriceNotifier, double>(
      SideDiamondPriceNotifier.new,
    );

class SideDiamondPriceNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void setPrice(double price) {
    state = price;
  }
}

/// ------------------------------------------------------------
/// Side Diamond Clarity
/// ------------------------------------------------------------
final sideDiamondClarityProvider =
    NotifierProvider<SideDiamondClarityNotifier, String>(
      SideDiamondClarityNotifier.new,
    );

class SideDiamondClarityNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setClarity(String clarity) {
    state = clarity;
  }
}

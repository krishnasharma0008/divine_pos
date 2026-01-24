import 'package:flutter_riverpod/flutter_riverpod.dart';

final ringSizeDiffProvider =
    NotifierProvider<RingSizeNotifier, double>(
  RingSizeNotifier.new,
);

class RingSizeNotifier extends Notifier<double> {
  @override
  double build() => 0.0;

  void setDiff(double diff) {
    state = diff;
  }
}

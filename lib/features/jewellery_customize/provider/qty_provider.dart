import 'package:flutter_riverpod/flutter_riverpod.dart';

final qtyProvider = NotifierProvider<QtyNotifier, int>(QtyNotifier.new);

class QtyNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setQty(int value) {
    state = value;
  }
}

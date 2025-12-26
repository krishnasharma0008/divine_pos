import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔹 Notifier to signal TopButtonsRow to reset UI
class TopButtonsResetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Call this to trigger a reset
  void trigger() => state++;
}

final topButtonsResetProvider = NotifierProvider<TopButtonsResetNotifier, int>(
  TopButtonsResetNotifier.new,
);

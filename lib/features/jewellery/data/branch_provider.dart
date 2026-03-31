import 'package:flutter_riverpod/flutter_riverpod.dart';

final branchProvider = NotifierProvider<BranchNotifier, String?>(
  BranchNotifier.new,
);

class BranchNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null; // initial branch
  }

  void setBranch(String? branch) {
    state = branch;
  }

  void resetBranch() {
    state = null;
  }
}

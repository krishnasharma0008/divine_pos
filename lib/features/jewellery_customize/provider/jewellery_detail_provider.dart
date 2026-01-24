import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/jewellery_detail_model.dart';

import 'jewellery_notifier.dart';

final jewelleryDetailProvider =
    AsyncNotifierProvider.autoDispose<
      JewelleryDetailNotifier,
      JewelleryDetail?
    >(JewelleryDetailNotifier.new);

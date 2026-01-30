import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';


final caratRangeProvider = StateProvider<RangeValues>(
  (ref) => const RangeValues(0.14, 0.18),
);
 
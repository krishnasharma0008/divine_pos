import 'package:flutter/material.dart';
import '../../features/jewellery/data/jewellery_model.dart';

/// 🔹 Returns tag text based on jewellery attributes
String getTagText(Jewellery item) {
  if (item.isNew) {
    return "New Arrival ✨";
  }

  // if (item.productCategory.toLowerCase().contains('ring')) {
  //   return "Best Seller 🔥";
  // }

  return "";
}

/// 🔹 Returns color for tag text (used for text + bg opacity)
Color getTagColor(String tagText) {
  if (tagText.contains("New")) {
    return Colors.teal;
  }

  // if (tagText.contains("Best")) {
  //   return Colors.orange;
  // }

  return Colors.transparent;
}

// helper to format price/weight nicely
String formatWeight(double? w) {
  if (w == null) return '';
  return w.toStringAsFixed(2); // or just w.toString()
}

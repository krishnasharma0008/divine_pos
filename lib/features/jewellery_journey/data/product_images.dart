import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class ProductImage {
  final String id;
  final String url;
  final String tagText;
  final Color tagColor;

  ProductImage({
    required this.id,
    required this.url,
    this.tagText = "",
    this.tagColor = Colors.transparent,
  });
}

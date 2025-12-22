class Jewellery {
  final int itemId;
  final String itemNumber;
  final String? oldVariant;
  final String productCategory;
  final String? solitaireSlab;
  final double? weight;
  final String? bomVariantName;
  final String? imageUrl;
  final bool isNew;

  Jewellery({
    required this.itemId,
    required this.itemNumber,
    required this.oldVariant,
    required this.productCategory,
    required this.solitaireSlab,
    required this.weight,
    required this.bomVariantName,
    required this.imageUrl,
    required this.isNew,
  });

  factory Jewellery.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.isNotEmpty) return double.tryParse(v);
      return null;
    }

    String? _cleanUrl(dynamic v) {
      if (v == null) return null;
      var s = v.toString().trim();
      // Remove markdown-style [url]()
      if (s.startsWith('[') && s.contains('](')) {
        final start = s.indexOf('[') + 1;
        final end = s.indexOf(']');
        if (end > start) {
          s = s.substring(start, end);
        }
      }
      return s;
    }

    return Jewellery(
      itemId: json['Item_id'] is int
          ? json['Item_id'] as int
          : int.tryParse(json['Item_id'].toString()) ?? 0,
      itemNumber: json['item_number']?.toString() ?? '',
      oldVariant: json['old_varient']?.toString(),
      productCategory: json['product_category']?.toString() ?? '',
      solitaireSlab: json['solitaire_slab']?.toString(),
      weight: _toDouble(json['weight']),
      bomVariantName: json['bom_variant_name']?.toString(),
      imageUrl: _cleanUrl(json['image_url']),
      isNew:
          json['isnew'] == true ||
          json['isnew'] == 1 ||
          json['isnew']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'Item_id': itemId,
    'item_number': itemNumber,
    'old_varient': oldVariant,
    'product_category': productCategory,
    'solitaire_slab': solitaireSlab,
    'weight': weight,
    'bom_variant_name': bomVariantName,
    'image_url': imageUrl,
    'isnew': isNew,
  };
}

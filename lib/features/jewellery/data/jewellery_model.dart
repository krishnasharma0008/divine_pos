class Jewellery {
  final int itemId;
  final String itemNumber;
  final String? oldVariant;
  final String productCategory;
  final String? solitaireSlab;
  final double? weight;
  final bool isNew;

  final String? classify;
  final String? description;
  final double? price;
  final String? layingWith;
  final String? imageUrl;

  Jewellery({
    required this.itemId,
    required this.itemNumber,
    this.oldVariant,
    required this.productCategory,
    this.solitaireSlab,
    this.weight,
    required this.isNew,
    this.classify,
    this.description,
    this.price,
    this.layingWith,
    this.imageUrl,
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
      if (s.startsWith('[') && s.contains('](')) {
        final start = s.indexOf('[') + 1;
        final end = s.indexOf(']');
        if (end > start) {
          s = s.substring(start, end);
        }
      }
      return s.isEmpty ? null : s;
    }

    return Jewellery(
      itemId: json['Item_id'] is int
          ? json['Item_id']
          : int.tryParse(json['Item_id']?.toString() ?? '') ?? 0,

      itemNumber: json['item_number']?.toString() ?? '',
      oldVariant: json['old_varient']?.toString(),
      productCategory: json['product_category']?.toString() ?? '',
      solitaireSlab: json['solitaire_slab']?.toString(),
      weight: _toDouble(json['weight']),
      isNew:
          json['isnew'] == true ||
          json['isnew'] == 1 ||
          json['isnew']?.toString().toLowerCase() == 'true',

      classify: json['classify']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _toDouble(json['price']),
      layingWith: json['laying_with']?.toString() ?? '',
      imageUrl: _cleanUrl(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => {
    'Item_id': itemId,
    'item_number': itemNumber,
    'old_varient': oldVariant,
    'product_category': productCategory,
    'solitaire_slab': solitaireSlab,
    'weight': weight,
    'isnew': isNew,
    'classify': classify,
    'description': description,
    'price': price,
    'laying_with': layingWith,
    'image_url': imageUrl,
  };
}

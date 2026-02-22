class Jewellery {
  final int itemId;
  final String itemNumber;
  final String? designno;
  final String? oldVariant;
  final String productCategory;
  final String? solitaireSlab;
  final double? weight;
  final int? pcs; // new
  final bool isNew;

  final String? classify;
  final String? description;
  final double? price;
  final String? layingWith;
  final String? shape; // new
  final String? color; // new
  final String? clarity; // new
  final String? imageUrl;

  const Jewellery({
    required this.itemId,
    required this.itemNumber,
    this.designno,
    this.oldVariant,
    required this.productCategory,
    this.solitaireSlab,
    this.weight,
    this.pcs, //new
    required this.isNew,
    this.classify,
    this.description,
    this.price,
    this.layingWith,
    this.shape, // new
    this.color, // new
    this.clarity, // new
    this.imageUrl,
  });

  // 🔹 यही जोड़ना है
  Jewellery copyWith({
    int? itemId,
    String? itemNumber,
    String? designno,
    String? oldVariant,
    String? productCategory,
    String? solitaireSlab,
    double? weight,
    int? pcs,
    bool? isNew,
    String? classify,
    String? description,
    double? price,
    String? layingWith,
    String? shape,
    String? color,
    String? clarity,
    String? imageUrl,
  }) {
    return Jewellery(
      itemId: itemId ?? this.itemId,
      itemNumber: itemNumber ?? this.itemNumber,
      designno: designno ?? this.designno,
      oldVariant: oldVariant ?? this.oldVariant,
      productCategory: productCategory ?? this.productCategory,
      solitaireSlab: solitaireSlab ?? this.solitaireSlab,
      weight: weight ?? this.weight,
      pcs: pcs ?? this.pcs,
      isNew: isNew ?? this.isNew,
      classify: classify ?? this.classify,
      description: description ?? this.description,
      price: price ?? this.price,
      layingWith: layingWith ?? this.layingWith,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      clarity: clarity ?? this.clarity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Jewellery.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.isNotEmpty) return double.tryParse(v);
      return null;
    }

    String? cleanUrl(dynamic v) {
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
      designno: json['designno']?.toString() ?? '',
      oldVariant: json['old_varient']?.toString(),
      productCategory: json['product_category']?.toString() ?? '',
      solitaireSlab: json['solitaire_slab']?.toString(),
      weight: toDouble(json['weight']),
      pcs: json['pcs'] is int
          ? json['pcs']
          : int.tryParse(json['pcs']?.toString() ?? ''),
      isNew:
          json['isnew'] == true ||
          json['isnew'] == 1 ||
          json['isnew']?.toString().toLowerCase() == 'true',
      classify: json['classify']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: toDouble(json['price']),
      layingWith: json['laying_with']?.toString() ?? '',
      shape: json['shape']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      clarity: json['clarity']?.toString() ?? '',
      imageUrl: cleanUrl(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => {
    'Item_id': itemId,
    'item_number': itemNumber,
    'designno': designno,
    'old_varient': oldVariant,
    'product_category': productCategory,
    'solitaire_slab': solitaireSlab,
    'weight': weight,
    'pcs': pcs,
    'isnew': isNew,
    'classify': classify,
    'description': description,
    'price': price,
    'laying_with': layingWith,
    'shape': shape,
    'color': color,
    'clarity': clarity,
    'image_url': imageUrl,
  };
}

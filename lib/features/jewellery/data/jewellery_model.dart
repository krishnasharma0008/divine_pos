class Jewellery {
  final int itemId;
  final String itemNumber;
  final String oldVariant;
  final String productCategory;
  final String solitaireSlab;
  final String weight;
  final String bomVariantName;
  final String imageUrl;
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

  // Optional: factory method for JSON
  factory Jewellery.fromJson(Map<String, dynamic> json) {
    return Jewellery(
      itemId: json['Item_id'] as int,
      itemNumber: json['item_number'] as String,
      oldVariant: json['old_varient'] as String,
      productCategory: json['product_category'] as String,
      solitaireSlab: json['solitaire_slab'] as String,
      weight: json['weight'] as String,
      bomVariantName: json['bom_variant_name'] as String,
      imageUrl: json['image_url'] as String,
      isNew: json['isnew'] as bool,
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

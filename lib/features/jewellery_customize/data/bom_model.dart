class Bom {
  final int bomId;
  final int productId;
  final int variantId;
  final String itemType;
  final String itemGroup;
  final String bomVariantName;
  final int pcs;
  final double avgWeight;
  final double weight;

  Bom({
    required this.bomId,
    required this.productId,
    required this.variantId,
    required this.itemType,
    required this.itemGroup,
    required this.bomVariantName,
    required this.pcs,
    required this.avgWeight,
    required this.weight,
  });

  factory Bom.fromJson(Map<String, dynamic> json) {
    return Bom(
      bomId: json['Bom_id'] ?? 0,
      productId: json['Product_id'] ?? 0,
      variantId: json['Variant_id'] ?? 0,
      itemType: json['Item_type'] ?? '',
      itemGroup: json['Item_group'] ?? '',
      bomVariantName: json['Bom_variant_name'] ?? '',
      pcs: json['Pcs'] ?? 0,
      avgWeight: (json['Avg_weight'] ?? 0).toDouble(),
      weight: (json['Weight'] ?? 0).toDouble(),
    );
  }
}

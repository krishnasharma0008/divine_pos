class Variant {
  final int variantId;
  final int productId;
  final String variantName;
  final String metalPurity;
  final String solitaireSlab;
  final String size;
  final bool isBaseVariant;

  final String? variantApprovedDate;
  final String? rhodiumInstruction;
  final String? specialInstruction;
  final String? customer;
  final bool forWeb;
  final String status;

  Variant({
    required this.variantId,
    required this.productId,
    required this.variantName,
    required this.metalPurity,
    required this.solitaireSlab,
    required this.size,
    required this.isBaseVariant,
    this.variantApprovedDate,
    this.rhodiumInstruction,
    this.specialInstruction,
    this.customer,
    required this.forWeb,
    required this.status,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      variantId: json['Variant_id'] ?? 0,
      productId: json['Product_id'] ?? 0,
      variantName: json['Variant_name'] ?? '',
      metalPurity: json['Metal_purity'] ?? '',
      solitaireSlab: json['Solitaire_slab'] ?? '',
      size: json['Size'] ?? '',

      /// API sends 0 / 1
      isBaseVariant: json['Is_base_variant'] == 1,

      variantApprovedDate: json['Variant_approved_date'],
      rhodiumInstruction: json['Rhodium_instruction'],
      specialInstruction: json['Special_instruction'],
      customer: json['Customer'],

      /// API sends 0 / 1
      forWeb: json['For_web'] == 1,

      status: json['Status'] ?? '',
    );
  }
}

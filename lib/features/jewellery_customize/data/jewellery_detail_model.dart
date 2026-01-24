import 'product_images.dart';
import 'variant_model.dart';
import 'bom_model.dart';

class JewelleryDetail {
  final int itemId;
  final String itemNumber;
  final String productName;

  final String productCategory;
  final String productSubCategory;
  final String subCategory2;
  final String subCategory3;
  final String subCategory4;

  final String style;
  final String wearStyle;
  final String look;
  final String status;

  final String productDescription;
  final String remark;

  final String productRangeFrom;
  final String productRangeTo;
  final String oldVariant;

  final double? productRangeFromMin;
  final double? productRangeToMax;

  final String productSizeFrom;
  final String productSizeTo;

  final String metalColor;
  final String metalPurity;
  final String currentStatus;

  final String portfolioType;
  final String collection;
  final String gender;

  final String? variantApprovedDate;

  final double? metalPriceLessOneGms;
  final double? productPrice;

  final List<String> ctsSizeSlab;
  final List<ProductImage> images;
  final List<Variant> variants;
  final List<Bom> bom;

  JewelleryDetail({
    required this.itemId,
    required this.itemNumber,
    required this.productName,
    required this.productCategory,
    required this.productSubCategory,
    required this.subCategory2,
    required this.subCategory3,
    required this.subCategory4,
    required this.style,
    required this.wearStyle,
    required this.look,
    required this.status,
    required this.productDescription,
    required this.remark,
    required this.productRangeFrom,
    required this.productRangeTo,
    required this.oldVariant,
    required this.productRangeFromMin,
    required this.productRangeToMax,
    required this.productSizeFrom,
    required this.productSizeTo,
    required this.metalColor,
    required this.metalPurity,
    required this.currentStatus,
    required this.portfolioType,
    required this.collection,
    required this.gender,
    required this.variantApprovedDate,
    required this.metalPriceLessOneGms,
    required this.productPrice,
    required this.ctsSizeSlab,
    required this.images,
    required this.variants,
    required this.bom,
  });

  factory JewelleryDetail.fromJson(Map<String, dynamic> json) {
    return JewelleryDetail(
      itemId: json['Item_id'] ?? 0,
      itemNumber: json['Item_number'] ?? '',
      productName: json['Product_name'] ?? '',

      productCategory: json['Product_category'] ?? '',
      productSubCategory: json['Product_sub_category'] ?? '',
      subCategory2: json['Sub_catagory_2'] ?? '',
      subCategory3: json['Sub_catagory_3'] ?? '',
      subCategory4: json['Sub_catagory_4'] ?? '',

      style: json['Style'] ?? '',
      wearStyle: json['Wear_style'] ?? '',
      look: json['Look'] ?? '',
      status: json['Status'] ?? '',

      productDescription: json['Product_description'] ?? '',
      remark: json['Remark'] ?? '',

      productRangeFrom: json['Product_range_from'] ?? '',
      productRangeTo: json['Product_range_to'] ?? '',
      oldVariant: json['Old_varient'] ?? '',

      // productRangeFromMin: json['Product_range_from_min'] ?? '',
      // productRangeToMax: json['Product_range_to_max'] ?? '',
      productRangeFromMin:
          double.tryParse(json['Product_range_from_min']?.toString() ?? '0') ??
          0,
      productRangeToMax:
          double.tryParse(json['Product_range_to_max']?.toString() ?? '0') ?? 0,

      //       productRangeFromMin:
      //     (json['Product_range_from_min'] as num?)?.toDouble(),

      // productRangeToMax:
      //     (json['Product_range_to_max'] as num?)?.toDouble(),
      productSizeFrom: json['Product_size_from'] ?? '',
      productSizeTo: json['Product_size_to'] ?? '',

      metalColor: json['Metal_color'] ?? '',
      metalPurity: json['Metal_purity'] ?? '',
      currentStatus: json['Current_status'] ?? '',

      portfolioType: json['Portfolio_type'] ?? '',
      collection: json['Collection'] ?? '',
      gender: json['Gender'] ?? '',

      variantApprovedDate: json['Variant_approved_date'],

      // metalPriceLessOneGms: json['Metal_price_lessonegms'] ?? '',
      // productPrice: json['Product_price'] ?? '',
      metalPriceLessOneGms:
          double.tryParse(json['Metal_price_lessonegms']?.toString() ?? '0') ??
          0,
      productPrice:
          double.tryParse(json['Product_price']?.toString() ?? '0') ?? 0,

      //       metalPriceLessOneGms:
      //     (json['Metal_price_lessonegms'] as num?)?.toDouble(),

      // productPrice:
      //     (json['Product_price'] as num?)?.toDouble(),
      ctsSizeSlab: (json['Cts_size_slab'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      images: (json['Images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),

      variants: (json['Variants'] as List<dynamic>? ?? [])
          .map((e) => Variant.fromJson(e))
          .toList(),

      bom: (json['Bom'] as List<dynamic>? ?? [])
          .map((e) => Bom.fromJson(e))
          .toList(),
    );
  }
}

class CartDetail {
  final int? id;
  final String? orderFor;
  final int? customerId;
  final String? customerCode;
  final String? customerName;
  final String? customerBranch;
  final String? orderType;
  final String? productType;
  final String? productCategory;
  final String? productSubCategory;
  final String? collection;
  final String? expDlvDate;
  final String? oldVarient;
  final String? productCode;
  final int? solitairePcs;
  final int? productQty;
  final double? productAmtMin;
  final double? productAmtMax;
  final String? solitaireShape;
  final String? solitaireSlab;
  final String? solitaireColor;
  final String? solitaireQuality;
  final String? solitairePremSize;
  final double? solitairePremPct;
  final double? solitaireAmtMin;
  final double? solitaireAmtMax;
  final String? metalType;
  final String? metalPurity;
  final String? metalColor;
  final double? metalWeight;
  final double? metalPrice;
  final double? mountAmtMin;
  final double? mountAmtMax;
  final String? sizeFrom;
  final String? sizeTo;
  final int? sideStonePcs;
  final double? sideStoneCts;
  final String? sideStoneColor;
  final String? sideStoneQuality;
  final String? cartRemarks;
  final String? orderRemarks;
  final String? imageUrl;
  final String? style;
  final String? wearStyle;
  final String? look;
  final String? portfolioType;
  final String? gender;

  /// 🔥 NEW (UI ONLY)
  //final bool engravingEnabled;

  const CartDetail({
    this.id,
    this.orderFor,
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerBranch,
    this.orderType,
    this.productType,
    this.productCategory,
    this.productSubCategory,
    this.collection,
    this.expDlvDate,
    this.oldVarient,
    this.productCode,
    this.solitairePcs,
    this.productQty,
    this.productAmtMin,
    this.productAmtMax,
    this.solitaireShape,
    this.solitaireSlab,
    this.solitaireColor,
    this.solitaireQuality,
    this.solitairePremSize,
    this.solitairePremPct,
    this.solitaireAmtMin,
    this.solitaireAmtMax,
    this.metalType,
    this.metalPurity,
    this.metalColor,
    this.metalWeight,
    this.metalPrice,
    this.mountAmtMin,
    this.mountAmtMax,
    this.sizeFrom,
    this.sizeTo,
    this.sideStonePcs,
    this.sideStoneCts,
    this.sideStoneColor,
    this.sideStoneQuality,
    this.cartRemarks,
    this.orderRemarks,
    this.imageUrl,
    this.style,
    this.wearStyle,
    this.look,
    this.portfolioType,
    this.gender,
    //this.engravingEnabled = false, // ✅ default
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'] as int?,
      orderFor: json['order_for'] as String?,
      customerId: json['customer_id'] as int?,
      customerCode: json['customer_code'] as String?,
      customerName: json['customer_name'] as String?,
      customerBranch: json['customer_branch'] as String?,
      orderType: json['order_type'] as String?,
      productType: json['product_type'] as String?,
      productCategory: json['product_category'] as String?,
      productSubCategory: json['product_sub_category'] as String?,
      collection: json['collection'] as String?,
      expDlvDate: json['exp_dlv_date'] as String?,
      oldVarient: json['old_varient'] as String?,
      productCode: json['product_code'] as String?,
      solitairePcs: json['solitaire_pcs'] as int?,
      productQty: json['product_qty'] as int?,
      productAmtMin: (json['product_amt_min'] as num?)?.toDouble(),
      productAmtMax: (json['product_amt_max'] as num?)?.toDouble(),
      solitaireShape: json['solitaire_shape'] as String?,
      solitaireSlab: json['solitaire_slab'] as String?,
      solitaireColor: json['solitaire_color'] as String?,
      solitaireQuality: json['solitaire_quality'] as String?,
      solitairePremSize: json['solitaire_prem_size'] as String?,
      solitairePremPct: (json['solitaire_prem_pct'] as num?)?.toDouble(),
      solitaireAmtMin: (json['solitaire_amt_min'] as num?)?.toDouble(),
      solitaireAmtMax: (json['solitaire_amt_max'] as num?)?.toDouble(),
      metalType: json['metal_type'] as String?,
      metalPurity: json['metal_purity'] as String?,
      metalColor: json['metal_color'] as String?,
      metalWeight: (json['metal_weight'] as num?)?.toDouble(),
      metalPrice: (json['metal_price'] as num?)?.toDouble(),
      mountAmtMin: (json['mount_amt_min'] as num?)?.toDouble(),
      mountAmtMax: (json['mount_amt_max'] as num?)?.toDouble(),
      sizeFrom: json['size_from'] as String?,
      sizeTo: json['size_to'] as String?,
      sideStonePcs: json['side_stone_pcs'] as int?,
      sideStoneCts: (json['side_stone_cts'] as num?)?.toDouble(),
      sideStoneColor: json['side_stone_color'] as String?,
      sideStoneQuality: json['side_stone_quality'] as String?,
      cartRemarks: json['cart_remarks'] as String?, //remarks,
      orderRemarks: json['order_remarks'] as String?,
      imageUrl: json['image_url'] as String?,
      style: json['style'] as String?,
      wearStyle: json['wear_style'] as String?,
      look: json['look'] as String?,
      portfolioType: json['portfolio_type'] as String?,
      gender: json['gender'] as String?,
      //engravingEnabled: remarks != null, // ✅ KEY FIX
    );
  }

  CartDetail copyWith({
    int? id,
    String? orderFor,
    int? customerId,
    String? customerCode,
    String? customerName,
    String? customerBranch,
    String? orderType,
    String? productType,
    String? productCategory,
    String? productSubCategory,
    String? collection,
    String? expDlvDate,
    String? oldVarient,
    String? productCode,
    int? solitairePcs,
    int? productQty,
    double? productAmtMin,
    double? productAmtMax,
    String? solitaireShape,
    String? solitaireSlab,
    String? solitaireColor,
    String? solitaireQuality,
    String? solitairePremSize,
    double? solitairePremPct,
    double? solitaireAmtMin,
    double? solitaireAmtMax,
    String? metalType,
    String? metalPurity,
    String? metalColor,
    double? metalWeight,
    double? metalPrice,
    double? mountAmtMin,
    double? mountAmtMax,
    String? sizeFrom,
    String? sizeTo,
    int? sideStonePcs,
    double? sideStoneCts,
    String? sideStoneColor,
    String? sideStoneQuality,
    String? cartRemarks,
    String? orderRemarks,
    String? imageUrl,
    String? style,
    String? wearStyle,
    String? look,
    String? portfolioType,
    String? gender,
  }) {
    return CartDetail(
      id: id ?? this.id,
      orderFor: orderFor ?? this.orderFor,
      customerId: customerId ?? this.customerId,
      customerCode: customerCode ?? this.customerCode,
      customerName: customerName ?? this.customerName,
      customerBranch: customerBranch ?? this.customerBranch,
      orderType: orderType ?? this.orderType,
      productType: productType ?? this.productType,
      productCategory: productCategory ?? this.productCategory,
      productSubCategory: productSubCategory ?? this.productSubCategory,
      collection: collection ?? this.collection,
      expDlvDate: expDlvDate ?? this.expDlvDate,
      oldVarient: oldVarient ?? this.oldVarient,
      productCode: productCode ?? this.productCode,
      solitairePcs: solitairePcs ?? this.solitairePcs,
      productQty: productQty ?? this.productQty,
      productAmtMin: productAmtMin ?? this.productAmtMin,
      productAmtMax: productAmtMax ?? this.productAmtMax,
      solitaireShape: solitaireShape ?? this.solitaireShape,
      solitaireSlab: solitaireSlab ?? this.solitaireSlab,
      solitaireColor: solitaireColor ?? this.solitaireColor,
      solitaireQuality: solitaireQuality ?? this.solitaireQuality,
      solitairePremSize: solitairePremSize ?? this.solitairePremSize,
      solitairePremPct: solitairePremPct ?? this.solitairePremPct,
      solitaireAmtMin: solitaireAmtMin ?? this.solitaireAmtMin,
      solitaireAmtMax: solitaireAmtMax ?? this.solitaireAmtMax,
      metalType: metalType ?? this.metalType,
      metalPurity: metalPurity ?? this.metalPurity,
      metalColor: metalColor ?? this.metalColor,
      metalWeight: metalWeight ?? this.metalWeight,
      metalPrice: metalPrice ?? this.metalPrice,
      mountAmtMin: mountAmtMin ?? this.mountAmtMin,
      mountAmtMax: mountAmtMax ?? this.mountAmtMax,
      sizeFrom: sizeFrom ?? this.sizeFrom,
      sizeTo: sizeTo ?? this.sizeTo,
      sideStonePcs: sideStonePcs ?? this.sideStonePcs,
      sideStoneCts: sideStoneCts ?? this.sideStoneCts,
      sideStoneColor: sideStoneColor ?? this.sideStoneColor,
      sideStoneQuality: sideStoneQuality ?? this.sideStoneQuality,
      cartRemarks: cartRemarks ?? this.cartRemarks,
      orderRemarks: orderRemarks ?? this.orderRemarks,
      imageUrl: imageUrl ?? this.imageUrl,
      style: style ?? this.style,
      wearStyle: wearStyle ?? this.wearStyle,
      look: look ?? this.look,
      portfolioType: portfolioType ?? this.portfolioType,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_for': orderFor,
      'customer_id': customerId,
      'customer_code': customerCode,
      'customer_name': customerName,
      'customer_branch': customerBranch,
      'order_type': orderType,
      'product_type': productType,
      'product_category': productCategory,
      'product_sub_category': productSubCategory,
      'collection': collection,
      'exp_dlv_date': expDlvDate,
      'old_varient': oldVarient,
      'product_code': productCode,
      'solitaire_pcs': solitairePcs,
      'product_qty': productQty,
      'product_amt_min': productAmtMin,
      'product_amt_max': productAmtMax,
      'solitaire_shape': solitaireShape,
      'solitaire_slab': solitaireSlab,
      'solitaire_color': solitaireColor,
      'solitaire_quality': solitaireQuality,
      'solitaire_prem_size': solitairePremSize,
      'solitaire_prem_pct': solitairePremPct,
      'solitaire_amt_min': solitaireAmtMin,
      'solitaire_amt_max': solitaireAmtMax,
      'metal_type': metalType,
      'metal_purity': metalPurity,
      'metal_color': metalColor,
      'metal_weight': metalWeight,
      'metal_price': metalPrice,
      'mount_amt_min': mountAmtMin,
      'mount_amt_max': mountAmtMax,
      'size_from': sizeFrom,
      'size_to': sizeTo,
      'side_stone_pcs': sideStonePcs,
      'side_stone_cts': sideStoneCts,
      'side_stone_color': sideStoneColor,
      'side_stone_quality': sideStoneQuality,
      'cart_remarks': cartRemarks,
      'order_remarks': orderRemarks,
      'image_url': imageUrl,
      'style': style,
      'wear_style': wearStyle,
      'look': look,
      'portfolio_type': portfolioType,
      'gender': gender,
    };
  }
}

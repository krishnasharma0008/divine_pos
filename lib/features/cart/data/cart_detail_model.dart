int _i(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

String? _s(dynamic v) => v?.toString();

class CartDetail {
  final int? id;
  // final String? username; // 🔥 NEW (UI ONLY
  // final String? orderFrom; // 🔥 NEW (UI ONLY)
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
  final String? designno;
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
    // this.username, // 🔥 NEW (UI ONLY)
    // this.orderFrom, // 🔥 NEW (UI ONLY)
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
    this.designno,
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
      id: _i(json['id']),
      // username: _s(json['username']),
      // orderFrom: _s(json['order_from']),
      orderFor: _s(json['order_for']),
      customerId: _i(json['customer_id']),
      customerCode: _s(json['customer_code']),
      customerName: _s(json['customer_name']),
      customerBranch: _s(json['customer_branch']),
      orderType: _s(json['order_type']),
      productType: _s(json['product_type']),
      productCategory: _s(json['product_category']),
      productSubCategory: _s(json['product_sub_category']),
      collection: _s(json['collection']),
      expDlvDate: _s(json['exp_dlv_date']),
      oldVarient: _s(json['old_varient']),
      productCode: _s(json['product_code']),
      designno: _s(json['designno']),
      solitairePcs: _i(json['solitaire_pcs']),
      productQty: _i(json['product_qty']),
      productAmtMin: _d(json['product_amt_min']),
      productAmtMax: _d(json['product_amt_max']),
      solitaireShape: _s(json['solitaire_shape']),
      solitaireSlab: _s(json['solitaire_slab']),
      solitaireColor: _s(json['solitaire_color']),
      solitaireQuality: _s(json['solitaire_quality']),
      solitairePremSize: _s(json['solitaire_prem_size']),
      solitairePremPct: _d(json['solitaire_prem_pct']),
      solitaireAmtMin: _d(json['solitaire_amt_min']),
      solitaireAmtMax: _d(json['solitaire_amt_max']),
      metalType: _s(json['metal_type']),
      metalPurity: _s(json['metal_purity']),
      metalColor: _s(json['metal_color']),
      metalWeight: _d(json['metal_weight']),
      metalPrice: _d(json['metal_price']),
      mountAmtMin: _d(json['mount_amt_min']),
      mountAmtMax: _d(json['mount_amt_max']),
      sizeFrom: _s(json['size_from']),
      sizeTo: _s(json['size_to']),
      sideStonePcs: _i(json['side_stone_pcs']),
      sideStoneCts: _d(json['side_stone_cts']),
      sideStoneColor: _s(json['side_stone_color']),
      sideStoneQuality: _s(json['side_stone_quality']),
      cartRemarks: _s(json['cart_remarks']),
      orderRemarks: _s(json['order_remarks']),
      imageUrl: _s(json['image_url']),
      style: _s(json['style']),
      wearStyle: _s(json['wear_style']),
      look: _s(json['look']),
      portfolioType: _s(json['portfolio_type']),
      gender: _s(json['gender']),
    );
  }

  CartDetail copyWith({
    int? id,
    // String? username, // 🔥 NEW (UI ONLY
    // String? orderFrom, // 🔥 NEW (UI ONLY)
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
    String? designno,
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
      // username: username ?? this.username, // 🔥 NEW (UI ONLY
      // orderFrom: orderFrom ?? this.orderFrom, // 🔥 NEW (UI ONLY)
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
      designno: designno ?? this.designno,
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
    final map = <String, dynamic>{
      'id': id,
      // 'username': username, // 🔥 NEW (UI ONLY
      // 'order_from': orderFrom, // 🔥 NEW (UI ONLY
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
      'designno': designno,
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

    map.removeWhere((_, v) => v == null || (v is String && v.isEmpty));
    return map;
  }
}

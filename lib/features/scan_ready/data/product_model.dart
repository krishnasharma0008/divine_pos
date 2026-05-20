class ProductModel {
  final int id;

  final String? username;
  final String? placedBy;
  final String? orderFrom;
  final String? orderno;
  final String? orderFor;
  final int? customerId;
  final String? customerCode;
  final String? customerName;
  final String? customerBranch;
  final int? endCustomerId;
  final String? endCustomerName;

  final String? productType;
  final String? productCategory;
  final String? productSubCategory;
  final String? orderType;
  final String? expDlvDate;
  final String? itemno;
  final String? oldVarient;
  final String? designno;
  final String? productCode;
  final int? productQty;
  final double? productAmtMin;
  final double? productAmtMax;

  final String? solitaireShape;
  final String? solitaireSlab;
  final String? solitaireColor;
  final String? solitaireQuality;
  final int? solitairePcs;
  final String? solitairePremSize;
  final double? solitairePremPct;
  final double? solitaireAmtMin;
  final double? solitaireAmtMax;

  final String? metalType;
  final String? metalPurity;
  final String? metalColor;
  final double? metalWeight;
  final double? metalPrice;

  final String? sizeFrom;
  final String? sizeTo;

  final int? sideStonePcs;
  final double? sideStoneCtw;
  final String? sideStoneColor;
  final String? sideStoneQuality;

  final double? mountAmtMin;
  final double? mountAmtMax;

  final String? style;
  final String? wearStyle;
  final String? look;
  final String? portfolioType;
  final String? collection;
  final String? gender;

  final String? cartRemarks;
  final String? orderRemarks;
  final String? orderStatus;
  final String? imageUrl;

  final bool? isNew;
  final String? classify;
  final String? description;
  final String? layingWith;
  final String? lyingWithId;
  final String? lyingWithName;
  final String? lyingWithNickname;

  const ProductModel({
    required this.id,
    this.username,
    this.placedBy,
    this.orderFrom,
    this.orderno,
    this.orderFor,
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerBranch,
    this.endCustomerId,
    this.endCustomerName,
    this.productType,
    this.productCategory,
    this.productSubCategory,
    this.orderType,
    this.expDlvDate,
    this.itemno,
    this.oldVarient,
    this.designno,
    this.productCode,
    this.productQty,
    this.productAmtMin,
    this.productAmtMax,
    this.solitaireShape,
    this.solitaireSlab,
    this.solitaireColor,
    this.solitaireQuality,
    this.solitairePcs,
    this.solitairePremSize,
    this.solitairePremPct,
    this.solitaireAmtMin,
    this.solitaireAmtMax,
    this.metalType,
    this.metalPurity,
    this.metalColor,
    this.metalWeight,
    this.metalPrice,
    this.sizeFrom,
    this.sizeTo,
    this.sideStonePcs,
    this.sideStoneCtw,
    this.sideStoneColor,
    this.sideStoneQuality,
    this.mountAmtMin,
    this.mountAmtMax,
    this.style,
    this.wearStyle,
    this.look,
    this.portfolioType,
    this.collection,
    this.gender,
    this.cartRemarks,
    this.orderRemarks,
    this.orderStatus,
    this.imageUrl,
    this.isNew,
    this.classify,
    this.description,
    this.layingWith,
    this.lyingWithId,
    this.lyingWithName,
    this.lyingWithNickname,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  static const _unset = Object();

  ProductModel copyWith({
    Object? id = _unset,
    Object? username = _unset,
    Object? placedBy = _unset,
    Object? orderFrom = _unset,
    Object? orderno = _unset,
    Object? orderFor = _unset,
    Object? customerId = _unset,
    Object? customerCode = _unset,
    Object? customerName = _unset,
    Object? customerBranch = _unset,
    Object? endCustomerId = _unset,
    Object? endCustomerName = _unset,
    Object? productType = _unset,
    Object? productCategory = _unset,
    Object? productSubCategory = _unset,
    Object? orderType = _unset,
    Object? expDlvDate = _unset,
    Object? itemno = _unset,
    Object? oldVarient = _unset,
    Object? designno = _unset,
    Object? productCode = _unset,
    Object? productQty = _unset,
    Object? productAmtMin = _unset,
    Object? productAmtMax = _unset,
    Object? solitaireShape = _unset,
    Object? solitaireSlab = _unset,
    Object? solitaireColor = _unset,
    Object? solitaireQuality = _unset,
    Object? solitairePcs = _unset,
    Object? solitairePremSize = _unset,
    Object? solitairePremPct = _unset,
    Object? solitaireAmtMin = _unset,
    Object? solitaireAmtMax = _unset,
    Object? metalType = _unset,
    Object? metalPurity = _unset,
    Object? metalColor = _unset,
    Object? metalWeight = _unset,
    Object? metalPrice = _unset,
    Object? sizeFrom = _unset,
    Object? sizeTo = _unset,
    Object? sideStonePcs = _unset,
    Object? sideStoneCtw = _unset,
    Object? sideStoneColor = _unset,
    Object? sideStoneQuality = _unset,
    Object? mountAmtMin = _unset,
    Object? mountAmtMax = _unset,
    Object? style = _unset,
    Object? wearStyle = _unset,
    Object? look = _unset,
    Object? portfolioType = _unset,
    Object? collection = _unset,
    Object? gender = _unset,
    Object? cartRemarks = _unset,
    Object? orderRemarks = _unset,
    Object? orderStatus = _unset,
    Object? imageUrl = _unset,
    Object? isNew = _unset,
    Object? classify = _unset,
    Object? description = _unset,
    Object? layingWith = _unset,
    Object? lyingWithId = _unset,
    Object? lyingWithName = _unset,
    Object? lyingWithNickname = _unset,
  }) {
    return ProductModel(
      id: id == _unset ? this.id : id as int,
      username: username == _unset ? this.username : username as String?,
      placedBy: placedBy == _unset ? this.placedBy : placedBy as String?,
      orderFrom: orderFrom == _unset ? this.orderFrom : orderFrom as String?,
      orderno: orderno == _unset ? this.orderno : orderno as String?,
      orderFor: orderFor == _unset ? this.orderFor : orderFor as String?,
      customerId: customerId == _unset ? this.customerId : customerId as int?,
      customerCode: customerCode == _unset
          ? this.customerCode
          : customerCode as String?,
      customerName: customerName == _unset
          ? this.customerName
          : customerName as String?,
      customerBranch: customerBranch == _unset
          ? this.customerBranch
          : customerBranch as String?,
      endCustomerId: endCustomerId == _unset
          ? this.endCustomerId
          : endCustomerId as int?,
      endCustomerName: endCustomerName == _unset
          ? this.endCustomerName
          : endCustomerName as String?,
      productType: productType == _unset
          ? this.productType
          : productType as String?,
      productCategory: productCategory == _unset
          ? this.productCategory
          : productCategory as String?,
      productSubCategory: productSubCategory == _unset
          ? this.productSubCategory
          : productSubCategory as String?,
      orderType: orderType == _unset ? this.orderType : orderType as String?,
      expDlvDate: expDlvDate == _unset
          ? this.expDlvDate
          : expDlvDate as String?,
      itemno: itemno == _unset ? this.itemno : itemno as String?,
      oldVarient: oldVarient == _unset
          ? this.oldVarient
          : oldVarient as String?,
      designno: designno == _unset ? this.designno : designno as String?,
      productCode: productCode == _unset
          ? this.productCode
          : productCode as String?,
      productQty: productQty == _unset ? this.productQty : productQty as int?,
      productAmtMin: productAmtMin == _unset
          ? this.productAmtMin
          : productAmtMin as double?,
      productAmtMax: productAmtMax == _unset
          ? this.productAmtMax
          : productAmtMax as double?,
      solitaireShape: solitaireShape == _unset
          ? this.solitaireShape
          : solitaireShape as String?,
      solitaireSlab: solitaireSlab == _unset
          ? this.solitaireSlab
          : solitaireSlab as String?,
      solitaireColor: solitaireColor == _unset
          ? this.solitaireColor
          : solitaireColor as String?,
      solitaireQuality: solitaireQuality == _unset
          ? this.solitaireQuality
          : solitaireQuality as String?,
      solitairePcs: solitairePcs == _unset
          ? this.solitairePcs
          : solitairePcs as int?,
      solitairePremSize: solitairePremSize == _unset
          ? this.solitairePremSize
          : solitairePremSize as String?,
      solitairePremPct: solitairePremPct == _unset
          ? this.solitairePremPct
          : solitairePremPct as double?,
      solitaireAmtMin: solitaireAmtMin == _unset
          ? this.solitaireAmtMin
          : solitaireAmtMin as double?,
      solitaireAmtMax: solitaireAmtMax == _unset
          ? this.solitaireAmtMax
          : solitaireAmtMax as double?,
      metalType: metalType == _unset ? this.metalType : metalType as String?,
      metalPurity: metalPurity == _unset
          ? this.metalPurity
          : metalPurity as String?,
      metalColor: metalColor == _unset
          ? this.metalColor
          : metalColor as String?,
      metalWeight: metalWeight == _unset
          ? this.metalWeight
          : metalWeight as double?,
      metalPrice: metalPrice == _unset
          ? this.metalPrice
          : metalPrice as double?,
      sizeFrom: sizeFrom == _unset ? this.sizeFrom : sizeFrom as String?,
      sizeTo: sizeTo == _unset ? this.sizeTo : sizeTo as String?,
      sideStonePcs: sideStonePcs == _unset
          ? this.sideStonePcs
          : sideStonePcs as int?,
      sideStoneCtw: sideStoneCtw == _unset
          ? this.sideStoneCtw
          : sideStoneCtw as double?,
      sideStoneColor: sideStoneColor == _unset
          ? this.sideStoneColor
          : sideStoneColor as String?,
      sideStoneQuality: sideStoneQuality == _unset
          ? this.sideStoneQuality
          : sideStoneQuality as String?,
      mountAmtMin: mountAmtMin == _unset
          ? this.mountAmtMin
          : mountAmtMin as double?,
      mountAmtMax: mountAmtMax == _unset
          ? this.mountAmtMax
          : mountAmtMax as double?,
      style: style == _unset ? this.style : style as String?,
      wearStyle: wearStyle == _unset ? this.wearStyle : wearStyle as String?,
      look: look == _unset ? this.look : look as String?,
      portfolioType: portfolioType == _unset
          ? this.portfolioType
          : portfolioType as String?,
      collection: collection == _unset
          ? this.collection
          : collection as String?,
      gender: gender == _unset ? this.gender : gender as String?,
      cartRemarks: cartRemarks == _unset
          ? this.cartRemarks
          : cartRemarks as String?,
      orderRemarks: orderRemarks == _unset
          ? this.orderRemarks
          : orderRemarks as String?,
      orderStatus: orderStatus == _unset
          ? this.orderStatus
          : orderStatus as String?,
      imageUrl: imageUrl == _unset ? this.imageUrl : imageUrl as String?,
      isNew: isNew == _unset ? this.isNew : isNew as bool?,
      classify: classify == _unset ? this.classify : classify as String?,
      description: description == _unset
          ? this.description
          : description as String?,
      layingWith: layingWith == _unset
          ? this.layingWith
          : layingWith as String?,
      lyingWithId: lyingWithId == _unset
          ? this.lyingWithId
          : lyingWithId as String?,
      lyingWithName: lyingWithName == _unset
          ? this.lyingWithName
          : lyingWithName as String?,
      lyingWithNickname: lyingWithNickname == _unset
          ? this.lyingWithNickname
          : lyingWithNickname as String?,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
      return null;
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String && v.trim().isNotEmpty) return int.tryParse(v.trim());
      return null;
    }

    bool? toBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true') return true;
        if (s == 'false') return false;
      }
      return null;
    }

    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty || s == 'null' || s == '-' ? null : s;
    }

    return ProductModel(
      id: toInt(json['id'] ?? json['Item_id']) ?? 0,

      username: str(json['username']),
      placedBy: str(json['placed_by']),
      orderFrom: str(json['order_from']),
      orderno: str(json['orderno']),
      orderFor: str(json['order_for']),
      customerId: toInt(json['customer_id']),
      customerCode: str(json['customer_code']),
      customerName: str(json['customer_name']),
      customerBranch: str(json['customer_branch']),
      endCustomerId: toInt(json['end_customer_id']),
      endCustomerName: str(json['end_customer_name']),

      productType: str(json['product_type']),
      productCategory: str(json['product_category']),
      productSubCategory: str(json['product_sub_category']),
      orderType: str(json['order_type']),
      expDlvDate: str(json['exp_dlv_date']),
      itemno: str(json['item_number']),
      oldVarient: str(json['old_varient']),
      designno: str(json['designno']),
      productCode: str(json['product_code']),
      productQty: toInt(json['product_qty'] ?? json['pcs']),
      productAmtMin: toDouble(json['product_amt_min'] ?? json['price']),
      productAmtMax: toDouble(json['product_amt_max'] ?? json['price']),

      solitaireShape: str(json['solitaire_shape'] ?? json['shape']),
      solitaireSlab: str(json['solitaire_slab']),
      solitaireColor: str(json['solitaire_color'] ?? json['color']),
      solitaireQuality: str(json['solitaire_quality'] ?? json['clarity']),
      solitairePcs: toInt(json['solitaire_pcs'] ?? json['pcs']),
      solitairePremSize: str(json['solitaire_prem_size']),
      solitairePremPct: toDouble(json['solitaire_prem_pct']),
      solitaireAmtMin: toDouble(json['solitaire_amt_min'] ?? json['price']),
      solitaireAmtMax: toDouble(json['solitaire_amt_max'] ?? json['price']),

      metalType: str(json['metal_type']),
      metalPurity: str(json['metal_purity']),
      metalColor: str(json['metal_color']),
      metalWeight: toDouble(json['metal_weight'] ?? json['weight']),
      metalPrice: toDouble(json['metal_price'] ?? json['price']),

      sizeFrom: str(json['size_from']),
      sizeTo: str(json['size_to']),

      sideStonePcs: toInt(json['side_stone_pcs']),
      sideStoneCtw: toDouble(json['side_stone_cts']),
      sideStoneColor: str(json['side_stone_color']),
      sideStoneQuality: str(json['side_stone_quality']),

      mountAmtMin: toDouble(json['mount_amt_min']),
      mountAmtMax: toDouble(json['mount_amt_max']),

      style: str(json['style']),
      wearStyle: str(json['wear_style']),
      look: str(json['look']),
      portfolioType: str(json['portfolio_type']),
      collection: str(json['collection']),
      gender: str(json['gender']),

      cartRemarks: str(json['cart_remarks']),
      orderRemarks: str(json['order_remarks']),
      orderStatus: str(json['order_status']),
      imageUrl: str(json['image_url']),

      isNew: toBool(json['isnew']),
      classify: str(json['classify']),
      description: str(json['description']),
      layingWith: str(json['laying_with']),
      lyingWithId: str(json['lying_with_id']),
      lyingWithName: str(json['lying_with_name']),
      lyingWithNickname: str(json['lying_with_nickname']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'Item_id': id,
    'username': username,
    'placed_by': placedBy,
    'order_from': orderFrom,
    'orderno': orderno,
    'order_for': orderFor,
    'customer_id': customerId,
    'customer_code': customerCode,
    'customer_name': customerName,
    'customer_branch': customerBranch,
    'end_customer_id': endCustomerId,
    'end_customer_name': endCustomerName,
    'product_type': productType,
    'product_category': productCategory,
    'product_sub_category': productSubCategory,
    'order_type': orderType,
    'exp_dlv_date': expDlvDate,
    'item_number': itemno,
    'old_varient': oldVarient,
    'designno': designno,
    'product_code': productCode,
    'product_qty': productQty,
    'product_amt_min': productAmtMin,
    'product_amt_max': productAmtMax,
    'solitaire_shape': solitaireShape,
    'solitaire_slab': solitaireSlab,
    'solitaire_color': solitaireColor,
    'solitaire_quality': solitaireQuality,
    'solitaire_pcs': solitairePcs,
    'solitaire_prem_size': solitairePremSize,
    'solitaire_prem_pct': solitairePremPct,
    'solitaire_amt_min': solitaireAmtMin,
    'solitaire_amt_max': solitaireAmtMax,
    'metal_type': metalType,
    'metal_purity': metalPurity,
    'metal_color': metalColor,
    'metal_weight': metalWeight,
    'metal_price': metalPrice,
    'size_from': sizeFrom,
    'size_to': sizeTo,
    'side_stone_pcs': sideStonePcs,
    'side_stone_cts': sideStoneCtw,
    'side_stone_color': sideStoneColor,
    'side_stone_quality': sideStoneQuality,
    'mount_amt_min': mountAmtMin,
    'mount_amt_max': mountAmtMax,
    'style': style,
    'wear_style': wearStyle,
    'look': look,
    'portfolio_type': portfolioType,
    'collection': collection,
    'gender': gender,
    'cart_remarks': cartRemarks,
    'order_remarks': orderRemarks,
    'order_status': orderStatus,
    'image_url': imageUrl,
    'isnew': isNew,
    'classify': classify,
    'description': description,
    'laying_with': layingWith,
    'lying_with_id': lyingWithId,
    'lying_with_name': lyingWithName,
    'lying_with_nickname': lyingWithNickname,
    'price': productAmtMax,
    'weight': metalWeight,
    'pcs': solitairePcs ?? productQty,
    'shape': solitaireShape,
    'color': solitaireColor,
    'clarity': solitaireQuality,
  };

  static List<ProductModel> listFromJson(List<dynamic> list) {
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// =============================================================================
// lib/features/verify_track/data/verify_track_model.dart
// All TypeScript interfaces → Dart classes
// =============================================================================

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

// -----------------------------------------------------------------------------
// SltDetail  →  slt_details items
// -----------------------------------------------------------------------------

class SltDetail {
  final double carat;
  final String clarity;
  final String colour;
  final double currentPrice;
  final double purchasePrice;
  final String shape;
  final String uid;

  const SltDetail({
    required this.carat,
    required this.clarity,
    required this.colour,
    required this.currentPrice,
    required this.purchasePrice,
    required this.shape,
    required this.uid,
  });

  factory SltDetail.fromJson(Map<String, dynamic> json) => SltDetail(
    carat: (json['carat'] as num?)?.toDouble() ?? 0.0,
    clarity: json['clarity'] as String? ?? '',
    colour: json['colour'] as String? ?? '',
    currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
    purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
    shape: json['shape'] as String? ?? '',
    uid: json['uid'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'carat': carat,
    'clarity': clarity,
    'colour': colour,
    'current_price': currentPrice,
    'purchase_price': purchasePrice,
    'shape': shape,
    'uid': uid,
  };
}

// -----------------------------------------------------------------------------
// VerifyTrackByUid  →  full product details
// -----------------------------------------------------------------------------

class VerifyTrackByUid {
  // Product Info
  final String uid;
  final String uidStatus;
  final String productType; // "Jewellery" | "Diamond"
  final String category;
  final String collection;
  final String designNo;
  final String image;
  final List<String> images;
  final List<String> videos;
  final bool isCoin;
  // Pricing & Currency
  final String currencyCode;
  final String currencyLocale;
  final double currentPrice;
  final double purchasePrice;
  final double purchasePriceFinal;
  final double purchaseDiscount;
  final String purchaseFrom;
  final String purchaseDate;
  // Weight & Metal
  final double grossWt;
  final double netWt;
  final String jewellerySize;
  final double metalSdPurchasePrice;
  final double metalTotalCurrentPrice;
  // Solitaire (SLT)
  final List<SltDetail> sltDetails;
  final double sltTotalCts;
  final double sltTotalCurrentPrice;
  final int sltTotalPcs;
  final double? sltTotalPurchasePrice; // optional in TS
  final String solitaireDetails1;
  // Small Diamond (SD)
  final String sdColourClarity;
  final double sdCts;
  final int sdPcs;
  final double sdTotalCurrentPrice;
  // Mount
  final String mountDetails1;
  final String mountDetails2;
  // Upgrade
  final double upgradeMinimumPrice;
  // Buyback
  final bool buybackIsBlock;
  final String buybackBlockDate;
  final String buybackBlockMessage;
  final double buybackSolitairePrice;
  final double buybackMountPrice;
  final double buybackPrice;
  final double buybackProcessingCharges;
  final double buybackSameStorePrice;
  final double
  buybackDifferentStorePrice; // JSON key: buyback_diffrent_store_price (TS typo preserved)
  // Exchange
  final bool exchangeIsBlock;
  final String exchangeBlockDate;
  final String exchangeBlockMessage;
  final double exchangeSolitairePrice;
  final double exchangeMountPrice;
  final double exchangePrice;
  final double exchangeProcessingCharges;
  final double exchangeSameStorePrice;
  final double
  exchangeDifferentStorePrice; // JSON key: exchange_diffrent_store_price (TS typo preserved)

  const VerifyTrackByUid({
    required this.uid,
    required this.uidStatus,
    required this.productType,
    required this.category,
    required this.collection,
    required this.designNo,
    required this.image,
    required this.images,
    required this.videos,
    required this.isCoin,
    required this.currencyCode,
    required this.currencyLocale,
    required this.currentPrice,
    required this.purchasePrice,
    required this.purchasePriceFinal,
    required this.purchaseDiscount,
    required this.purchaseFrom,
    required this.purchaseDate,
    required this.grossWt,
    required this.netWt,
    required this.jewellerySize,
    required this.metalSdPurchasePrice,
    required this.metalTotalCurrentPrice,
    required this.sltDetails,
    required this.sltTotalCts,
    required this.sltTotalCurrentPrice,
    required this.sltTotalPcs,
    this.sltTotalPurchasePrice,
    required this.solitaireDetails1,
    required this.sdColourClarity,
    required this.sdCts,
    required this.sdPcs,
    required this.sdTotalCurrentPrice,
    required this.mountDetails1,
    required this.mountDetails2,
    required this.upgradeMinimumPrice,
    required this.buybackIsBlock,
    required this.buybackBlockDate,
    required this.buybackBlockMessage,
    required this.buybackSolitairePrice,
    required this.buybackMountPrice,
    required this.buybackPrice,
    required this.buybackProcessingCharges,
    required this.buybackSameStorePrice,
    required this.buybackDifferentStorePrice,
    required this.exchangeIsBlock,
    required this.exchangeBlockDate,
    required this.exchangeBlockMessage,
    required this.exchangeSolitairePrice,
    required this.exchangeMountPrice,
    required this.exchangePrice,
    required this.exchangeProcessingCharges,
    required this.exchangeSameStorePrice,
    required this.exchangeDifferentStorePrice,
  });

  factory VerifyTrackByUid.fromJson(
    Map<String, dynamic> json,
  ) => VerifyTrackByUid(
    uid: json['uid'] as String? ?? '',
    uidStatus: json['uid_status'] as String? ?? '',
    productType: json['product_type'] as String? ?? '',
    category: json['category'] as String? ?? '',
    collection: json['collection'] as String? ?? '',
    designNo: json['design_no'] as String? ?? '',
    image: json['image'] as String? ?? '',
    images: _parseStringList(json['images']),
    videos: _parseStringList(json['videos']),
    isCoin: json['is_coin'] as bool? ?? false,
    currencyCode: json['currency_code'] as String? ?? '',
    currencyLocale: json['currency_locale'] as String? ?? '',
    currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
    purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
    purchasePriceFinal:
        (json['purchase_price_final'] as num?)?.toDouble() ?? 0.0,
    purchaseDiscount: (json['purchase_discount'] as num?)?.toDouble() ?? 0.0,
    purchaseFrom: json['purchase_from'] as String? ?? '',
    purchaseDate: json['purchase_date'] as String? ?? '',
    grossWt: (json['gross_wt'] as num?)?.toDouble() ?? 0.0,
    netWt: (json['net_wt'] as num?)?.toDouble() ?? 0.0,
    jewellerySize: json['jewel_size'] as String? ?? '',
    metalSdPurchasePrice:
        (json['metal_sd_purchase_price'] as num?)?.toDouble() ?? 0.0,
    metalTotalCurrentPrice:
        (json['metal_total_current_price'] as num?)?.toDouble() ?? 0.0,
    sltDetails:
        (json['slt_details'] as List<dynamic>?)
            ?.map((e) => SltDetail.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    sltTotalCts: (json['slt_total_cts'] as num?)?.toDouble() ?? 0.0,
    sltTotalCurrentPrice:
        (json['slt_total_current_price'] as num?)?.toDouble() ?? 0.0,
    sltTotalPcs: json['slt_total_pcs'] as int? ?? 0,
    sltTotalPurchasePrice: (json['slt_total_purchase_price'] as num?)
        ?.toDouble(),
    solitaireDetails1: json['solitaire_details_1'] as String? ?? '',
    sdColourClarity: json['sd_colour_clarity'] as String? ?? '',
    sdCts: (json['sd_cts'] as num?)?.toDouble() ?? 0.0,
    sdPcs: json['sd_pcs'] as int? ?? 0,
    sdTotalCurrentPrice:
        (json['sd_total_current_price'] as num?)?.toDouble() ?? 0.0,
    mountDetails1: json['mount_details_1'] as String? ?? '',
    mountDetails2: json['mount_details_2'] as String? ?? '',
    upgradeMinimumPrice:
        (json['upgrade_minimum_price'] as num?)?.toDouble() ?? 0.0,
    buybackIsBlock: json['buyback_isblock'] as bool? ?? false,
    buybackBlockDate: json['buyback_block_date'] as String? ?? '',
    buybackBlockMessage: json['buyback_block_message'] as String? ?? '',
    buybackSolitairePrice:
        (json['buyback_solitaire_price'] as num?)?.toDouble() ?? 0.0,
    buybackMountPrice: (json['buyback_mount_price'] as num?)?.toDouble() ?? 0.0,
    buybackPrice: (json['buyback_price'] as num?)?.toDouble() ?? 0.0,
    buybackProcessingCharges:
        (json['buyback_processing_charges'] as num?)?.toDouble() ?? 0.0,
    buybackSameStorePrice:
        (json['buyback_same_store_price'] as num?)?.toDouble() ?? 0.0,
    buybackDifferentStorePrice:
        (json['buyback_diffrent_store_price'] as num?)?.toDouble() ?? 0.0,
    exchangeIsBlock: json['exchange_isblock'] as bool? ?? false,
    exchangeBlockDate: json['exchange_block_date'] as String? ?? '',
    exchangeBlockMessage: json['exchange_block_message'] as String? ?? '',
    exchangeSolitairePrice:
        (json['exchange_solitaire_price'] as num?)?.toDouble() ?? 0.0,
    exchangeMountPrice:
        (json['exchange_mount_price'] as num?)?.toDouble() ?? 0.0,
    exchangePrice: (json['exchange_price'] as num?)?.toDouble() ?? 0.0,
    exchangeProcessingCharges:
        (json['exchange_processing_charges'] as num?)?.toDouble() ?? 0.0,
    exchangeSameStorePrice:
        (json['exchange_same_store_price'] as num?)?.toDouble() ?? 0.0,
    exchangeDifferentStorePrice:
        (json['exchange_diffrent_store_price'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'uid_status': uidStatus,
    'product_type': productType,
    'category': category,
    'collection': collection,
    'design_no': designNo,
    'image': image,
    'images': images,
    'videos': videos,
    'is_coin': isCoin,
    'currency_code': currencyCode,
    'currency_locale': currencyLocale,
    'current_price': currentPrice,
    'purchase_price': purchasePrice,
    'purchase_price_final': purchasePriceFinal,
    'purchase_discount': purchaseDiscount,
    'purchase_from': purchaseFrom,
    'purchase_date': purchaseDate,
    'gross_wt': grossWt,
    'net_wt': netWt,
    'jewel_size': jewellerySize,
    'metal_sd_purchase_price': metalSdPurchasePrice,
    'metal_total_current_price': metalTotalCurrentPrice,
    'slt_details': sltDetails.map((e) => e.toJson()).toList(),
    'slt_total_cts': sltTotalCts,
    'slt_total_current_price': sltTotalCurrentPrice,
    'slt_total_pcs': sltTotalPcs,
    if (sltTotalPurchasePrice != null)
      'slt_total_purchase_price': sltTotalPurchasePrice,
    'solitaire_details_1': solitaireDetails1,
    'sd_colour_clarity': sdColourClarity,
    'sd_cts': sdCts,
    'sd_pcs': sdPcs,
    'sd_total_current_price': sdTotalCurrentPrice,
    'mount_details_1': mountDetails1,
    'mount_details_2': mountDetails2,
    'upgrade_minimum_price': upgradeMinimumPrice,
    'buyback_isblock': buybackIsBlock,
    'buyback_block_date': buybackBlockDate,
    'buyback_block_message': buybackBlockMessage,
    'buyback_solitaire_price': buybackSolitairePrice,
    'buyback_mount_price': buybackMountPrice,
    'buyback_price': buybackPrice,
    'buyback_processing_charges': buybackProcessingCharges,
    'buyback_same_store_price': buybackSameStorePrice,
    'buyback_diffrent_store_price': buybackDifferentStorePrice,
    'exchange_isblock': exchangeIsBlock,
    'exchange_block_date': exchangeBlockDate,
    'exchange_block_message': exchangeBlockMessage,
    'exchange_solitaire_price': exchangeSolitairePrice,
    'exchange_mount_price': exchangeMountPrice,
    'exchange_price': exchangePrice,
    'exchange_processing_charges': exchangeProcessingCharges,
    'exchange_same_store_price': exchangeSameStorePrice,
    'exchange_diffrent_store_price': exchangeDifferentStorePrice,
  };

  // ── Computed helpers ─────────────────────────────────────────────────────────
  bool get isSold => uidStatus == 'SOLD';
  bool get isDiamond => productType == 'Diamond';
  bool get isJewellery => productType == 'Jewellery';

  /// sdCts + sltTotalCts — used as AddToProductRequest.carat
  double get totalCarat => sdCts + sltTotalCts;

  /// jewellery → image url | diamond → first slt shape name
  String get productImage =>
      isJewellery ? image : (sltDetails.isNotEmpty ? sltDetails[0].shape : '');

  @override
  String toString() =>
      'VerifyTrackByUid(uid: $uid, productType: $productType, uidStatus: $uidStatus)';
}

// -----------------------------------------------------------------------------
// VerifyTrackByUidResponse
// -----------------------------------------------------------------------------

class VerifyTrackByUidResponse {
  final VerifyTrackByUid? data;
  final bool flag;
  final String message;

  bool get isSuccess => flag && data != null;

  const VerifyTrackByUidResponse({
    required this.data,
    required this.flag,
    required this.message,
  });

  factory VerifyTrackByUidResponse.fromJson(Map<String, dynamic> json) =>
      VerifyTrackByUidResponse(
        data: json['data'] != null
            ? VerifyTrackByUid.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        flag: json['flag'] as bool? ?? false,
        message: json['message'] as String? ?? 'Failed',
      );
}

// -----------------------------------------------------------------------------
// ProductStatusExists
// -----------------------------------------------------------------------------

class ProductStatusExists {
  final int id;
  final int userId;
  final String uid;
  final String productType;
  final String jewelCat;
  final String designNo;
  final double purchasePrice;
  final double currentPrice;
  final double carat;
  final String imgUrl;

  const ProductStatusExists({
    required this.id,
    required this.userId,
    required this.uid,
    required this.productType,
    required this.jewelCat,
    required this.designNo,
    required this.purchasePrice,
    required this.currentPrice,
    required this.carat,
    required this.imgUrl,
  });

  factory ProductStatusExists.fromJson(Map<String, dynamic> json) =>
      ProductStatusExists(
        id: json['id'] as int? ?? 0,
        userId: json['userid'] as int? ?? 0,
        uid: json['uid'] as String? ?? '',
        productType: json['product_type'] as String? ?? '',
        jewelCat: json['jewelcat'] as String? ?? '',
        designNo: json['design_no'] as String? ?? '',
        purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
        currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
        carat: (json['carat'] as num?)?.toDouble() ?? 0.0,
        imgUrl: json['imgurl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userid': userId,
    'uid': uid,
    'product_type': productType,
    'jewelcat': jewelCat,
    'design_no': designNo,
    'purchase_price': purchasePrice,
    'current_price': currentPrice,
    'carat': carat,
    'imgurl': imgUrl,
  };
}

// -----------------------------------------------------------------------------
// ProductStatusResponse
// -----------------------------------------------------------------------------

class ProductStatusResponse {
  final ProductStatusExists? data;
  final bool flag;
  bool get exists => data != null;

  const ProductStatusResponse({required this.data, required this.flag});

  factory ProductStatusResponse.fromJson(Map<String, dynamic> json) =>
      ProductStatusResponse(
        data: json['data'] != null
            ? ProductStatusExists.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        flag: json['flag'] as bool? ?? false,
      );
}

// -----------------------------------------------------------------------------
// AddToProductRequest  →  wishlist & portfolio payload
// -----------------------------------------------------------------------------

class AddToProductRequest {
  final String uid;
  final String productType;
  final String jewelCat;
  final String designNo;
  final double purchasePrice;
  final double currentPrice;
  final double carat;
  final String imgUrl;

  const AddToProductRequest({
    required this.uid,
    required this.productType,
    required this.jewelCat,
    required this.designNo,
    required this.purchasePrice,
    required this.currentPrice,
    required this.carat,
    required this.imgUrl,
  });

  /// Build directly from a VerifyTrackByUid product
  factory AddToProductRequest.fromProduct(VerifyTrackByUid p) =>
      AddToProductRequest(
        uid: p.uid,
        productType: p.productType,
        jewelCat: p.category,
        designNo: p.designNo,
        purchasePrice: p.purchasePrice,
        currentPrice: p.currentPrice,
        carat: p.totalCarat,
        imgUrl: p.productImage,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'product_type': productType,
    'jewelcat': jewelCat,
    'design_no': designNo,
    'purchase_price': purchasePrice,
    'current_price': currentPrice,
    'carat': carat,
    'imgurl': imgUrl,
  };
}

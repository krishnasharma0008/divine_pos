class SolitaireDetail {
  final int itemId;
  final String itemNumber;
  final String designNo;
  final String oldVariant;
  final String productCategory;
  final String solitaireSlab;
  final double weight;
  final int pcs;
  final bool isNew;
  final String? classify;
  final String? description;
  final double price;
  final String layingWith;
  final String shape;
  final String color;
  final String clarity;
  final String imageUrl;
  final String? laying_with; // new customer code
  final int lying_with_id; // new customer id
  final String? lying_with_name; // new customer name
  final String? lying_with_nickname; //new customer branch

  SolitaireDetail({
    required this.itemId,
    required this.itemNumber,
    required this.designNo,
    required this.oldVariant,
    required this.productCategory,
    required this.solitaireSlab,
    required this.weight,
    required this.pcs,
    required this.isNew,
    this.classify,
    this.description,
    required this.price,
    required this.layingWith,
    required this.shape,
    required this.color,
    required this.clarity,
    required this.imageUrl,
    this.laying_with, // new customer code
    this.lying_with_id = 0, // new customer id
    this.lying_with_name, // new customer name
    this.lying_with_nickname, // new customer branch
  });

  factory SolitaireDetail.fromJson(Map<String, dynamic> json) {
    return SolitaireDetail(
      itemId: json['Item_id'] ?? 0,
      itemNumber: json['item_number'] ?? '',
      designNo: json['designno'] ?? '',
      oldVariant: json['old_varient'] ?? '',
      productCategory: json['product_category'] ?? '',
      solitaireSlab: json['solitaire_slab'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      pcs: json['pcs'] ?? 0,
      isNew: json['isnew'] ?? false,
      classify: json['classify'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      layingWith: json['laying_with'] ?? '',
      shape: json['shape'] ?? '',
      color: json['color'] ?? '',
      clarity: json['clarity'] ?? '',
      imageUrl: json['image_url'] ?? '',
      laying_with: json['laying_with'], // new customer code
      lying_with_id: json['lying_with_id'] ?? 0, // new customer id
      lying_with_name: json['lying_with_name'], // new customer name
      lying_with_nickname: json['lying_with_nickname'], // new customer branch
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Item_id": itemId,
      "item_number": itemNumber,
      "designno": designNo,
      "old_varient": oldVariant,
      "product_category": productCategory,
      "solitaire_slab": solitaireSlab,
      "weight": weight,
      "pcs": pcs,
      "isnew": isNew,
      "classify": classify,
      "description": description,
      "price": price,
      "laying_with": layingWith,
      "shape": shape,
      "color": color,
      "clarity": clarity,
      "image_url": imageUrl,
      "laying_with": laying_with, // new customer code
      "lying_with_id": lying_with_id, // new customer id
      "lying_with_name": lying_with_name, // new customer name
      "lying_with_nickname": lying_with_nickname, // new customer branch
    };
  }
}

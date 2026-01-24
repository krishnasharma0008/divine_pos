// lib/features/jewellery/data/models/jewellery_price_model.dart
class JewelleryPrice {
  final double price;
  final String message;

  JewelleryPrice({required this.price, required this.message});

  factory JewelleryPrice.fromJson(Map<String, dynamic> json) {
    return JewelleryPrice(
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? 'Failed',
    );
  }

  Map<String, dynamic> toJson() => {'price': price, 'message': message};
}

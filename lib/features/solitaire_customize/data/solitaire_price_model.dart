// lib/features/jewellery/data/models/jewellery_price_model.dart
class SolitairePrice {
  final double price;
  final String message;

  SolitairePrice({required this.price, required this.message});

  factory SolitairePrice.fromJson(Map<String, dynamic> json) {
    return SolitairePrice(
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? 'Failed',
    );
  }

  Map<String, dynamic> toJson() => {'price': price, 'message': message};
}

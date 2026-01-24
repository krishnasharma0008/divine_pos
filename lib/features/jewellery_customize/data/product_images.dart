class ProductImage {
  final String color;
  final List<String> imageUrls;

  ProductImage({required this.color, required this.imageUrls});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      color: json['color']?.toString() ?? '',
      imageUrls: (json['image_url'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'image_url': imageUrls};
  }

  ProductImage copyWith({String? color, List<String>? imageUrls}) {
    return ProductImage(
      color: color ?? this.color,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  @override
  String toString() => 'ProductImage(color: $color, imageUrls: $imageUrls)';
}

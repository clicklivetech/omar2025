import 'package:omarmarket/models/product.dart';

class FavoriteItem {
  final String id;
  final String userId;
  final Product product;
  final DateTime createdAt;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.createdAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': product.id,
        'created_at': createdAt.toIso8601String(),
      };
}

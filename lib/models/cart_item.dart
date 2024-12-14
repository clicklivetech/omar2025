import 'package:omarmarket/models/product.dart';

class CartItem {
  final String id;
  final String userId;
  final Product product;
  int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_id': product.id,
        'quantity': quantity,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  double get totalPrice => product.discountPrice != null
      ? product.discountPrice! * quantity
      : product.price * quantity;
}

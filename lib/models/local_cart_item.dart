import '../models/product.dart';

class LocalCartItem {
  final Product product;
  int quantity;

  LocalCartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory LocalCartItem.fromJson(Map<String, dynamic> json) {
    return LocalCartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

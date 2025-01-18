import 'package:hive/hive.dart';
import 'product.dart';

part 'local_cart_item.g.dart';

@HiveType(typeId: 1)
class LocalCartItem {
  @HiveField(0)
  final Product product;
  
  @HiveField(1)
  int quantity;

  LocalCartItem({
    required this.product,
    required this.quantity,
  });

  factory LocalCartItem.fromJson(Map<String, dynamic> json) {
    return LocalCartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

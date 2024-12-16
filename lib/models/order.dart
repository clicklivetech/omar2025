import 'address.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final Address deliveryAddress;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      deliveryAddress: Address.fromJson(json['deliveryAddress']),
      paymentMethod: json['paymentMethod'],
      subtotal: json['subtotal'],
      deliveryFee: json['deliveryFee'],
      total: json['total'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CartItem {
  final String productId;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  factory CartItem.fromCartItem(dynamic item) {
    return CartItem(
      productId: item.product.id,
      quantity: item.quantity,
      price: item.product.price,
    );
  }
}

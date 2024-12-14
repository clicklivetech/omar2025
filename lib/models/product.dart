import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final int stockQuantity;
  final String? imageUrl;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? unit;
  final Map<String, dynamic>? category;
  int? cartQuantity; // Added for cart functionality

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    required this.stockQuantity,
    this.imageUrl,
    required this.isFeatured,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.unit,
    this.category,
    this.cartQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        discountPrice: json['discount_price'] != null 
            ? (json['discount_price'] as num).toDouble() 
            : null,
        categoryId: json['category_id'].toString(),
        stockQuantity: json['stock_quantity'] ?? 0,
        imageUrl: json['image_url'],
        isFeatured: json['is_featured'] ?? false,
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        unit: json['unit'],
        category: json['categories'],
      );
    } catch (e) {
      debugPrint('Error parsing product: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unit': unit,
      'categories': category,
    };
  }
}

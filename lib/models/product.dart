import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final double? discountPrice;
  
  @HiveField(5)
  final String categoryId;
  
  @HiveField(6)
  final int stockQuantity;
  
  @HiveField(7)
  final String? imageUrl;
  
  @HiveField(8)
  final bool isFeatured;
  
  @HiveField(9)
  final bool isActive;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final DateTime updatedAt;
  
  @HiveField(12)
  final String? unit;
  
  @HiveField(13)
  final Map<String, dynamic>? category;
  
  @HiveField(14)
  int? cartQuantity;

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

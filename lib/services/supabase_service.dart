import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart'; // Added import statement for Product model
import '../models/favorite_item.dart'; // Import statement for FavoriteItem model
import '../models/cart_item.dart'; // Import statement for CartItem model

class SupabaseService {
  static const String supabaseUrl = 'https://vvjgjuvcbqnrzbjkcloa.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2amdqdXZjYnFucnpiamtjbG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMjM0MjMsImV4cCI6MjA0ODY5OTQyM30.dAu01n_o4KOZ9L8W42U8Qd6XER4bH2SuXzwWZt09t7Q';

  static Future<void> initialize() async {
    try {
      debugPrint('Initializing Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<bool> signUp({
    required String email,
    required String password,
    required String phone,
    required String name,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'phone': phone,
          'name': name,
          'email': email,
        },
      );

      if (response.user != null) {
        await createProfile(
          userId: response.user!.id,
          name: name,
          email: email,
          phone: phone,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing up: $e');
      if (e.toString().contains('User already registered')) {
        throw Exception('البريد الإلكتروني مسجل مسبقاً');
      }
      rethrow;
    }
  }

  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.session != null;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating profile: $e');
      rethrow;
    }
  }

  static Future<List<Category>> getHomeCategories() async {
    try {
      debugPrint('Fetching categories from Supabase...');
      final response = await client
          .from('categories')
          .select()
          .order('created_at');  // Removed is_home filter temporarily for testing
      
      debugPrint('Response from Supabase: $response');
      
      if (response == null) {
        debugPrint('Response is null');
        return [];
      }
      
      final categories = (response as List)
          .map((category) => Category.fromJson(category))
          .toList();
          
      debugPrint('Parsed ${categories.length} categories');
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      debugPrint('Fetching featured products from Supabase...');
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('created_at');
      
      debugPrint('Featured products response: $response');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      debugPrint('Fetching products for category: $categoryId');
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .eq('category_id', categoryId)
          .eq('is_active', true)  // Only get active products
          .order('created_at', ascending: false);

      if (response == null) {
        debugPrint('No products found for category: $categoryId');
        return [];
      }

      debugPrint('Found ${(response as List).length} products');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  static Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      return (response as List).map((product) => Product.fromJson(product)).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await client
          .from('categories')
          .select()
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getProductsByCategoryNew(String categoryId) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      debugPrint('Searching products with query: $query');
      final response = await client
          .from('products')
          .select('*, categories(*)')
          .eq('is_active', true)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      if (response == null) {
        debugPrint('No products found for query: $query');
        return [];
      }

      debugPrint('Found ${(response as List).length} products');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching products: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Favorites methods
  static Future<List<FavoriteItem>> getFavorites(String userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('*, product:products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => FavoriteItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  static Future<void> addToFavorites(String userId, String productId) async {
    await client.from('favorites').insert({
      'user_id': userId,
      'product_id': productId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeFromFavorites(String favoriteId) async {
    await client.from('favorites').delete().eq('id', favoriteId);
  }

  static Future<FavoriteItem?> getFavoriteByProductId(String userId, String productId) async {
    try {
      final response = await client
          .from('favorites')
          .select('*, product:products(*)')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .single();

      return response != null ? FavoriteItem.fromJson(response) : null;
    } catch (e) {
      debugPrint('Error getting favorite by product ID: $e');
      return null;
    }
  }

  // Cart methods
  static Future<List<CartItem>> getCart(String userId) async {
    try {
      final response = await client
          .from('cart')
          .select('*, product:products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting cart: $e');
      return [];
    }
  }

  static Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      // Check if the product already exists in the user's cart
      final existing = await client
          .from('cart')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // If product exists, update the quantity
        final newQuantity = (existing['quantity'] as int) + quantity;
        await client.from('cart').update({
          'quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        // If product doesn't exist, insert new item
        await client.from('cart').insert({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  static Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    await client.from('cart').update({
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', cartItemId);
  }

  static Future<void> removeFromCart(String cartItemId) async {
    await client.from('cart').delete().eq('id', cartItemId);
  }

  // Order Methods
  static Future<void> createOrder(
    String userId,
    List<Map<String, dynamic>> items,
    double totalAmount,
  ) async {
    final orderData = {
      'user_id': userId,
      'total_amount': totalAmount,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    // Create order
    final orderResponse = await client
        .from('orders')
        .insert(orderData)
        .select('id')
        .single();

    // Create order items
    final orderItems = items.map((item) => {
      ...item,
      'order_id': orderResponse['id'],
      'created_at': DateTime.now().toIso8601String(),
    }).toList();

    await client.from('order_items').insert(orderItems);
  }

  static Future<void> clearCart(String userId) async {
    await client.from('cart').delete().eq('user_id', userId);
  }
}

import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/local_cart_item.dart';

class LocalStorageService {
  static const String _favoritesBox = 'favorites';
  static const String _cartBox = 'cart';
  
  // Add StreamController for favorites
  static final _favoritesStreamController = StreamController<List<Product>>.broadcast();
  static Stream<List<Product>> get favoritesStream => _favoritesStreamController.stream;

  // Add StreamController for cart
  static final _cartStreamController = StreamController<List<LocalCartItem>>.broadcast();
  static Stream<List<LocalCartItem>> get cartStream => _cartStreamController.stream;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocalCartItemAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Product>(_favoritesBox);
    await Hive.openBox<LocalCartItem>(_cartBox);
  }

  // Cart Methods
  static Future<List<LocalCartItem>> getCart() async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    return box.values.toList();
  }

  static Future<void> addToCart(Product product, [int quantity = 1]) async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    final existingItem = box.values.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => LocalCartItem(product: product, quantity: 0),
    );
    
    if (existingItem.quantity > 0) {
      // Update existing item
      existingItem.quantity = quantity;
      await box.put(product.id, existingItem);
    } else {
      // Add new item
      await box.put(product.id, LocalCartItem(product: product, quantity: quantity));
    }
    
    // Notify listeners
    _cartStreamController.add(box.values.toList());
  }

  static Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    final item = box.get(productId);
    
    if (item != null) {
      item.quantity = quantity;
      await box.put(productId, item);
      // Notify listeners
      _cartStreamController.add(box.values.toList());
    }
  }

  static Future<void> removeFromCart(String productId) async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    await box.delete(productId);
    // Notify listeners
    _cartStreamController.add(box.values.toList());
  }

  static Future<void> clearCart() async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    await box.clear();
    // Notify listeners
    _cartStreamController.add([]);
  }

  // Favorites Methods
  static Future<List<Product>> getFavorites() async {
    final box = Hive.box<Product>(_favoritesBox);
    return box.values.toList();
  }

  static Future<void> addToFavorites(Product product) async {
    final box = Hive.box<Product>(_favoritesBox);
    await box.put(product.id, product);
    // Notify listeners
    _favoritesStreamController.add(box.values.toList());
  }

  static Future<void> removeFromFavorites(String productId) async {
    final box = Hive.box<Product>(_favoritesBox);
    await box.delete(productId);
    // Notify listeners
    _favoritesStreamController.add(box.values.toList());
  }

  static Future<bool> isFavorite(String productId) async {
    final box = Hive.box<Product>(_favoritesBox);
    return box.containsKey(productId);
  }

  static Future<void> clearFavorites() async {
    final box = Hive.box<Product>(_favoritesBox);
    await box.clear();
    // Notify listeners
    _favoritesStreamController.add([]);
  }

  // Get cart items count
  static Future<int> getCartItemsCount() async {
    final box = Hive.box<LocalCartItem>(_cartBox);
    return box.length;
  }

  // Get just the IDs of favorite products
  static Future<List<String>> getFavoriteIds() async {
    final box = Hive.box<Product>(_favoritesBox);
    return box.values.map((product) => product.id).toList();
  }
}

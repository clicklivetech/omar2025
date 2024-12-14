import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/local_cart_item.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorites';
  static const String _cartKey = 'local_cart';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Cart Methods
  static Future<List<LocalCartItem>> getCart() async {
    if (_prefs == null) await init();
    
    final String? cartJson = _prefs?.getString(_cartKey);
    if (cartJson == null) return [];

    final List<dynamic> cartList = json.decode(cartJson);
    return cartList.map((json) => LocalCartItem.fromJson(json)).toList();
  }

  static Future<void> addToCart(Product product, [int quantity = 1]) async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    final existingItemIndex = cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      // Update existing item quantity
      cart[existingItemIndex].quantity += quantity;
    } else {
      // Add new item with specified quantity
      cart.add(LocalCartItem(product: product, quantity: quantity));
    }
    
    final String cartJson = json.encode(cart.map((item) => item.toJson()).toList());
    await _prefs?.setString(_cartKey, cartJson);
  }

  static Future<void> updateCartItemQuantity(String productId, int quantity) async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    final itemIndex = cart.indexWhere((item) => item.product.id == productId);
    
    if (itemIndex != -1) {
      cart[itemIndex].quantity = quantity;
      final String cartJson = json.encode(cart.map((item) => item.toJson()).toList());
      await _prefs?.setString(_cartKey, cartJson);
    }
  }

  static Future<void> removeFromCart(String productId) async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    cart.removeWhere((item) => item.product.id == productId);
    final String cartJson = json.encode(cart.map((item) => item.toJson()).toList());
    await _prefs?.setString(_cartKey, cartJson);
  }

  static Future<void> clearCart() async {
    if (_prefs == null) await init();
    
    await _prefs?.remove(_cartKey);
  }

  // Get cart items count
  static Future<int> getCartItemsCount() async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    return cart.length;
  }

  // Get list of favorite products
  static Future<List<Product>> getFavorites() async {
    if (_prefs == null) await init();
    
    final String? favoritesJson = _prefs?.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.map((json) => Product.fromJson(json)).toList();
  }

  // Add product to favorites
  static Future<void> addToFavorites(Product product) async {
    if (_prefs == null) await init();
    
    final List<Product> favorites = await getFavorites();
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product);
      await _saveFavorites(favorites);
    }
  }

  // Remove product from favorites
  static Future<void> removeFromFavorites(String productId) async {
    if (_prefs == null) await init();
    
    final List<Product> favorites = await getFavorites();
    favorites.removeWhere((p) => p.id == productId);
    await _saveFavorites(favorites);
  }

  // Check if a product is in favorites
  static Future<bool> isProductFavorite(String productId) async {
    if (_prefs == null) await init();
    
    final List<Product> favorites = await getFavorites();
    return favorites.any((p) => p.id == productId);
  }

  // Save favorites list to SharedPreferences
  static Future<void> _saveFavorites(List<Product> favorites) async {
    if (_prefs == null) await init();
    
    final String favoritesJson = json.encode(
      favorites.map((product) => product.toJson()).toList(),
    );
    await _prefs?.setString(_favoritesKey, favoritesJson);
  }

  // Clear favorites
  static Future<void> clearFavorites() async {
    if (_prefs == null) await init();
    await _prefs?.remove(_favoritesKey);
  }
}

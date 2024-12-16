import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/local_cart_item.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorites';
  static const String _cartKey = 'local_cart';
  static SharedPreferences? _prefs;

  // Add StreamController for favorites
  static final _favoritesStreamController = StreamController<List<Product>>.broadcast();
  static Stream<List<Product>> get favoritesStream => _favoritesStreamController.stream;

  // Add StreamController for cart
  static final _cartStreamController = StreamController<List<LocalCartItem>>.broadcast();
  static Stream<List<LocalCartItem>> get cartStream => _cartStreamController.stream;

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
      // Replace existing item quantity instead of adding to it
      cart[existingItemIndex].quantity = quantity;
    } else {
      // Add new item with specified quantity
      cart.add(LocalCartItem(product: product, quantity: quantity));
    }
    
    await _saveCart(cart);
    // Notify listeners about the change
    _cartStreamController.add(cart);
  }

  static Future<void> updateCartItemQuantity(String productId, int quantity) async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    final itemIndex = cart.indexWhere((item) => item.product.id == productId);
    
    if (itemIndex != -1) {
      cart[itemIndex].quantity = quantity;
      await _saveCart(cart);
      // Notify listeners about the change
      _cartStreamController.add(cart);
    }
  }

  static Future<void> removeFromCart(String productId) async {
    if (_prefs == null) await init();
    
    final List<LocalCartItem> cart = await getCart();
    cart.removeWhere((item) => item.product.id == productId);
    await _saveCart(cart);
    // Notify listeners about the change
    _cartStreamController.add(cart);
  }

  static Future<void> clearCart() async {
    if (_prefs == null) await init();
    await _prefs?.remove(_cartKey);
    // Notify listeners about the change
    _cartStreamController.add([]);
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

  // Get just the IDs of favorite products
  static Future<List<String>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((product) => product.id).toList();
  }

  // Get favorites count
  static Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  // Add product to favorites
  static Future<void> addToFavorites(Product product) async {
    if (_prefs == null) await init();
    
    final List<Product> favorites = await getFavorites();
    if (!favorites.any((p) => p.id == product.id)) {
      favorites.add(product);
      await _saveFavorites(favorites);
      // Notify listeners about the change
      _favoritesStreamController.add(favorites);
    }
  }

  // Remove product from favorites
  static Future<void> removeFromFavorites(String productId) async {
    if (_prefs == null) await init();
    
    final List<Product> favorites = await getFavorites();
    favorites.removeWhere((p) => p.id == productId);
    await _saveFavorites(favorites);
    // Notify listeners about the change
    _favoritesStreamController.add(favorites);
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

  // Save cart list to SharedPreferences
  static Future<void> _saveCart(List<LocalCartItem> cart) async {
    if (_prefs == null) await init();
    
    final String cartJson = json.encode(cart.map((item) => item.toJson()).toList());
    await _prefs?.setString(_cartKey, cartJson);
  }

  // Clear favorites
  static Future<void> clearFavorites() async {
    if (_prefs == null) await init();
    await _prefs?.remove(_favoritesKey);
    // Notify listeners about the change
    _favoritesStreamController.add([]);
  }
}

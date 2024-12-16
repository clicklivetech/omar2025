import 'package:flutter/material.dart';
import 'dart:async';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  final Map<String, bool> _favoriteStatus = {};
  int _cartItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCartCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await LocalStorageService.getFavorites();
      if (mounted) {
        setState(() {
          for (var product in favorites) {
            _favoriteStatus[product.id] = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await SupabaseService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء البحث: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final isFavorite = _favoriteStatus[product.id] ?? false;
      if (isFavorite) {
        await LocalStorageService.removeFromFavorites(product.id);
        setState(() {
          _favoriteStatus[product.id] = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تمت الإزالة من المفضلة')),
        );
      } else {
        await LocalStorageService.addToFavorites(product);
        setState(() {
          _favoriteStatus[product.id] = true;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحديث المفضلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (_cartItemsCount > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      _cartItemsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن المنتجات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          'ابدأ البحث عن المنتجات...',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final productData = _searchResults[index];
                          final product = Product.fromJson(productData);
                          
                          return ProductCard(
                            product: product,
                            isFavorite: _favoriteStatus[product.id] ?? false,
                            onFavoritePressed: () => _toggleFavorite(product),
                            onAddToCartPressed: () async {
                              if (!mounted) return;
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              try {
                                await LocalStorageService.addToCart(product, 1);
                                await _loadCartCount();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('حدث خطأ أثناء الإضافة إلى السلة')),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCartCount() async {
    try {
      final count = await LocalStorageService.getCartItemsCount();
      if (mounted) {
        setState(() {
          _cartItemsCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }
}

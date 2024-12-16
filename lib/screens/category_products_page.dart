import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/product_card.dart';

class CategoryProductsPage extends StatefulWidget {
  final Category category;

  const CategoryProductsPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  bool _isLoading = true;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _favoriteIds = [];
  int _cartItemsCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
      return;
    }

    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final productsData = await SupabaseService.getProductsByCategory(widget.category.id);
      final products = productsData
          .map((data) => Product.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      
      final favorites = await LocalStorageService.getFavorites();
      final favoriteIds = favorites.map((f) => f.id).toList();
      
      final cartItemsCount = await LocalStorageService.getCartItemsCount();
      
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _favoriteIds = favoriteIds;
          _cartItemsCount = cartItemsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل المنتجات')),
        );
      }
    }
  }

  Future<void> _updateCartCount() async {
    try {
      final cartItemsCount = await LocalStorageService.getCartItemsCount();
      if (mounted) {
        setState(() {
          _cartItemsCount = cartItemsCount;
        });
      }
    } catch (e) {
      debugPrint('Error updating cart count: $e');
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      final isFavorite = _favoriteIds.contains(product.id);
      if (isFavorite) {
        await LocalStorageService.removeFromFavorites(product.id);
        if (mounted) {
          setState(() {
            _favoriteIds.remove(product.id);
          });
        }
      } else {
        await LocalStorageService.addToFavorites(product);
        if (mounted) {
          setState(() {
            _favoriteIds.add(product.id);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحديث المفضلة')),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      await LocalStorageService.addToCart(product, product.cartQuantity ?? 1);
      await _updateCartCount(); // Reload to update cart count
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Custom top bar with search
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
              left: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          onPressed: () => Navigator.pushNamed(context, '/cart_page')
                              .then((_) => _updateCartCount()),
                        ),
                        if (_cartItemsCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
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
                ),
                // Search bar
                Container(
                  margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterProducts('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterProducts,
                  ),
                ),
              ],
            ),
          ),
          // Products grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'لا توجد منتجات في هذه الفئة'
                                  : 'لا توجد نتائج للبحث',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width < 600 ? 2 : 3,
                            childAspectRatio:
                                MediaQuery.of(context).size.width < 360 ? 0.6 : 0.65,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final isFavorite = _favoriteIds.contains(product.id);
                            return ProductCard(
                              product: product,
                              isFavorite: isFavorite,
                              onFavoritePressed: () => _toggleFavorite(product),
                              onAddToCartPressed: () => _addToCart(product),
                              onQuantityChanged: (quantity) {
                                product.cartQuantity = quantity;
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

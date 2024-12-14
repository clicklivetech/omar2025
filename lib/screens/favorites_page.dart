import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with WidgetsBindingObserver, RouteAware {
  bool _isLoading = true;
  List<Product> _favorites = [];
  int _cartItemsCount = 0;
  final _routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    _loadFavorites();
    _loadCartCount();
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
      // Handle error silently
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await LocalStorageService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل المفضلة')),
        );
      }
    }
  }

  Future<void> _removeFavorite(Product product) async {
    try {
      await LocalStorageService.removeFromFavorites(product.id);
      if (mounted) {
        setState(() {
          _favorites.removeWhere((p) => p.id == product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة المنتج من المفضلة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إزالة المنتج من المفضلة')),
        );
      }
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      await LocalStorageService.addToCart(product, product.cartQuantity ?? 1);
      await _loadCartCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إضافة المنتج إلى السلة')),
        );
      }
    }
  }

  Future<void> _showClearFavoritesDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المفضلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await LocalStorageService.clearFavorites();
        setState(() {
          _favorites.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم مسح المفضلة')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء مسح المفضلة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text('المفضلة'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.white,
              onPressed: () => _showClearFavoritesDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favorites.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: Stack(
                          children: [
                            ListView(),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد منتجات في المفضلة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'يمكنك إضافة المنتجات للمفضلة\nمن خلال الضغط على أيقونة القلب',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('تصفح المنتجات'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width < 600 ? 2 : 3,
                            childAspectRatio:
                                MediaQuery.of(context).size.width < 360
                                    ? 0.6
                                    : 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final product = _favorites[index];
                            return ProductCard(
                              product: product,
                              isFavorite: true,
                              onFavoritePressed: () {
                                _removeFavorite(product);
                              },
                              onAddToCartPressed: () {
                                _addToCart(product);
                              },
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

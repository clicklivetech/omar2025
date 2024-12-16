import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with WidgetsBindingObserver, RouteAware {
  List<Product> _favorites = [];
  bool _isLoading = true;
  final _routeObserver = RouteObserver<PageRoute>();
  final StreamController<List<Product>> _favoritesController =
      StreamController<List<Product>>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    LocalStorageService.favoritesStream.listen((favorites) {
      if (mounted) {
        _favoritesController.add(favorites);
        setState(() {
          _favorites = favorites;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(this);
    _favoritesController.close();
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
    if (!mounted) return;
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    try {
      final favorites = await LocalStorageService.getFavorites();
      if (!mounted) return;
      
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحميل المفضلة')),
      );
    }
  }

  Future<void> _removeFavorite(Product product) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await LocalStorageService.removeFromFavorites(product.id);
      if (!mounted) return;
      
      setState(() {
        _favorites.removeWhere((p) => p.id == product.id);
      });
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم إزالة المنتج من المفضلة')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إزالة المنتج من المفضلة')),
      );
    }
  }

  Future<void> _addToCart(Product product) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await LocalStorageService.addToCart(product, product.cartQuantity ?? 1);
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إضافة المنتج إلى السلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'المفضلة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.white,
              onPressed: _showClearFavoritesDialog,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _favorites.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد منتجات في المفضلة',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final product = _favorites[index];
                      return ProductCard(
                        product: product,
                        isFavorite: true,
                        onFavoritePressed: () => _removeFavorite(product),
                        onAddToCartPressed: () => _addToCart(product),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _showClearFavoritesDialog() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد المسح'),
          content: const Text('هل أنت متأكد من مسح قائمة المفضلة؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      try {
        await LocalStorageService.clearFavorites();
        if (!mounted) return;
        
        setState(() {
          _favorites.clear();
        });
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تم مسح المفضلة')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء مسح المفضلة')),
        );
      }
    }
  }
}

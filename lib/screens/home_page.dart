import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/product_card.dart';
import './category_products_page.dart';
import './search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  final List<String> carouselImages = [
    'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000',
    'https://images.unsplash.com/photo-1573246123716-6b1782bfc499?q=80&w=1000',
    'https://images.unsplash.com/photo-1610348725531-843dff563e2c?q=80&w=1000',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint('Starting to load data...');
      
      debugPrint('Fetching categories...');
      final categories = await SupabaseService.getHomeCategories();
      debugPrint('Found ${categories.length} categories');
      
      debugPrint('Fetching featured products...');
      final featuredProductsData = await SupabaseService.getFeaturedProducts();
      debugPrint('Found ${featuredProductsData.length} featured products');
      
      final featuredProducts = featuredProductsData
          .map((product) => Product.fromJson(product))
          .toList();
      debugPrint('Parsed ${featuredProducts.length} featured products');

      if (mounted) {
        setState(() {
          _categories = categories;
          _featuredProducts = featuredProducts;
          _isLoading = false;
        });

        if (categories.isEmpty) {
          debugPrint('No categories found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم العثور على تصنيفات'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          debugPrint('Categories loaded: ${categories.map((c) => c.name).join(', ')}');
        }

        if (featuredProducts.isEmpty) {
          debugPrint('No featured products found');
        } else {
          debugPrint('Featured products loaded: ${featuredProducts.map((p) => p.name).join(', ')}');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل البيانات: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              elevation: 0,
              leading: Container(),
              backgroundColor: theme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchPage()),
                      );
                    },
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'ابحث عن المنتجات...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عمر ماركت',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    _buildCarousel(),
                    const SizedBox(height: 20),
                    _buildCategories(),
                    const SizedBox(height: 20),
                    _buildFeaturedProducts(),
                    const SizedBox(height: 20),
                    _buildDeals(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16/9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: carouselImages.map((image) {
        return Container(
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: CachedNetworkImageProvider(image),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'التصنيفات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsPage(category: category),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A14AD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: category.imageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  category.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.category,
                                color: Color(0xFF7A14AD),
                                size: 40,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'منتجات مميزة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featuredProducts.length,
            itemBuilder: (context, index) {
              final product = _featuredProducts[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.only(left: 16),
                child: ProductCard(
                  product: product,
                  isFavorite: false,
                  onFavoritePressed: () async {
                    final userId = SupabaseService.client.auth.currentUser?.id;
                    if (userId != null) {
                      await SupabaseService.addToFavorites(userId, product.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
                      );
                    }
                  },
                  onAddToCartPressed: () async {
                    final userId = SupabaseService.client.auth.currentUser?.id;
                    if (userId != null) {
                      await SupabaseService.addToCart(userId, product.id, product.cartQuantity ?? 1);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
                      );
                    } else {
                      await LocalStorageService.addToCart(product, product.cartQuantity ?? 1);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
                      );
                    }
                  },
                  onQuantityChanged: (quantity) {
                    product.cartQuantity = quantity;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'عروض مميزة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredProducts.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final product = _featuredProducts[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.only(left: 16),
                child: ProductCard(
                  product: product,
                  isFavorite: false,
                  onFavoritePressed: () async {
                    final userId = SupabaseService.client.auth.currentUser?.id;
                    if (userId != null) {
                      await SupabaseService.addToFavorites(userId, product.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
                      );
                    }
                  },
                  onAddToCartPressed: () async {
                    final userId = SupabaseService.client.auth.currentUser?.id;
                    if (userId != null) {
                      await SupabaseService.addToCart(userId, product.id, product.cartQuantity ?? 1);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
                      );
                    } else {
                      await LocalStorageService.addToCart(product, product.cartQuantity ?? 1);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
                      );
                    }
                  },
                  onQuantityChanged: (quantity) {
                    product.cartQuantity = quantity;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

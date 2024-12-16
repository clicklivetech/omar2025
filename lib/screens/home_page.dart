import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/product_card.dart';
import 'package:logging/logging.dart';
import 'category_products_page.dart';
import 'categories_page.dart';
import 'search_page.dart';
import './product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> categories = [];
  bool isLoading = true;
  List<Product> featuredProducts = [];
  bool isFeaturedLoading = true;
  List<Product> discountedProducts = [];
  bool isDiscountedLoading = true;
  int currentDiscountIndex = 0;
  Timer? discountTimer;
  List<Product> todayDeals = [];
  bool isTodayDealsLoading = true;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  static const int _dealsPageSize = 6;
  int _currentPage = 0;
  bool _hasMoreDeals = true;

  // Sample featured products
  final List<Map<String, dynamic>> featuredProductsCarousel = [
    {
      'image': 'assets/images/offers/fresh_vegetables.jpg',
      'title': 'خصم 20% على الخضروات الطازجة',
      'subtitle': 'تسوق الآن واحصل على أفضل المنتجات الطازجة',
      'backgroundColor': const Color(0xFF4CAF50),
    },
    {
      'image': 'assets/images/offers/dairy_products.jpg',
      'title': 'عروض الألبان ومنتجات الأجبان',
      'subtitle': 'خصومات تصل إلى 30%',
      'backgroundColor': const Color(0xFF2196F3),
    },
    {
      'image': 'assets/images/offers/meat_fresh.jpg',
      'title': 'اللحوم الطازجة',
      'subtitle': 'جودة عالية بأسعار مميزة',
      'backgroundColor': const Color(0xFFE91E63),
    },
  ];

  // Sample products
  final List<Product> products = [
    Product(
      id: '1',
      name: 'هاتف ذكي',
      price: 999.99,
      categoryId: '1',
      stockQuantity: 50,
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: 'https://picsum.photos/200/200',
      description: 'هاتف ذكي بمواصفات عالية',
      discountPrice: 899.99,
    ),
    Product(
      id: '2',
      name: 'سماعات لاسلكية',
      price: 199.99,
      categoryId: '1',
      stockQuantity: 100,
      isFeatured: true,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: 'https://picsum.photos/200/201',
      description: 'سماعات بلوتوث عالية الجودة',
    ),
    // Add more sample products here
  ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchFeaturedProducts();
    fetchDiscountedProducts();
    fetchTodayDeals();
    startDiscountTimer();
    _setupScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    discountTimer?.cancel();
    super.dispose();
  }

  void startDiscountTimer() {
    discountTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && discountedProducts.isNotEmpty) {
        setState(() {
          currentDiscountIndex = (currentDiscountIndex + 1) % discountedProducts.length;
        });
      }
    });
  }

  int calculateDiscount(Product product) {
    if (product.discountPrice == null || product.price == 0) return 0;
    return (((product.price - product.discountPrice!) / product.price) * 100).round();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
          !isLoadingMore &&
          _hasMoreDeals) {
        _loadMoreDeals();
      }
    });
  }

  Future<void> _loadMoreDeals() async {
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .not('discount_price', 'is', null)
          .order('created_at', ascending: false)
          .range(_currentPage * _dealsPageSize, (_currentPage + 1) * _dealsPageSize - 1);

      final newDeals = (response as List<dynamic>)
          .map((product) => Product.fromJson(product))
          .toList();

      if (mounted) {
        setState(() {
          todayDeals.addAll(newDeals);
          _currentPage++;
          _hasMoreDeals = newDeals.length == _dealsPageSize;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more deals: $e');
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await SupabaseService.client
          .from('categories')
          .select()
          .eq('is_home', true)
          .order('created_at');

      setState(() {
        categories = (response as List<dynamic>)
            .map((category) => Category.fromJson(category))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      Logger('HomePage').warning('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await SupabaseService.getFeaturedProducts();
      setState(() {
        featuredProducts = response
            .map((data) => Product.fromJson(Map<String, dynamic>.from(data)))
            .toList();
        isFeaturedLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      setState(() {
        isFeaturedLoading = false;
      });
    }
  }

  Future<void> fetchDiscountedProducts() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .not('discount_price', 'is', null)
          .order('discount_price', ascending: true)
          .limit(5);

      if (mounted) {
        setState(() {
          discountedProducts = (response as List<dynamic>)
              .map((product) => Product.fromJson(product))
              .toList();
          isDiscountedLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching discounted products: $e');
      if (mounted) {
        setState(() {
          isDiscountedLoading = false;
        });
      }
    }
  }

  Future<void> fetchTodayDeals() async {
    try {
      final response = await SupabaseService.client
          .from('products')
          .select()
          .not('discount_price', 'is', null)
          .order('created_at', ascending: false)
          .limit(_dealsPageSize);

      if (mounted) {
        setState(() {
          todayDeals = (response as List<dynamic>)
              .map((product) => Product.fromJson(product))
              .toList();
          isTodayDealsLoading = false;
          _currentPage = 1;
          _hasMoreDeals = todayDeals.length == _dealsPageSize;
        });
      }
    } catch (e) {
      debugPrint('Error fetching today deals: $e');
      if (mounted) {
        setState(() {
          isTodayDealsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Spacer(),
                      Text(
                        'عمر ماركت',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ابحث عن منتجات...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Discounted Products Banner
            if (!isDiscountedLoading && discountedProducts.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        product: discountedProducts.first,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.5),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            key: ValueKey<int>(currentDiscountIndex),
                            '${discountedProducts[currentDiscountIndex].name} - خصم ${calculateDiscount(discountedProducts[currentDiscountIndex])}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),

            // Featured Products Carousel
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                height: 200,
                child: FlutterCarousel(
                  options: CarouselOptions(
                    height: 200,
                    showIndicator: true,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    autoPlayCurve: Curves.easeInOutCubic,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 0.92,
                  ),
                  items: featuredProductsCarousel.map((product) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  product['image'],
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        (product['backgroundColor'] as Color).withOpacity(0.9),
                                        (product['backgroundColor'] as Color).withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        product['subtitle'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            // Categories Section
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'التصنيفات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoriesPage(),
                              ),
                            );
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryProductsPage(
                                  category: category,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: category.imageUrl != null
                                        ? Image.network(
                                            category.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.category_outlined,
                                                size: 40,
                                                color: Colors.grey,
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.category_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            // Featured Products Section
            if (isFeaturedLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (featuredProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'المنتجات المميزة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = featuredProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 16.0),
                          width: 200,
                          child: ProductCard(
                            product: product,
                            isFavorite: false,
                            onAddToCartPressed: () async {
                              try {
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                await LocalStorageService.addToCart(product, 1);
                                if (!context.mounted) return;
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إضافة المنتج إلى السلة'),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('حدث خطأ أثناء الإضافة إلى السلة'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            // Today's Deals Section
            if (!isTodayDealsLoading && todayDeals.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'عروض اليوم',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'خصم حتى ${todayDeals.map((p) => calculateDiscount(p)).reduce((a, b) => a > b ? a : b)}%',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: todayDeals.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == todayDeals.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final product = todayDeals[index];
                              return ProductCard(
                                product: product,
                                isFavorite: false,
                                onAddToCartPressed: () async {
                                  try {
                                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                                    await LocalStorageService.addToCart(product, 1);
                                    if (!context.mounted) return;
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('تم إضافة المنتج إلى السلة'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('حدث خطأ أثناء الإضافة إلى السلة'),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          if (!_hasMoreDeals && todayDeals.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'لا توجد المزيد من العروض',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
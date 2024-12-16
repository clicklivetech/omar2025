import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'categories_page.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'home_page.dart';
import '../services/local_storage_service.dart';
import 'dart:async';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _cartItemCount = 0;
  StreamSubscription? _cartSubscription;
  
  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const FavoritesPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
    _setupCartListener();
  }

  Future<void> _loadCartItemCount() async {
    final count = await LocalStorageService.getCartItemsCount();
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  void _setupCartListener() {
    _cartSubscription = LocalStorageService.cartStream.listen((cart) {
      if (mounted) {
        setState(() {
          _cartItemCount = cart.fold(0, (sum, item) => sum + item.quantity);
        });
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        cartItemCount: _cartItemCount,
      ),
    );
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCartItemCount();
  }
}

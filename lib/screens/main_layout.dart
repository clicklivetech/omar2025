import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'categories_page.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../services/local_storage_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _cartItemCount = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const CartPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
  }

  Future<void> _loadCartItemCount() async {
    final count = await LocalStorageService.getCartItemsCount();
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCartItemCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        cartItemCount: _cartItemCount,
      ),
    );
  }
}

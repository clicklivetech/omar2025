import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'categories_page.dart';
import 'home_page.dart';
import '../services/supabase_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const FavoritesPage(),
    const CartPage(),
  ];

  void _onItemTapped(int index) {
    final currentUser = SupabaseService.client.auth.currentUser;
    if (currentUser == null && index == 2) {
      // Only require login for favorites
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SupabaseService.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عمر ماركت'),
        actions: [
          if (currentUser == null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                await SupabaseService.signOut();
                setState(() {});
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'الأقسام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/cart_item.dart' as models;
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';
import 'delivery_address_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  bool _isLoading = true;
  List<models.CartItem> _cartItems = [];
  double _totalPrice = 0;
  final double _deliveryFee = 10.0; // Fixed delivery fee

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatusAndLoadCart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLoginStatusAndLoadCart() async {
    await AuthService.checkLoginStatus(); // تحديث حالة تسجيل الدخول
    await _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final items = await LocalStorageService.getCart();
      
      // Convert LocalCartItem to CartItem
      final cartItems = items.map((item) => models.CartItem(
        id: item.product.id.toString(),
        userId: AuthService.currentUserId ?? '',
        product: item.product,
        quantity: item.quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();

      if (!mounted) return;

      setState(() {
        _cartItems = cartItems;
        _calculateTotal();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.totalPrice;
    }
    _totalPrice = total;
  }

  Future<void> _updateQuantity(models.CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      await LocalStorageService.updateCartItemQuantity(item.product.id, newQuantity);
      if (!mounted) return;
      setState(() {
        item.quantity = newQuantity;
        _calculateTotal();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> _removeFromCart(models.CartItem item) async {
    try {
      await LocalStorageService.removeFromCart(item.product.id);
      if (!mounted) return;
      setState(() {
        _cartItems.removeWhere((cartItem) => cartItem.product.id == item.product.id);
        _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إزالة المنتج من السلة')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> _navigateToDeliveryAddress() async {
    if (!mounted) return;

    // التحقق من حالة تسجيل الدخول
    if (AuthService.currentUserId == null) {
      // عرض رسالة للمستخدم
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('تسجيل الدخول مطلوب'),
            content: const Text('يجب تسجيل الدخول لإكمال عملية الشراء. هل تريد تسجيل الدخول الآن؟'),
            actions: <Widget>[
              TextButton(
                child: const Text('إلغاء'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('تسجيل الدخول'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (shouldLogin == true) {
        if (!mounted) return;
        
        // الانتقال إلى صفحة تسجيل الدخول
        final loginResult = await Navigator.pushNamed(context, '/login');
        
        // التحقق مرة أخرى بعد العودة من صفحة تسجيل الدخول
        if (loginResult == true && mounted && AuthService.currentUserId != null) {
          // المتابعة إلى صفحة العنوان بعد تسجيل الدخول بنجاح
          await _continueToDeliveryAddress();
        }
      }
      return;
    }

    // إذا كان المستخدم مسجل دخول، المتابعة مباشرة إلى صفحة العنوان
    await _continueToDeliveryAddress();
  }

  Future<void> _continueToDeliveryAddress() async {
    if (!mounted) return;
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryAddressPage(
          cartItems: _cartItems,
          subtotal: _totalPrice,
          deliveryFee: _deliveryFee,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCartItems();
    }
  }

  Future<void> _showClearCartDialog() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد'),
          content: const Text('هل أنت متأكد من رغبتك في مسح السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('مسح السلة'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      try {
        await LocalStorageService.clearCart();
        if (!mounted) return;
        setState(() {
          _cartItems.clear();
          _calculateTotal();
        });
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  Widget _buildCartItem(models.CartItem item, ThemeData theme) {
    final price = item.product.price;
    final totalItemPrice = price * item.quantity;

    return Dismissible(
      key: Key(item.product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        _removeFromCart(item);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.product.imageUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price ₪',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _updateQuantity(
                              item, item.quantity - 1),
                          color: theme.primaryColor,
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _updateQuantity(
                              item, item.quantity + 1),
                          color: theme.primaryColor,
                        ),
                        const Spacer(),
                        Text(
                          '$totalItemPrice ₪',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'السلة فارغة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: const Text('تسوق الآن'),
                            ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _cartItems[index];
                                return GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/product-details',
                                    arguments: item.product,
                                  ),
                                  child: _buildCartItem(item, theme),
                                );
                              },
                              childCount: _cartItems.length,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'المجموع:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_totalPrice.toStringAsFixed(2)} ₪',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _cartItems.isEmpty ? null : _navigateToDeliveryAddress,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'متابعة الشراء',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (_cartItems.length > 1)
                                    TextButton(
                                      onPressed: _showClearCartDialog,
                                      child: const Text('مسح السلة'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

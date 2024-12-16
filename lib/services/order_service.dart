import '../models/address.dart';
import '../models/cart_item.dart' as models;
import '../models/order.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class OrderService {
  static Future<Order> createOrder({
    required List<models.CartItem> cartItems,
    required Address deliveryAddress,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
  }) async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      throw Exception('يجب تسجيل الدخول لإتمام الطلب');
    }

    final orderData = {
      'user_id': userId,
      'status': 'pending',
      'total_amount': subtotal + deliveryFee,
      'delivery_fee': deliveryFee,
      'shipping_address': '${deliveryAddress.street}, ${deliveryAddress.building}, ${deliveryAddress.floor}, ${deliveryAddress.city}',
      'phone': deliveryAddress.phone,
      'payment_method': paymentMethod,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      // إنشاء الطلب
      final orderResponse = await SupabaseService.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // تحضير عناصر الطلب
      final orderItems = cartItems.map((item) => {
        'order_id': orderResponse['id'],
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }).toList();

      // إضافة عناصر الطلب
      await SupabaseService.client.from('order_items').insert(orderItems);

      // مسح السلة بعد إتمام الطلب بنجاح
      await LocalStorageService.clearCart();

      // إنشاء كائن Order للواجهة
      final order = Order(
        id: orderResponse['id'],
        items: cartItems.map((item) => CartItem.fromCartItem(item)).toList(),
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: subtotal + deliveryFee,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      return order;
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء الطلب: $e');
    }
  }
}

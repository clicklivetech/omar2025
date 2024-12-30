import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CurrentOrdersPage extends StatefulWidget {
  const CurrentOrdersPage({super.key});

  @override
  State<CurrentOrdersPage> createState() => _CurrentOrdersPageState();
}

class _CurrentOrdersPageState extends State<CurrentOrdersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentOrders();
  }

  Future<void> _loadCurrentOrders() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('orders')
            .select('''
              *,
              order_items(
                id,
                quantity,
                price,
                product_id
              ),
              profiles!user_id(
                full_name,
                phone,
                address
              )
            ''')
            .eq('user_id', user.id)
            .in_('status', ['pending', 'processing', 'shipping'])
            .order('created_at', ascending: false);

        setState(() {
          _orders = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تحميل الطلبات'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      await SupabaseService.client
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);

      await _loadCurrentOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في إلغاء الطلب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'shipping':
        return 'قيد الشحن';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الحالية'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد طلبات حالية',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final orderItems =
                          List<Map<String, dynamic>>.from(order['order_items']);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                'طلب رقم: ${order['id']?.toString() ?? ''}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${order['total_amount']?.toString() ?? '0'} ر.س',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'التاريخ: ${order['created_at'] != null ? DateTime.parse(order['created_at']).toString().split('.')[0] : ''}',
                              ),
                              const SizedBox(height: 4),
                              if (order['shipping_address'] != null) ...[
                                Text(
                                  'العنوان: ${order['shipping_address']}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              if (order['phone'] != null) ...[
                                Text('رقم الهاتف: ${order['phone']}'),
                                const SizedBox(height: 4),
                              ],
                              Row(
                                children: [
                                  const Text('الحالة: '),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status'] as String?)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(order['status'] as String?),
                                      style: TextStyle(
                                        color: _getStatusColor(order['status'] as String?),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'تفاصيل الطلب:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...orderItems.map((item) => Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${item['quantity']}x',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(item['product_name']),
                                            ),
                                            Text(
                                              '${item['price']} ر.س',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'المجموع:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${order['total_amount']} ر.س',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (order['status'] == 'pending')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _cancelOrder(order['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('إلغاء الطلب'),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

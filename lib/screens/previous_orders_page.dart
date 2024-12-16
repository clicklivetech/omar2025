import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PreviousOrdersPage extends StatefulWidget {
  const PreviousOrdersPage({super.key});

  @override
  State<PreviousOrdersPage> createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousOrders();
  }

  Future<void> _loadPreviousOrders() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseService.client
            .from('orders')
            .select('*, order_items(*)')
            .eq('user_id', user.id)
            .in_('status', ['delivered', 'cancelled'])
            .order('created_at', ascending: false);

        if (!mounted) return;
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في تحميل الطلبات'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reorder(Map<String, dynamic> order) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final orderItems = List<Map<String, dynamic>>.from(order['order_items']);
      
      final newOrder = {
        'user_id': user.id,
        'status': 'pending',
        'total_amount': order['total_amount'],
        'shipping_address': order['shipping_address'],
        'payment_method': order['payment_method'],
      };

      final orderResponse = await SupabaseService.client
          .from('orders')
          .insert(newOrder)
          .select()
          .single();

      final newOrderItems = orderItems.map((item) => {
        'order_id': orderResponse['id'],
        'product_id': item['product_id'],
        'product_name': item['product_name'],
        'quantity': item['quantity'],
        'price': item['price'],
      }).toList();

      await SupabaseService.client
          .from('order_items')
          .insert(newOrderItems);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في إعادة الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showRatingDialog(Map<String, dynamic> order) async {
    if (!mounted) return;
    
    double rating = 0;
    String comment = '';
    
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تقييم الطلب', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (_, __) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (value) {
                    rating = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'أضف تعليقاً (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    comment = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating > 0) {
                  Navigator.pop(dialogContext, true);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إضافة تقييم'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (result == true && rating > 0) {
      try {
        final user = SupabaseService.client.auth.currentUser;
        if (user != null) {
          await SupabaseService.client.from('order_ratings').upsert({
            'order_id': order['id'],
            'user_id': user.id,
            'rating': rating,
            'comment': comment,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('شكراً على تقييمك!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في حفظ التقييم'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات السابقة'),
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
                          'لا توجد طلبات سابقة',
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
                          title: Text(
                            'طلب رقم: ${order['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'التاريخ: ${DateTime.parse(order['created_at']).toString().split('.')[0]}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text('الحالة: '),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _getStatusColor(order['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(order['status']),
                                      style: TextStyle(
                                        color: _getStatusColor(order['status']),
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
                                  if (order['status'] == 'delivered')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _reorder(order),
                                              icon: const Icon(Icons.refresh),
                                              label: const Text('إعادة الطلب'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _showRatingDialog(order);
                                              },
                                              icon: const Icon(Icons.star),
                                              label: const Text('تقييم الطلب'),
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
                      );
                    },
                  ),
      ),
    );
  }
}

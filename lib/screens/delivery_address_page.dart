import 'package:flutter/material.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import 'payment_method_page.dart';
import 'add_address_page.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class DeliveryAddressPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;

  const DeliveryAddressPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  List<Address> addresses = [];
  String? selectedAddressId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        setState(() {
          addresses = [];
          isLoading = false;
        });
        return;
      }

      final response = await SupabaseService.client
          .from('addresses')
          .select()
          .eq('user_id', userId);
      
      if (!mounted) return;

      if (response == null) {
        setState(() {
          addresses = [];
          isLoading = false;
        });
        return;
      }

      setState(() {
        addresses = (response as List).map((addr) => Address(
          id: addr['id'].toString(),
          street: addr['street'] ?? '',
          city: addr['city'] ?? '',
          building: addr['building'] ?? '',
          floor: addr['floor'] ?? '',
          landmark: addr['landmark'] ?? '',
          phone: addr['phone'] ?? '',
        )).toList();

        selectedAddressId ??= addresses.firstOrNull?.id;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        addresses = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في تحميل العناوين')),
      );
    }
  }

  void _handleAddressSelection(String? addressId) {
    setState(() {
      selectedAddressId = addressId;
    });
  }

  Future<void> _navigateToAddAddress() async {
    final newAddress = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressPage(),
      ),
    );

    if (newAddress != null) {
      setState(() {
        addresses.add(newAddress);
        selectedAddressId = newAddress.id;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة العنوان بنجاح')),
        );
      }
    }
  }

  Future<void> _navigateToPaymentMethod() async {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار عنوان للتوصيل')),
      );
      return;
    }

    final selectedAddress = addresses.firstWhere(
      (addr) => addr.id == selectedAddressId,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodPage(
            cartItems: widget.cartItems,
            subtotal: widget.subtotal,
            deliveryFee: widget.deliveryFee,
            selectedAddress: selectedAddress,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عنوان التوصيل'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (addresses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAddresses,
              tooltip: 'تحديث العناوين',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا يوجد عناوين محفوظة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAddresses,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return Dismissible(
                                key: Key(address.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('حذف العنوان'),
                                      content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  final currentAddress = addresses[index];
                                  final currentIndex = index;
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  
                                  setState(() {
                                    addresses.removeAt(currentIndex);
                                    if (selectedAddressId == currentAddress.id) {
                                      selectedAddressId = addresses.isNotEmpty ? addresses.first.id : null;
                                    }
                                  });
                                  
                                  try {
                                    final userId = AuthService.currentUserId;
                                    if (userId != null) {
                                      await SupabaseService.client
                                          .from('addresses')
                                          .delete()
                                          .match({
                                            'id': currentAddress.id,
                                            'user_id': userId
                                          });
                                      
                                      if (!mounted) return;
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(content: Text('تم حذف العنوان بنجاح')),
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() {
                                      addresses.insert(currentIndex, currentAddress);
                                      if (selectedAddressId == null) {
                                        selectedAddressId = currentAddress.id;
                                      }
                                    });
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(content: Text('فشل حذف العنوان')),
                                    );
                                  }
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: RadioListTile<String>(
                                    value: address.id,
                                    groupValue: selectedAddressId,
                                    onChanged: _handleAddressSelection,
                                    title: Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            address.street,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${address.city} - ${address.building}'),
                                        if (address.floor.isNotEmpty)
                                          Text('الطابق: ${address.floor}'),
                                        if (address.landmark.isNotEmpty)
                                          Text('علامة مميزة: ${address.landmark}'),
                                        Text(
                                          address.phone,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (addresses.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToAddAddress,
                          icon: const Icon(Icons.add_location),
                          label: const Text('إضافة عنوان جديد'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (addresses.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: selectedAddressId == null
                                ? null
                                : _navigateToPaymentMethod,
                            icon: const Icon(Icons.navigate_next),
                            label: const Text('متابعة للدفع'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

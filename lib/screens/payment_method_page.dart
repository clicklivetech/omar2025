import 'package:flutter/material.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import 'order_review_page.dart';

class PaymentMethodPage extends StatefulWidget {
  final Address selectedAddress;
  final List<CartItem> cartItems;
  final double subtotal;
  final double deliveryFee;

  const PaymentMethodPage({
    super.key,
    required this.selectedAddress,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طريقة الدفع'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPaymentMethodCard(
                  'cash',
                  'الدفع عند الاستلام',
                  Icons.money,
                ),
                const SizedBox(height: 16),
                _buildPaymentMethodCard(
                  'card',
                  'بطاقة ائتمان',
                  Icons.credit_card,
                ),
                const SizedBox(height: 16),
                _buildPaymentMethodCard(
                  'wallet',
                  'محفظة إلكترونية',
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMethod == null ? null : _navigateToOrderReview,
                child: const Text('متابعة'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method, String title, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedMethod == method ? Colors.blue : Colors.grey.shade300,
              width: selectedMethod == method ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              if (selectedMethod == method)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToOrderReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderReviewPage(
          paymentMethod: selectedMethod!,
          selectedAddress: widget.selectedAddress,
          cartItems: widget.cartItems,
          subtotal: widget.subtotal,
          deliveryFee: widget.deliveryFee,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final favoriteIds = await LocalStorageService.getFavoriteIds();
    if (mounted) {
      setState(() {
        isFavorite = favoriteIds.contains(widget.product.id);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      if (isFavorite) {
        await LocalStorageService.removeFromFavorites(widget.product.id);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تمت الإزالة من المفضلة')),
        );
      } else {
        await LocalStorageService.addToFavorites(widget.product);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
        );
      }
      
      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحديث المفضلة')),
      );
    }
  }

  Future<void> _addToCart() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await LocalStorageService.addToCart(widget.product, quantity);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم إضافة المنتج إلى السلة')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الإضافة إلى السلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl != null)
              Image.network(
                widget.product.imageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (widget.product.description != null) ...[
                    Text(
                      widget.product.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Text(
                        'السعر: ${widget.product.price} جنيه',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (widget.product.discountPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product.discountPrice} جنيه',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'الكمية:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'إضافة إلى السلة',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
                  import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onAddToCartPressed;
  final Function(int)? onQuantityChanged;
  final double width;
  final double height;

  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.onAddToCartPressed,
    this.onQuantityChanged,
    this.width = 160,
    this.height = 200,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const double priceFontSize = 14.0;
  static const double titleFontSize = 16.0;

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: widget.product.imageUrl != null
          ? Image.network(
              widget.product.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingIndicator(loadingProgress);
              },
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'الصورة غير متوفرة',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (widget.onFavoritePressed != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.onFavoritePressed,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: widget.isFavorite ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              widget.product.unit ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.discountPrice != null) ...[
                        Text(
                          '₪ ${widget.product.price}',
                          style: TextStyle(
                            fontSize: priceFontSize,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₪ ${widget.product.discountPrice}',
                          style: const TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ] else
                        Text(
                          '₪ ${widget.product.price}',
                          style: const TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.onAddToCartPressed != null)
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: widget.onAddToCartPressed,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
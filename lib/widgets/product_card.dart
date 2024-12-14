import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(int) onQuantityChanged;
  final VoidCallback onFavoritePressed;
  final VoidCallback onAddToCartPressed;
  final bool isFavorite;
  final bool showFavoriteButton;
  final bool showAddToCartButton;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onFavoritePressed,
    required this.onAddToCartPressed,
    required this.onQuantityChanged,
    this.isFavorite = false,
    this.showFavoriteButton = true,
    this.showAddToCartButton = true,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1;

  Future<void> _addToCart() async {
    try {
      // Always use local storage for cart
      await LocalStorageService.addToCart(widget.product, _quantity);
      widget.onAddToCartPressed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 3),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'تمت الإضافة إلى السلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.pushNamed(context, '/cart_page').then((_) {
                      // Refresh the parent page when returning from cart
                      widget.onAddToCartPressed();
                      // Force refresh cart page
                      Navigator.pushReplacementNamed(context, '/cart_page');
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'الذهاب للسلة',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الإضافة إلى السلة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageSize = cardWidth;
        final titleFontSize = isSmallScreen ? 11.0 : isMediumScreen ? 13.0 : 16.0;
        final priceFontSize = isSmallScreen ? 13.0 : isMediumScreen ? 15.0 : 18.0;
        final iconSize = isSmallScreen ? 16.0 : 20.0;
        final buttonHeight = isSmallScreen ? 28.0 : 36.0;
        final contentPadding = isSmallScreen ? 4.0 : 8.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.product.imageUrl != null
                          ? Image.network(
                              widget.product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error loading image: ${widget.product.imageUrl}');
                                debugPrint('Error details: $error');
                                return Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: imageSize * 0.3,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.image_not_supported,
                                size: imageSize * 0.3,
                                color: Colors.grey,
                              ),
                            ),
                      if (widget.product.discountPrice != null)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 4 : 8,
                              vertical: isSmallScreen ? 2 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[600],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${(((widget.product.price - widget.product.discountPrice!) / widget.product.price) * 100).round()}% خصم',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 9 : 11,
                              ),
                            ),
                          ),
                        ),
                      if (widget.showFavoriteButton)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: widget.isFavorite ? Colors.red : Colors.grey[600],
                                size: iconSize,
                              ),
                              onPressed: widget.onFavoritePressed,
                              constraints: BoxConstraints(
                                minWidth: buttonHeight,
                                minHeight: buttonHeight,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top row: Name and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price on the left
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.product.discountPrice != null)
                                  Text(
                                    '${widget.product.price.toStringAsFixed(2)} ريال',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey[600],
                                      fontSize: isSmallScreen ? 9 : 11,
                                    ),
                                  ),
                                Text(
                                  '${(widget.product.discountPrice ?? widget.product.price).toStringAsFixed(2)} ريال',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    fontSize: priceFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Name on the right
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleFontSize,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                                if (widget.product.unit != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: contentPadding / 2),
                                    child: Text(
                                      'الوحدة: ${widget.product.unit}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: isSmallScreen ? 9 : 11,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Bottom section: Quantity selector and buy button
                      if (widget.showAddToCartButton)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          padding: EdgeInsets.all(contentPadding / 2),
                          child: Row(
                            children: [
                              // Buy button
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: _addToCart,
                                  constraints: BoxConstraints(
                                    minWidth: buttonHeight,
                                    minHeight: buttonHeight,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: contentPadding),
                              // Quantity selector
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_rounded,
                                          size: iconSize,
                                          color: _quantity > 1 ? Colors.grey[700] : Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          if (_quantity > 1) {
                                            setState(() {
                                              _quantity--;
                                              widget.onQuantityChanged(_quantity);
                                            });
                                          }
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: buttonHeight,
                                          minHeight: buttonHeight,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          minWidth: isSmallScreen ? 24 : 32,
                                        ),
                                        child: Text(
                                          _quantity.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 11 : 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_rounded,
                                          size: iconSize,
                                          color: Colors.grey[700],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _quantity++;
                                            widget.onQuantityChanged(_quantity);
                                          });
                                        },
                                        constraints: BoxConstraints(
                                          minWidth: buttonHeight,
                                          minHeight: buttonHeight,
                                        ),
                                        padding: EdgeInsets.zero,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

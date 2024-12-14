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

    // Adjusted sizes for small screens
    final titleFontSize = isSmallScreen ? 10.0 : isMediumScreen ? 12.0 : 14.0;
    final priceFontSize = isSmallScreen ? 11.0 : isMediumScreen ? 13.0 : 15.0;
    final iconSize = isSmallScreen ? 14.0 : 18.0;
    final buttonHeight = isSmallScreen ? 24.0 : 32.0;
    final contentPadding = isSmallScreen ? 4.0 : 6.0;
    final discountFontSize = isSmallScreen ? 8.0 : 10.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with discount badge and favorite button
          AspectRatio(
            aspectRatio: isSmallScreen ? 1 : 1.2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  widget.product.imageUrl != null
                      ? Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.image_not_supported,
                                size: iconSize * 2,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image_not_supported,
                            size: iconSize * 2,
                            color: Colors.grey,
                          ),
                        ),
                  
                  // Discount Badge
                  if (widget.product.discountPrice != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: contentPadding,
                          vertical: contentPadding / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(((widget.product.price - widget.product.discountPrice!) / widget.product.price) * 100).round()}% خصم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: discountFontSize,
                          ),
                        ),
                      ),
                    ),
                  
                  // Favorite Button
                  if (widget.showFavoriteButton)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
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
          
          // Product Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Name and Unit
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
                    Text(
                      'الوحدة: ${widget.product.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: titleFontSize - 2,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  
                  const Spacer(),
                  
                  // Price Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.discountPrice != null)
                        Text(
                          '${widget.product.price.toStringAsFixed(2)} ريال',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: titleFontSize - 2,
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
                  
                  // Add to Cart Section
                  if (widget.showAddToCartButton)
                    Padding(
                      padding: EdgeInsets.only(top: contentPadding),
                      child: Row(
                        children: [
                          // Quantity Selector
                          Expanded(
                            child: Container(
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildQuantityButton(
                                    icon: Icons.remove_rounded,
                                    onPressed: _quantity > 1
                                        ? () {
                                            setState(() {
                                              _quantity--;
                                              widget.onQuantityChanged(_quantity);
                                            });
                                          }
                                        : null,
                                    iconSize: iconSize,
                                    buttonHeight: buttonHeight,
                                  ),
                                  Text(
                                    _quantity.toString(),
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _buildQuantityButton(
                                    icon: Icons.add_rounded,
                                    onPressed: () {
                                      setState(() {
                                        _quantity++;
                                        widget.onQuantityChanged(_quantity);
                                      });
                                    },
                                    iconSize: iconSize,
                                    buttonHeight: buttonHeight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: contentPadding),
                          // Add to Cart Button
                          Container(
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(6),
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
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double iconSize,
    required double buttonHeight,
  }) {
    return SizedBox(
      width: buttonHeight,
      height: buttonHeight,
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: onPressed != null ? Colors.grey[700] : Colors.grey[400],
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

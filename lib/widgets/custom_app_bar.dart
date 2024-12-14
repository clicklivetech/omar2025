import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Color? backgroundColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool showLogo;
  final int? cartItemCount;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
    this.backgroundColor,
    this.systemOverlayStyle,
    this.showLogo = false,
    this.cartItemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return AppBar(
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.light,
      backgroundColor: backgroundColor ?? primaryColor,
      elevation: elevation,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.white,
              onPressed: () {
                // Handle notifications
              },
            ),
      title: showLogo
          ? Image.asset(
              'assets/images/logo.png',
              height: 40,
              fit: BoxFit.contain,
            )
          : Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: [
        if (cartItemCount != null)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                color: Colors.white,
                onPressed: () {
                  // Handle cart
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cartItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.search),
          color: Colors.white,
          onPressed: () {
            // Handle search
          },
        ),
        ...(actions ?? []),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

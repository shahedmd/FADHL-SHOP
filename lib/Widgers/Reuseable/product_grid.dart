import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Controllers/wishlist_controller.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 🚀 ADDED CACHE MANAGER

import '../../Admin Panel/Utils/global_colours.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        );
      }

      // 🚀 Using the new paginated lists
      final allFiltered = controller.filteredProducts;
      final visibleProducts = controller.displayedProducts;

      if (allFiltered.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: Text(
              'No products found matching your criteria.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      return Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int columns =
                  constraints.maxWidth >= 900
                      ? 4
                      : (constraints.maxWidth >= 600 ? 3 : 2);
              double aspectRatio = constraints.maxWidth < 600 ? 0.58 : 0.65;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount:
                    visibleProducts.length, // 🚀 Only builds the visible ones!
                itemBuilder: (context, index) {
                  return ProductCard(product: visibleProducts[index]);
                },
              );
            },
          ),

          // 🚀 "LOAD MORE" BUTTON
          if (allFiltered.length > visibleProducts.length) ...[
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
                foregroundColor: AppColors.primaryGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => controller.loadMore(),
              child: const Text(
                'Load More Products',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      );
    });
  }
}

// ==========================================
// THE ULTRA-RESPONSIVE PRODUCT CARD
// ==========================================
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final RxBool _isHovered = false.obs;

  ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: GestureDetector(
        onTap: () => Get.toNamed('/product/${product.id}', arguments: product),
        child: Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              _isHovered.value ? -5 : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isHovered.value ? 0.1 : 0.04,
                  ),
                  blurRadius: _isHovered.value ? 15 : 10,
                  offset: Offset(0, _isHovered.value ? 8 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚀 HIGH-PERFORMANCE IMAGE SECTION
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        // 🚀 MAGIC BULLET: CachedNetworkImage + memCacheWidth
                        child: CachedNetworkImage(
                          imageUrl:
                              product.images.isNotEmpty
                                  ? product.images[0]
                                  : 'https://via.placeholder.com/300',
                          fit: BoxFit.cover,
                          memCacheWidth:
                              400, // Downsizes 4K images in RAM to prevent crashes
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[50],
                                child: const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                      ),

                      // Category Badge
                      Positioned(
                        top: isMobile ? 6 : 10,
                        left: isMobile ? 6 : 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8,
                            vertical: isMobile ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textDark.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      // Wishlist Button
                      Positioned(
                        top: isMobile ? 6 : 10,
                        right: isMobile ? 6 : 10,
                        child: Obx(() {
                          final bool isSaved = wishlistController.isFavorite(
                            product.id,
                          );
                          return InkWell(
                            onTap:
                                () =>
                                    wishlistController.toggleWishlist(product),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: FaIcon(
                                isSaved
                                    ? FontAwesomeIcons.solidHeart
                                    : FontAwesomeIcons.heart,
                                color: isSaved ? Colors.redAccent : Colors.grey,
                                size: isMobile ? 14 : 16,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                // DETAILS SECTION
                Container(
                  padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 12 : 14,
                          height: 1.2,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 10),
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: isMobile ? 14 : 18,
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 32 : 38,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.primaryGold,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => cartController.addToCart(product, 1),
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            size: isMobile ? 14 : 16,
                          ),
                          label: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 11 : 13,
                            ),
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
      ),
    );
  }
}

import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Controllers/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
            child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
          ),
        );
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
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

      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Columns
          int columns =
              constraints.maxWidth >= 900
                  ? 4
                  : (constraints.maxWidth >= 600 ? 3 : 2);

          // Responsive Aspect Ratio (Make cards slightly taller on mobile to fit the text)
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
              childAspectRatio: aspectRatio, // Dynamic ratio applied!
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      );
    });
  }
}

// ==========================================
// THE ULTRA-RESPONSIVE PRODUCT CARD
// ==========================================
class ProductCard extends StatelessWidget {
  final dynamic product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // 1. Detect if the user is on a Mobile Phone
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/product/${product.id}', arguments: product);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. IMAGE SECTION (Takes all remaining flexible space)
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.images.isNotEmpty
                            ? product.images[0]
                            : 'https://via.placeholder.com/300',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                      ),
                    ),
                    Positioned(
                      top: isMobile ? 6 : 10,
                      left: isMobile ? 6 : 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1F13).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: const Color(0xFFCEAB5F),
                            fontSize:
                                isMobile ? 8 : 10, // Smaller badge on mobile
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: isMobile ? 6 : 10,
                      right: isMobile ? 6 : 10,
                      child: Obx(() {
                        final wishlistController =
                            Get.find<WishlistController>();
                        final bool isSaved = wishlistController.isFavorite(
                          product.id,
                        );

                        return InkWell(
                          onTap:
                              () => wishlistController.toggleWishlist(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
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

              // 3. DETAILS SECTION (Takes exactly the space it needs to prevent overflow)
              Container(
                padding: EdgeInsets.all(
                  isMobile ? 8.0 : 12.0,
                ), // Less padding on mobile
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Hugs the text tightly
                  children: [
                    // Product Title
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 12 : 14, // Shrinks on mobile
                        height: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 10), // Tighter spacing
                    // Price
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: const Color(0xFFCEAB5F),
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 14 : 18, // Shrinks on mobile
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),

                    // Make sure to import the controller at the top of the file if you haven't:
                    // import '../controllers/cart_controller.dart';
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 32 : 38, // Shorter button on mobile
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A1F13),
                          foregroundColor: const Color(0xFFCEAB5F),
                          elevation: 0,
                          padding:
                              EdgeInsets
                                  .zero, // Prevents internal padding from causing overflow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          final cartController = Get.find<CartController>();
                          cartController.addToCart(
                            product,
                            1,
                          ); // Adds 1 item automatically!
                        },
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
    );
  }
}

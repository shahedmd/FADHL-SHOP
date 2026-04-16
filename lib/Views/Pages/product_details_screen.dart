import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Admin Panel/Utils/global_colours.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});

  final TextEditingController reviewCommentController = TextEditingController();
  final RxInt selectedImageIndex = 0.obs;
  final RxInt quantity = 1.obs;
  final RxInt selectedRating = 5.obs;

  final Map<int, String> ratingOptions = {
    1: 'Poor',
    2: 'Fair',
    3: 'Average',
    4: 'Good',
    5: 'Great',
  };

  ProductModel? _getSmartProduct(ProductController pc) {
    String? targetId = Get.parameters['id'];
    if (targetId == null && Get.arguments != null) {
      targetId = (Get.arguments as ProductModel).id;
    }
    if (targetId != null) {
      try {
        return pc.products.firstWhere((p) => p.id == targetId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ProductController pc = Get.find<ProductController>();

    return Obx(() {
      if (pc.isLoading.value) {
        return const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        );
      }

      final ProductModel? currentProduct = _getSmartProduct(pc);

      // Fallback if product is missing or deleted
      if (currentProduct == null) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Product no longer available.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.offAllNamed('/'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Back to Store',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final bool isDesktop = MediaQuery.of(context).size.width >= 900;

      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            const CustomHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ResponsiveLayout(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 30.0,
                        ),
                        child:
                            isDesktop
                                ? _buildDesktopLayout(currentProduct)
                                : _buildMobileLayout(currentProduct),
                      ),
                    ),
                    // 🚀 UPDATED: Now uses the new vertical list layout instead of tabs
                    ResponsiveLayout(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildProductDetailsList(currentProduct),
                      ),
                    ),
                    ResponsiveLayout(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 40.0,
                        ),
                        child: _buildReviewsSection(currentProduct),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDesktopLayout(ProductModel currentProduct) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 40,
          child: _buildImageGallery(
            isDesktop: true,
            currentProduct: currentProduct,
          ),
        ),
        const SizedBox(width: 50),
        Expanded(flex: 60, child: _buildProductInfo(currentProduct)),
      ],
    );
  }

  Widget _buildMobileLayout(ProductModel currentProduct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGallery(isDesktop: false, currentProduct: currentProduct),
        const SizedBox(height: 24),
        _buildProductInfo(currentProduct),
      ],
    );
  }

  // ==========================================
  // 1. NATIVE IMAGE GALLERY & ZOOM
  // ==========================================
  Widget _buildImageGallery({
    required bool isDesktop,
    required ProductModel currentProduct,
  }) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () {
              if (currentProduct.images.isNotEmpty) {
                _showZoomDialog(
                  currentProduct.images[selectedImageIndex.value],
                );
              }
            },
            child: Container(
              height: isDesktop ? 450 : 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Obx(
                      () => Image.network(
                        currentProduct.images.isNotEmpty
                            ? currentProduct.images[selectedImageIndex.value]
                            : 'https://via.placeholder.com/500',
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGold,
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.textDark.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (currentProduct.images.isNotEmpty)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentProduct.images.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = selectedImageIndex.value == index;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => selectedImageIndex.value = index,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        width: 70,
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryGold
                                    : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            currentProduct.images[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade50,
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
      ],
    );
  }

  void _showZoomDialog(String imageUrl) {
    Get.dialog(
      Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(
                      color: AppColors.primaryGold,
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black,
      useSafeArea: false,
    );
  }

  // ==========================================
  // 2. PRODUCT INFO & BUTTONS
  // ==========================================
  Widget _buildProductInfo(ProductModel currentProduct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            currentProduct.category,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          currentProduct.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          '৳${currentProduct.price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 30),

        const Text(
          'Quantity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _qtyButton(Icons.remove, () {
              if (quantity.value > 1) quantity.value--;
            }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Obx(
                () => Text(
                  '${quantity.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            _qtyButton(Icons.add, () => quantity.value++),
          ],
        ),
        const SizedBox(height: 30),

        // MAIN ORDER BUTTON
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
            ),
            onPressed: () {
              final cartController = Get.find<CartController>();
              cartController.addToCart(currentProduct, quantity.value);
              Get.toNamed('/cart');
            },
            icon: const Icon(
              Icons.flash_on,
              color: AppColors.pureWhite,
              size: 20,
            ),
            label: const Text(
              'ORDER NOW',
              style: TextStyle(
                color: AppColors.pureWhite,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // SECONDARY BUTTONS
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryGold,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final cartController = Get.find<CartController>();
                    cartController.addToCart(currentProduct, quantity.value);
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primaryGold,
                    size: 18,
                  ),
                  label: const Text(
                    'ADD TO CART',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final pc = Get.find<ProductController>();
                    pc.orderViaWhatsApp(currentProduct, quantity.value);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: AppColors.textDark),
      ),
    );
  }

  // ==========================================
  // 3. VERTICAL DETAILS LIST (NO TABS)
  // ==========================================
  Widget _buildProductDetailsList(ProductModel currentProduct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection(
          'Description',
          currentProduct.description.isNotEmpty
              ? currentProduct.description
              : "No description available.",
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'Benefits',
          currentProduct.benefits.isNotEmpty
              ? currentProduct.benefits
              : "No benefits listed.",
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          'Usage',
          currentProduct.usage.isNotEmpty
              ? currentProduct.usage
              : "No usage instructions listed.",
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. REVIEWS SECTION
  // ==========================================
  Widget _buildReviewsSection(ProductModel currentProduct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Experience',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 24),
        currentProduct.reviews.isEmpty
            ? const Text(
              'Be the first to share your experience with this product.',
              style: TextStyle(color: Colors.grey),
            )
            : Column(
              children:
                  currentProduct.reviews.map((review) {
                    final int starCount =
                        (review['rating'] != null)
                            ? (review['rating'] as num).toInt()
                            : 5;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryGreen
                                    .withValues(alpha: 0.1),
                                radius: 18,
                                child: const FaIcon(
                                  FontAwesomeIcons.solidUser,
                                  color: AppColors.primaryGold,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                review['reviewerName'] ?? 'Verified Customer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    starIndex < starCount
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: AppColors.primaryGold,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            review['comment'] ?? '',
                            style: const TextStyle(
                              color: AppColors.textDark,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.5),
            ),
          ),
          child: Obx(() {
            final AuthController authController = Get.find<AuthController>();
            final bool isLoggedIn = authController.firebaseUser.value != null;
            if (!isLoggedIn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lock,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the FADHL Family',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You must be logged in to share your experience.',
                    style: TextStyle(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 45,
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => Get.toNamed('/auth'),
                      child: const Text(
                        'Login to Review',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share Your Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      ratingOptions.entries
                          .map(
                            (entry) => Obx(() {
                              final isSelected =
                                  selectedRating.value == entry.key;
                              return ChoiceChip(
                                label: Text(entry.value),
                                selected: isSelected,
                                selectedColor: AppColors.primaryGreen,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primaryGold
                                          : AppColors.textDark,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                                onSelected: (bool selected) {
                                  if (selected) {
                                    selectedRating.value = entry.key;
                                  }
                                },
                              );
                            }),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reviewCommentController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Tell us more about your experience...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      final ProductController pc =
                          Get.find<ProductController>();
                      bool success = await pc.submitReview(
                        productId: currentProduct.id,
                        rating: selectedRating.value,
                        comment: reviewCommentController.text,
                      );
                      if (success) {
                        reviewCommentController.clear();
                        selectedRating.value = 5;
                      }
                    },
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
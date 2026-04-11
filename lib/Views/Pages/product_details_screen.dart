import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  final TextEditingController reviewCommentController = TextEditingController();

  ProductModel? _getSmartProduct(ProductController pc) {
    // 1. Find the target ID (Either from URL or Get.arguments)
    String? targetId = Get.parameters['id'];

    if (targetId == null && Get.arguments != null) {
      targetId = (Get.arguments as ProductModel).id;
    }

    // 2. ALWAYS pull from the LIVE Controller memory!
    // This guarantees that when a review is added to the controller, the UI instantly repaints!
    if (targetId != null) {
      try {
        return pc.products.firstWhere((p) => p.id == targetId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  final RxInt selectedImageIndex = 0.obs;
  final RxInt quantity = 1.obs;
  final RxInt selectedTab = 0.obs;

  final RxInt selectedRating = 5.obs;
  final Map<int, String> ratingOptions = {
    1: 'Poor',
    2: 'Fair',
    3: 'Average',
    4: 'Good',
    5: 'Great',
  };

  @override
  Widget build(BuildContext context) {
    final ProductController pc = Get.find<ProductController>();

    return Obx(() {
      // 1. Loading State
      if (pc.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Center(child: CircularProgressIndicator(color: brandGold)),
        );
      }

      // 2. Fetch the LIVE product using our Smart Deep-Link logic
      final ProductModel? currentProduct = _getSmartProduct(pc);

      // ==========================================
      // 🚀 THE FIX: Graceful Fallback (Prevents Chrome Back-Button Crash!)
      // ==========================================
      if (currentProduct == null) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: brandGold,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.offAllNamed('/'), // Safe manual click
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
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            CustomHeader(),

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

                    ResponsiveLayout(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildInfoTabsAndContent(currentProduct),
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

  // ==========================================
  // LAYOUTS (Desktop Image Made MUCH Smaller)
  // ==========================================
  Widget _buildDesktopLayout(ProductModel currentProduct) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // REDUCED FLEX: Image is now only 35% of the screen width!
        Expanded(
          flex: 35,
          child: _buildImageGallery(
            isDesktop: true,
            currentProduct: currentProduct,
          ),
        ),
        const SizedBox(width: 60), // More breathing room
        // INCREASED FLEX: Text gets 65% of the screen width!
        Expanded(flex: 65, child: _buildProductInfo(currentProduct)),
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
  // 1. IMAGE GALLERY
  // ==========================================
  Widget _buildImageGallery({
    required bool isDesktop,
    required ProductModel currentProduct,
  }) {
    return Column(
      children: [
        Container(
          height: isDesktop ? 350 : 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Obx(
              () => Image.network(
                currentProduct.images.isNotEmpty
                    ? currentProduct.images[selectedImageIndex.value]
                    : 'https://via.placeholder.com/500',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (currentProduct.images.isNotEmpty)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentProduct.images.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isSelected = selectedImageIndex.value == index;
                  return GestureDetector(
                    onTap: () => selectedImageIndex.value = index,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? brandGold : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          currentProduct.images[index],
                          fit: BoxFit.cover,
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
            color: brandGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            currentProduct.category,
            style: TextStyle(
              color: brandGreen,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          currentProduct.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          '৳${currentProduct.price.toStringAsFixed(0)}',
          style: TextStyle(
            color: brandGold,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Quantity',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _qtyButton(Icons.remove, () {
              if (quantity.value > 1) quantity.value--;
            }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Obx(
                () => Text(
                  '${quantity.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _qtyButton(Icons.add, () => quantity.value++),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final cartController = Get.find<CartController>();
              cartController.addToCart(currentProduct, quantity.value);
              Get.toNamed('/cart');
            },
            icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
            label: const Text(
              'ORDER NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: brandGold, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    final cartController = Get.find<CartController>();
                    cartController.addToCart(currentProduct, quantity.value);
                  },
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: brandGold,
                    size: 18,
                  ),
                  label: Text(
                    'ADD TO CART',
                    style: TextStyle(
                      color: brandGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ==========================================
  // 3. FIXED-WIDTH TABS SECTION
  // ==========================================
  Widget _buildInfoTabsAndContent(ProductModel currentProduct) {
    final tabs = ['Description', 'Benefits', 'Usage'];

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: List.generate(
                tabs.length,
                (index) => Expanded(
                  child: Obx(() {
                    final isSelected = selectedTab.value == index;
                    return InkWell(
                      onTap: () => selectedTab.value = index,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? brandGreen : Colors.transparent,
                          borderRadius:
                              index == 0
                                  ? const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                  )
                                  : (index == 2
                                      ? const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                      )
                                      : BorderRadius.zero),
                        ),
                        child: Center(
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color:
                                  isSelected ? brandGold : Colors.grey.shade600,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              if (selectedTab.value == 0) {
                return _tabTextContent(
                  currentProduct.description.isNotEmpty
                      ? currentProduct.description
                      : "No description available.",
                );
              }
              if (selectedTab.value == 1) {
                return _tabTextContent(
                  currentProduct.benefits.isNotEmpty
                      ? currentProduct.benefits
                      : "No benefits listed.",
                );
              }
              if (selectedTab.value == 2) {
                return _tabTextContent(
                  currentProduct.usage.isNotEmpty
                      ? currentProduct.usage
                      : "No usage instructions listed.",
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabTextContent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
    );
  }

  // ==========================================
  // 4. REVIEWS (NOW WITH VISUAL STARS!)
  // ==========================================
  Widget _buildReviewsSection(ProductModel currentProduct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Experience',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: brandGreen,
          ),
        ),
        const SizedBox(height: 24),

        // DISPLAYING REVIEWS WITH GOLDEN STARS
        currentProduct.reviews.isEmpty
            ? const Text(
              'Be the first to share your experience with this product.',
              style: TextStyle(color: Colors.grey),
            )
            : Column(
              children:
                  currentProduct.reviews.map((review) {
                    // ==========================================
                    // 🚀 CRITICAL FIX: Safe conversion for Double vs Int!
                    // ==========================================
                    final int starCount =
                        (review['rating'] != null)
                            ? (review['rating'] as num).toInt()
                            : 5;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: brandGreen.withValues(
                                  alpha: 0.1,
                                ),
                                radius: 18,
                                child: FaIcon(
                                  FontAwesomeIcons.solidUser,
                                  color: brandGold,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                review['reviewerName'] ?? 'Verified Customer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),

                              // MAGIC: Converts the database number (e.g. 5) into 5 Golden Stars!
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < starCount
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.orange,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            review['comment'] ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),

        const SizedBox(height: 40),

        // WRITE A REVIEW SECTION
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: brandGold.withValues(alpha: 0.5)),
          ),
          child: Obx(() {
            final AuthController authController = Get.find<AuthController>();
            final bool isLoggedIn = authController.firebaseUser.value != null;

            // =====================================
            // STATE A: USER IS NOT LOGGED IN
            // =====================================
            if (!isLoggedIn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  FaIcon(
                    FontAwesomeIcons.lock,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the FADHL Family',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You must be logged in to share your experience.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 45,
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGold,
                        foregroundColor: brandGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed:
                          () => Get.toNamed('/auth'), // Takes them to Login!
                      child: const Text(
                        'Login to Review',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            // =====================================
            // STATE B: USER IS LOGGED IN (SHOW FORM)
            // =====================================
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share Your Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),

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
                                selectedColor: brandGreen,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? brandGold : Colors.black87,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                                onSelected: (bool selected) {
                                  if (selected) {
                                    selectedRating.value =
                                        entry.key; // Saves the number (e.g. 5)
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
                      backgroundColor: brandGold,
                      foregroundColor: brandGreen,
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

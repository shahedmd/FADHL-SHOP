import 'package:fadhl/Controllers/banner_controller.dart';
import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Admin Panel/Utils/global_colours.dart'; 

class PromoCarousel extends StatelessWidget {
  const PromoCarousel({super.key});
  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final BannerController controller = Get.find<BannerController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;
    final double carouselHeight = isDesktop ? 500.0 : 220.0;

    return Obx(() {
      // 1. Loading State
      if (controller.isLoading.value) {
        return Container(
          height: carouselHeight,
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? 0 : 16.0,
            vertical: 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold,
            ), // Updated
          ),
        );
      }

      // 2. Empty State
      if (controller.banners.isEmpty) {
        return const SizedBox.shrink(); // Hide completely if no banners in Firebase
      }

      // 3. The Carousel
      return Container(
        width: double.infinity,
        height: carouselHeight,
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 0 : 16.0,
          vertical: 20.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 12),
          child: Stack(
            children: [
              // SLIDER
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.banners.length,
                itemBuilder: (context, index) {
                  final banner = controller.banners[index];

                  final bool hasText = banner.title.trim().isNotEmpty;

                  return InkWell(
                    onTap: () {
                      if (banner.targetCategory != 'All') {
                        productController.updateCategory(banner.targetCategory);
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(banner.image, fit: BoxFit.cover),
                        if (hasText) ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textDark.withValues(
                                    alpha: 0.6,
                                  ), // Updated
                                  AppColors.textDark.withValues(
                                    alpha: 0.2,
                                  ), // Updated
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          Positioned(
                            left: isDesktop ? 60 : 20,
                            top: 0,
                            bottom: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: isDesktop ? 500 : 250,
                                  child: Text(
                                    banner.title,
                                    style: TextStyle(
                                      color: AppColors.pureWhite, // Updated
                                      fontSize: isDesktop ? 42 : 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 16 : 8),
                                SizedBox(
                                  width: isDesktop ? 450 : 220,
                                  child: Text(
                                    banner.subtitle,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: isDesktop ? 18 : 12,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 30 : 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primaryGold, // Updated
                                    foregroundColor:
                                        AppColors.primaryGreen, // Updated
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 30 : 16,
                                      vertical: isDesktop ? 20 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (banner.targetCategory != 'All') {
                                      productController.updateCategory(
                                        banner.targetCategory,
                                      );
                                    }
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.arrowRight,
                                    size: isDesktop ? 18 : 14,
                                  ),
                                  label: Text(
                                    banner.buttonText,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 16 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // THE ANIMATED DOT INDICATORS
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.banners.length,
                    (index) => Obx(() {
                      final isActive = controller.currentIndex.value == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 32 : 8, // Stretches out when active
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? AppColors
                                      .primaryGold // Updated
                                  : AppColors.pureWhite.withValues(
                                    alpha: 0.5,
                                  ), // Updated
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

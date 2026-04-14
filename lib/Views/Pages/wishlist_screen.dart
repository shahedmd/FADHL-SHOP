import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is inside this file
import '../../Controllers/wishlist_controller.dart';
import '../../Widgers/Reuseable/responsive_headermenu.dart';
import '../../Widgers/responsive_layout.dart';

import '../../Widgers/Reuseable/product_grid.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Updated to brand background
      body: Column(
        children: [
          const CustomHeader(),

          Expanded(
            child: Obx(() {
              // ==========================================
              // 1. EMPTY WISHLIST STATE
              // ==========================================
              if (wishlistController.wishlistItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.heartCrack,
                          size: 60,
                          color: Colors.redAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark, // Updated to brand text
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Save your favorite premium items here for later.',
                        style: TextStyle(
                          color: AppColors.textDark.withValues(
                            alpha: 0.7,
                          ), // Updated
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen, // Updated
                          foregroundColor: AppColors.primaryGold, // Updated
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Get.offAllNamed('/'), // Go back home
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          size: 16,
                        ),
                        label: const Text(
                          'Explore Products',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ==========================================
              // 2. FILLED WISHLIST STATE
              // ==========================================
              return SingleChildScrollView(
                child: ResponsiveLayout(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 30.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Wishlist',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen, // Updated
                          ),
                        ),
                        const SizedBox(height: 24),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            int columns =
                                constraints.maxWidth >= 900
                                    ? 4
                                    : (constraints.maxWidth >= 600 ? 3 : 2);
                            double aspectRatio =
                                constraints.maxWidth < 600 ? 0.58 : 0.65;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    childAspectRatio: aspectRatio,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount:
                                  wishlistController.wishlistItems.length,
                              itemBuilder: (context, index) {
                                // Reusing your amazing ProductCard widget!
                                return ProductCard(
                                  product:
                                      wishlistController.wishlistItems[index],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
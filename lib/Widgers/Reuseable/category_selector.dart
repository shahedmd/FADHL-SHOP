import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Admin Panel/Utils/global_colours.dart'; // Ensure AppColors is inside this file

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});
  // Helper function to smartly assign icons based on category name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('eye')) return Icons.visibility;
    if (name.contains('organic') || name.contains('food')) return Icons.eco;
    if (name.contains('pet') || name.contains('cat')) return Icons.pets;
    return Icons.grid_view; // Default icon for 'All'
  }

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Section Title
          Obx(
            () => Text(
              controller.selectedCategory.value == 'All'
                  ? 'Explore Our Collections'
                  : '${controller.selectedCategory.value} Collection',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen, // Updated
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // The Premium Category Cards
          SizedBox(
            height: 55, // Taller for a premium look
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];

                  return Obx(() {
                    final isSelected =
                        controller.selectedCategory.value == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: InkWell(
                        onTap: () => controller.updateCategory(category),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.pureWhite, // Updated
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors
                                          .primaryGreen // Updated
                                      : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.3), // Updated
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 16,
                                color:
                                    isSelected
                                        ? AppColors
                                            .primaryGold // Updated
                                        : AppColors.textDark.withValues(
                                          alpha: 0.6,
                                        ), // Updated to brand dark green
                              ),
                              const SizedBox(width: 10),
                              Text(
                                category,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors
                                              .primaryGold // Updated
                                          : AppColors
                                              .textDark, // Updated to brand dark green
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

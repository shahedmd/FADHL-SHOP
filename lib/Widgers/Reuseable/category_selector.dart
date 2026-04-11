import 'package:fadhl/Controllers/productcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  // Helper function to smartly assign icons based on category name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('eye')) return FontAwesomeIcons.glasses;
    if (name.contains('organic') || name.contains('food')) {
      return FontAwesomeIcons.leaf;
    }
    if (name.contains('pet') || name.contains('cat')) {
      return FontAwesomeIcons.paw;
    }
    return FontAwesomeIcons.borderAll; // Default icon for 'All'
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: brandGreen,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // The Premium Category Cards
          SizedBox(
            height: 55, // Taller for a premium look
            child: Obx(
              ()=> ListView.builder(
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
                            color: isSelected ? brandGreen : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected ? brandGreen : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: brandGreen.withValues( alpha:  0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                _getCategoryIcon(category),
                                size: 16,
                                color: isSelected ? brandGold : Colors.black54,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? brandGold : Colors.black87,
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

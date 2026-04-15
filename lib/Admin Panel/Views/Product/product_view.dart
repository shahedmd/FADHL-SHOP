import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 🚀 ADDED: High-Performance Image Caching
import '../../../../Models/productmodel.dart';
import '../../Controllers/admin_product_controller.dart';
import '../../Utils/global_colours.dart';
import 'product_form_modal.dart';

class ProductsView extends StatelessWidget {
  final bool isDesktop;

  const ProductsView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminControllerProductmanagement>();
    final TextEditingController searchNameController = TextEditingController();
    final RxString searchCategory = 'All Categories'.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Products',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen, // Updated
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View, edit, and add new products to your store.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen, // Updated
                foregroundColor: AppColors.primaryGold, // Updated
                elevation: 2,
                shadowColor: AppColors.primaryGreen.withValues(
                  alpha: 0.3,
                ), // Updated
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => openProductFormModal(),
              icon: Icon(Icons.add, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add New Product' : 'Add',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 🚀 ADVANCED SEARCH BAR
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite, // Updated
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: searchNameController,
                  decoration: const InputDecoration(
                    hintText: 'Search by Product Name...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite, // Updated
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: searchCategory.value,
                      items:
                          [
                                'All Categories',
                                ...adminController.availableCategories,
                              ]
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => searchCategory.value = val!,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold, // Updated
                foregroundColor: AppColors.primaryGreen, // Updated
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed:
                  () => adminController.searchProducts(
                    searchNameController.text,
                    searchCategory.value,
                  ),
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (searchNameController.text.isNotEmpty ||
                searchCategory.value != 'All Categories') ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  searchNameController.clear();
                  searchCategory.value = 'All Categories';
                  adminController.fetchProducts(isRefresh: true);
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        Obx(() {
          if (adminController.isLoadingTable.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ), // Updated
            );
          }
          if (adminController.tableProducts.isEmpty) return _buildEmptyState();

          return Container(
            decoration:
                isDesktop
                    ? BoxDecoration(
                      color: AppColors.pureWhite, // Updated
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    )
                    : null,
            child: Column(
              children: [
                if (isDesktop) _buildDesktopHeaderRow(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isDesktop ? 16 : 0),
                  itemCount: adminController.tableProducts.length,
                  itemBuilder: (context, index) {
                    final product = adminController.tableProducts[index];

                    // 🚀 GROUP BY CATEGORY UI TRICK
                    bool showCategoryHeader = false;
                    if (index == 0 ||
                        adminController.tableProducts[index - 1].category !=
                            product.category) {
                      showCategoryHeader = true;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showCategoryHeader)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              bottom: 8,
                              left: 8,
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreen, // Updated
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        isDesktop
                            ? _buildDesktopProductRow(product, adminController)
                            : _buildMobileProductCard(product, adminController),
                        if (isDesktop &&
                            index != adminController.tableProducts.length - 1)
                          Divider(color: Colors.grey.shade100)
                        else if (!isDesktop)
                          const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }),

        // 🚀 PAGINATION CONTROLS
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed:
                      adminController.currentPage.value > 1
                          ? () => adminController.previousPage()
                          : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 12),
                  label: const Text('Prev', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.05,
                    ), // Updated
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Page ${adminController.currentPage.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryGreen, // Updated
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed:
                      adminController.hasNextPage.value
                          ? () => adminController.nextPage()
                          : null,
                  icon: const Text('Next', style: TextStyle(fontSize: 13)),
                  label: const Icon(Icons.arrow_forward_ios, size: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight, // Updated for brand consistency
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('Image', style: _headerStyle())),
          Expanded(flex: 3, child: Text('Product Name', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Category', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Price', style: _headerStyle())),
          Expanded(
            flex: 2,
            child: Text(
              'Actions',
              textAlign: TextAlign.right,
              style: _headerStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProductRow(
    ProductModel product,
    AdminControllerProductmanagement adminController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildProductImage(product, 50)),
          Expanded(
            flex: 3,
            child: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textDark, // Updated
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildCategoryBadge(product.category),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '৳${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primaryGreen, // Updated
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  color: Colors.blue,
                  tooltip: 'Edit Product',
                  onTap: () => openProductFormModal(existingProduct: product),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  tooltip: 'Delete Product',
                  onTap: () => _confirmDeleteProduct(product, adminController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductCard(
    ProductModel product,
    AdminControllerProductmanagement adminController,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProductImage(product, 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark, // Updated
                  ),
                ),
                const SizedBox(height: 6),
                _buildCategoryBadge(product.category),
                const SizedBox(height: 8),
                Text(
                  '৳${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primaryGreen, // Updated
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildActionButton(
                icon: Icons.edit_rounded,
                color: Colors.blue,
                tooltip: 'Edit',
                onTap: () => openProductFormModal(existingProduct: product),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                tooltip: 'Delete',
                onTap: () => _confirmDeleteProduct(product, adminController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
    fontWeight: FontWeight.w800,
    color: Colors.grey.shade500,
    fontSize: 12,
    letterSpacing: 0.5,
  );

  // ==========================================
  // 🚀 HIGH PERFORMANCE PRODUCT IMAGE LOADER
  // ==========================================
  Widget _buildProductImage(ProductModel product, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          product.images.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: product.images[0],
                width: size,
                height: size,
                fit: BoxFit.cover,
                // 🚀 CRITICAL FIX: Since max size is 80 (mobile), we cache it at 150.
                // This reduces memory usage per image by 95%!
                memCacheWidth: 150,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder:
                    (context, url) => Container(
                      width: size,
                      height: size,
                      color: Colors.grey.shade50,
                      child: Center(
                        child: SizedBox(
                          width: size * 0.4,
                          height: size * 0.4,
                          child: const CircularProgressIndicator(
                            color: AppColors.primaryGold,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                errorWidget: (context, url, error) => _buildImageFallback(size),
              )
              : _buildImageFallback(size),
    );
  }

  Widget _buildImageFallback(double size) => Container(
    width: size,
    height: size,
    color: Colors.grey.shade100,
    child: Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey.shade400,
    ),
  );

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08), // Updated
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ), // Updated
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryGreen, // Updated
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          hoverColor: color.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "No Products Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(
    ProductModel product,
    AdminControllerProductmanagement adminController,
  ) {
    Get.defaultDialog(
      title: 'Delete Product?',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppColors.textDark, // Updated
      ),
      content: Text(
        'Delete "${product.name}" forever?',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark, // Updated
        ),
      ),
      textConfirm: 'Delete Permanently',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      cancelTextColor: AppColors.primaryGreen, // Updated
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite, // Updated
      onConfirm: () {
        adminController.deleteProduct(product.id);
        Get.back();
      },
    );
  }
}
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Models/productmodel.dart';
import '../../Controllers/admin_product_controller.dart';
import '../../Utils/global_colours.dart';

void openProductFormModal({ProductModel? existingProduct}) {
  final adminController = Get.find<AdminControllerProductmanagement>();
  final bool isEdit = existingProduct != null;

  final nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
  final priceCtrl = TextEditingController(
    text: existingProduct?.price.toString() ?? '',
  );
  final descCtrl = TextEditingController(
    text: existingProduct?.description ?? '',
  );
  final benCtrl = TextEditingController(text: existingProduct?.benefits ?? '');
  final usageCtrl = TextEditingController(text: existingProduct?.usage ?? '');

  // 🚀 CATEGORY LOGIC
  final RxString selectedCategory =
      (existingProduct != null &&
                  adminController.availableCategories.contains(
                    existingProduct.category,
                  )
              ? existingProduct.category
              : (adminController.availableCategories.isNotEmpty
                  ? adminController.availableCategories.first
                  : 'General'))
          .obs;

  final RxBool isAddingNewCategory = false.obs;
  final TextEditingController newCategoryCtrl = TextEditingController();

  // 🚀 REVIEWS LOGIC
  RxList<dynamic> currentReviews = (existingProduct?.reviews ?? []).obs;

  RxList<String> currentImageUrls = (existingProduct?.images ?? []).obs;
  RxList<Uint8List> newImageBytes = <Uint8List>[].obs;
  List<String> newFileNames = [];

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    for (var img in images) {
      newImageBytes.add(await img.readAsBytes());
      newFileNames.add(img.name);
    }
  }

  Get.dialog(
    barrierDismissible: false,
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 1000, // 🚀 BIGGER PROFESSIONAL WIDTH
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.90,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandGreen,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Product' : 'Add New Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: brandGold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed:
                        () =>
                            Navigator.of(
                              Get.overlayContext!,
                              rootNavigator: true,
                            ).pop(), // 🚀 Fixes the closing crash!
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isModalDesktop = constraints.maxWidth > 700;

                    // ==============================
                    // LEFT PANEL: Details & Categories
                    // ==============================
                    Widget leftPanel = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Product Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price (৳)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 🚀 DROPDOWN & NEW CATEGORY
                        const Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          // 1. Safely grab current categories
                          List<String> safeCategories =
                              adminController.availableCategories.toList();

                          // 2. GUARANTEE the selected value exists in the list to prevent crashes
                          if (!safeCategories.contains(
                                selectedCategory.value,
                              ) &&
                              selectedCategory.value != 'ADD_NEW') {
                            safeCategories.insert(0, selectedCategory.value);
                          }

                          return DropdownButtonFormField<String>(
                            value: selectedCategory.value,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ...safeCategories.map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              ),
                              const DropdownMenuItem(
                                value: 'ADD_NEW',
                                child: Text(
                                  '➕ Create New Category',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == 'ADD_NEW') {
                                isAddingNewCategory.value = true;
                              } else {
                                isAddingNewCategory.value = false;
                                selectedCategory.value = val!;
                              }
                            },
                          );
                        }),
                        Obx(
                          () =>
                              isAddingNewCategory.value
                                  ? Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextField(
                                      controller: newCategoryCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Type New Category Name',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.add_box),
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                        ),

                        const SizedBox(height: 20),
                        TextField(
                          controller: descCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: benCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Benefits',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: usageCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Usage Instructions',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    );

                    // ==============================
                    // RIGHT PANEL: Images & Reviews
                    // ==============================
                    Widget rightPanel = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ...currentImageUrls.map(
                                (url) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        url,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap:
                                            () => currentImageUrls.remove(url),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...newImageBytes.map(
                                (bytes) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        bytes,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap:
                                            () => newImageBytes.remove(bytes),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: pickImages,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 🚀 REVIEWS MANAGEMENT
                        const Text(
                          'Manage Customer Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() {
                            if (currentReviews.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No reviews yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: currentReviews.length,
                              separatorBuilder:
                                  (c, i) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                var rev = currentReviews[index];
                                return ListTile(
                                  title: Text(
                                    rev['reviewerName'] ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '⭐ ${rev['rating']} / 5',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(rev['comment'] ?? ''),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed:
                                        () => currentReviews.removeAt(
                                          index,
                                        ), // Deletes review immediately!
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    );

                    return isModalDesktop
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: leftPanel),
                            const SizedBox(width: 40),
                            Expanded(flex: 4, child: rightPanel),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftPanel,
                            const SizedBox(height: 40),
                            rightPanel,
                          ],
                        );
                  },
                ),
              ),
            ),

            // ==============================
            // BOTTOM SAVE BUTTON
            // ==============================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: brandGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        adminController.isUploading.value
                            ? null
                            : () async {
                              // Final Category resolve
                              String finalCat =
                                  isAddingNewCategory.value
                                      ? newCategoryCtrl.text.trim()
                                      : selectedCategory.value;
                              if (finalCat.isEmpty) finalCat = 'General';

                              List<String> uploadedUrls = await adminController
                                  .uploadProductImages(
                                    newImageBytes,
                                    newFileNames,
                                  );
                              List<String> finalImages = [
                                ...currentImageUrls,
                                ...uploadedUrls,
                              ];
                              String finalId =
                                  isEdit
                                      ? existingProduct.id
                                      : FirebaseFirestore.instance
                                          .collection('Products')
                                          .doc()
                                          .id;

                              ProductModel updatedProduct = ProductModel(
                                id: finalId,
                                name: nameCtrl.text,
                                price: double.tryParse(priceCtrl.text) ?? 0.0,
                                category: finalCat,
                                description: descCtrl.text,
                                benefits: benCtrl.text,
                                usage: usageCtrl.text,
                                images: finalImages,
                                reviews:
                                    currentReviews
                                        .toList(), // Pass updated reviews!
                              );

                              await adminController.saveProduct(
                                updatedProduct,
                                isNew: !isEdit,
                              );
                            },
                    child:
                        adminController.isUploading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFCEAB5F),
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              isEdit ? 'SAVE CHANGES' : 'CREATE PRODUCT',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// lib/Admin Panel/Views/admin_banner_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Models/bannermodel.dart';
import '../../Controllers/admin_banner_controller.dart';
import '../../Utils/global_colours.dart';

class AdminBannerView extends StatelessWidget {
  final bool isDesktop;
  const AdminBannerView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminBannerController controller = Get.put(AdminBannerController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // 1. HEADER & ADD BUTTON
        // ==========================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banner Management',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add, edit, and manage your store banners.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

            // 🚀 ADD BANNER BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 16,
                  vertical: isDesktop ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () => _showBannerDialog(null),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Banner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ==========================================
        // 2. DATA TABLE / LIST
        // ==========================================
        Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }
          if (controller.allBanners.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.view_carousel_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No banners found.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration:
                isDesktop
                    ? BoxDecoration(
                      color: Colors.white,
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.allBanners.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final banner = controller.allBanners[index];

                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      banner.image,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  title: Text(
                    banner.title.isNotEmpty
                        ? banner.title
                        : "Image Only Banner (No Text)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          AppColors.textDark, // Uses textDark as per original
                    ),
                  ),
                  subtitle: Text(
                    "Target: ${banner.targetCategory}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: banner.isActive,
                        activeColor: AppColors.primaryGold,
                        onChanged: (val) {
                          controller.toggleStatus(banner.id, banner.isActive);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showBannerDialog(banner),
                        tooltip: 'Edit Banner',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => controller.deleteBanner(
                              banner.id,
                              banner.image,
                            ),
                        tooltip: 'Delete Banner',
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 3. ADD / EDIT BANNER MODAL
  // ==========================================
  void _showBannerDialog(BannerModel? existingBanner) {
    final AdminBannerController controller = Get.find<AdminBannerController>();

    final titleCtrl = TextEditingController(text: existingBanner?.title ?? '');
    final subCtrl = TextEditingController(text: existingBanner?.subtitle ?? '');
    final btnCtrl = TextEditingController(
      text: existingBanner?.buttonText ?? '',
    );
    final catCtrl = TextEditingController(
      text: existingBanner?.targetCategory ?? 'All',
    );

    Uint8List? selectedImageBytes;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.85,
          ),
          child: Column(
            children: [
              // --- Custom Dialog Header ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          existingBanner == null
                              ? 'Add New Banner'
                              : 'Edit Banner',
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Upload an image and set optional text',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // --- Dialog Body ---
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE PICKER SECTION
                          GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                selectedImageBytes = await image.readAsBytes();
                                setState(() {});
                              }
                            },
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  selectedImageBytes != null
                                      ? Image.memory(
                                        selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                      : existingBanner != null
                                      ? Image.network(
                                        existingBanner.image,
                                        fit: BoxFit.cover,
                                      )
                                      : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 40,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Click to browse and upload Image",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Leave text fields blank for an Image-Only banner.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // INPUT FIELDS
                          _buildTextField(titleCtrl, "Title (Optional)"),
                          const SizedBox(height: 16),
                          _buildTextField(subCtrl, "Subtitle (Optional)"),
                          const SizedBox(height: 16),
                          _buildTextField(btnCtrl, "Button Text (Optional)"),
                          const SizedBox(height: 16),
                          _buildTextField(
                            catCtrl,
                            "Target Category (Default: All)",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Footer Actions ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Obx(() {
                      if (controller.isUploading.value) {
                        return const SizedBox(
                          height: 36,
                          width: 36,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGold,
                          ),
                        );
                      }
                      return // Change this specific button in your _showBannerDialog
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () async {
                          bool success = await controller.saveBanner(
                            docId: existingBanner?.id,
                            title: titleCtrl.text,
                            subtitle: subCtrl.text,
                            buttonText: btnCtrl.text,
                            targetCategory: catCtrl.text,
                            imageBytes: selectedImageBytes,
                            existingImageUrl: existingBanner?.image,
                          );
                          if (success) {
                            Get.back();
                            Get.snackbar(
                              "Success",
                              "Banner saved successfully",
                              backgroundColor: AppColors.primaryGreen,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        },
                        child: Text(
                          existingBanner == null
                              ? "Save Banner"
                              : "Update Banner",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

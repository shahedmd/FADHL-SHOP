import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/shipping_controller.dart';
import '../Utils/global_colours.dart';

class AdminShippingAreaView extends StatelessWidget {
  final bool isDesktop;
  const AdminShippingAreaView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminShippingController shippingController = Get.put(
      AdminShippingController(),
    );

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
                  'Shipping Areas & Pricing',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set custom delivery charges for every District and Thana.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openAddDistrictDialog(shippingController),
              icon: Icon(Icons.add_location_alt, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add New District' : 'Add District',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Obx(() {
          if (shippingController.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }

          if (shippingController.shippingAreas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  'No districts available. Add a new one to start setting prices.',
                ),
              ),
            );
          }

          return Container(
            decoration:
                isDesktop
                    ? BoxDecoration(
                      color: AppColors.pureWhite,
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
              itemCount: shippingController.shippingAreas.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                String district = shippingController.shippingAreas.keys
                    .elementAt(index);
                Map<String, dynamic> data =
                    shippingController.shippingAreas[district]!;

                double baseCharge = (data['_district_charge'] ?? 0).toDouble();
                List<String> thanas =
                    data.keys.where((k) => k != '_district_charge').toList()
                      ..sort();

                return ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        district,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Base: ৳${baseCharge.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${thanas.length} Thanas configured',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Delete District',
                        onPressed:
                            () => _confirmDeleteDistrict(
                              district,
                              shippingController,
                            ),
                      ),
                      const Icon(Icons.expand_more, color: Colors.grey),
                    ],
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: isDesktop ? 80 : 24,
                        right: 24,
                        bottom: 24,
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...thanas.map((thana) {
                            double thanaCharge = (data[thana] ?? 0).toDouble();
                            return Chip(
                              label: Text(
                                '$thana (৳${thanaCharge.toStringAsFixed(0)})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.grey.shade100,
                              deleteIcon: const Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onDeleted:
                                  () => _confirmDeleteThana(
                                    district,
                                    thana,
                                    shippingController,
                                  ),
                            );
                          }),
                          ActionChip(
                            label: const Text(
                              '+ Configure Thana',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            onPressed:
                                () => _openAddThanaDialog(
                                  district,
                                  shippingController,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // DIALOGS
  // ==========================================
  void _openAddDistrictDialog(AdminShippingController controller) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New District',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'District Name (e.g. Dhaka)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base Delivery Charge (৳)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.primaryGold,
                  ),
                  onPressed: () {
                    double charge = double.tryParse(priceCtrl.text) ?? 0.0;
                    controller.addDistrict(nameCtrl.text, charge);
                    Get.back();
                  },
                  child: const Text('SAVE DISTRICT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddThanaDialog(
    String district,
    AdminShippingController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Thana to $district',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Thana Name (e.g. Dhanmondi)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Specific Delivery Charge (৳)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.primaryGold,
                  ),
                  onPressed: () {
                    double charge = double.tryParse(priceCtrl.text) ?? 0.0;
                    controller.addThana(district, nameCtrl.text, charge);
                    Get.back();
                  },
                  child: const Text('SAVE THANA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteDistrict(
    String district,
    AdminShippingController controller,
  ) {
    Get.defaultDialog(
      title: 'Delete District?',
      middleText: 'Remove $district and ALL its configured thanas?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.deleteDistrict(district);
        Get.back();
      },
    );
  }

  void _confirmDeleteThana(
    String district,
    String thana,
    AdminShippingController controller,
  ) {
    Get.defaultDialog(
      title: 'Delete Thana?',
      middleText: 'Remove $thana from $district?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.removeThana(district, thana);
        Get.back();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/admin_about_us_controller.dart';
import '../Utils/global_colours.dart';

class AdminAboutUsView extends StatelessWidget {
  final bool isDesktop;
  AdminAboutUsView({super.key, required this.isDesktop});

  final List<Map<String, dynamic>> availableIcons = [
    {
      'name': 'truckFast',
      'icon': Icons.local_shipping_outlined,
      'label': 'Fast Delivery',
    },
    {
      'name': 'shieldHalved',
      'icon': Icons.shield_outlined,
      'label': 'Safe / Shield',
    },
    {
      'name': 'handshake',
      'icon': Icons.handshake_outlined,
      'label': 'Reliable / Trust',
    },
    {'name': 'leaf', 'icon': Icons.eco_outlined, 'label': 'Organic / Nature'},
    {
      'name': 'medal',
      'icon': Icons.military_tech_outlined,
      'label': 'Medal / Award',
    },
    {'name': 'gem', 'icon': Icons.diamond_outlined, 'label': 'Premium / Gem'},
    {'name': 'heart', 'icon': Icons.favorite, 'label': 'Heart / Care'},
    {'name': 'star', 'icon': Icons.star, 'label': 'Star / Top Rated'},
  ];

  IconData _getIconData(String iconName) {
    return availableIcons.firstWhere(
      (item) => item['name'] == iconName,
      orElse: () => availableIcons.first,
    )['icon'];
  }

  @override
  Widget build(BuildContext context) {
    final AdminAboutUsController controller = Get.put(AdminAboutUsController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage About Us',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edit your story and manage core values.',
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
              onPressed: () => _openAddValueDialog(controller),
              icon: Icon(Icons.add_box, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add Core Value' : 'Add Value',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 🚀 SECTION 1: MANAGE OUR STORY
        _buildStoryEditCard(controller, isDesktop),
        const SizedBox(height: 32),

        // SECTION 2: CORE VALUES LIST
        const Text(
          'Core Values (Why Choose Us)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }

          if (controller.coreValues.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No Core Values found. Add one above!'),
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
              itemCount: controller.coreValues.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final value = controller.coreValues[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      _getIconData(value['iconName'] ?? ''),
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    value['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value['description'] ?? '',
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(value['id'], controller),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // 🚀 OUR STORY EDIT CARD
  Widget _buildStoryEditCard(
    AdminAboutUsController controller,
    bool isDesktop,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Our Story Section',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
              IconButton(
                onPressed: () => _openEditStoryDialog(controller),
                icon: const Icon(
                  Icons.edit_square,
                  color: AppColors.primaryGold,
                ),
                tooltip: 'Edit Story',
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.storySubtitle.value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.storyBody.value,
              style: const TextStyle(color: Colors.grey, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DIALOGS
  // ==========================================
  void _openEditStoryDialog(AdminAboutUsController controller) {
    final headingCtrl = TextEditingController(
      text: controller.storyHeading.value,
    );
    final subCtrl = TextEditingController(text: controller.storySubtitle.value);
    final bodyCtrl = TextEditingController(text: controller.storyBody.value);

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Our Story',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: headingCtrl,
                decoration: const InputDecoration(
                  labelText: 'Small Heading (e.g. Our Story)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subCtrl,
                decoration: const InputDecoration(
                  labelText: 'Main Title (e.g. A Commitment...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Main Body Paragraph',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.primaryGold,
                  ),
                  onPressed: () {
                    controller.updateStory(
                      headingCtrl.text,
                      subCtrl.text,
                      bodyCtrl.text,
                    );
                    Get.back();
                  },
                  child: const Text(
                    'SAVE STORY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddValueDialog(AdminAboutUsController controller) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    RxString selectedIcon = 'truckFast'.obs;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Core Value',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. FAST)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Icon',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedIcon.value,
                  items:
                      availableIcons.map((iconMap) {
                        return DropdownMenuItem<String>(
                          value: iconMap['name'],
                          child: Row(
                            children: [
                              Icon(
                                iconMap['icon'],
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              Text(iconMap['label']),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (val) => selectedIcon.value = val!,
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.primaryGold,
                  ),
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) {
                      Get.snackbar('Error', 'Please fill all fields.');
                      return;
                    }
                    controller.addCoreValue(
                      titleCtrl.text,
                      descCtrl.text,
                      selectedIcon.value,
                    );
                    Get.back();
                  },
                  child: const Text(
                    'ADD CORE VALUE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, AdminAboutUsController controller) {
    Get.defaultDialog(
      title: 'Delete Core Value?',
      middleText:
          'Are you sure you want to remove this from the About Us page?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.deleteCoreValue(id);
        Get.back();
      },
    );
  }
}

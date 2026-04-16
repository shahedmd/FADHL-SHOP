import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Controllers/admin_faq_controller.dart';
import '../Utils/global_colours.dart';

class AdminFaqView extends StatelessWidget {
  final bool isDesktop;
  const AdminFaqView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminFaqController faqController = Get.put(AdminFaqController());

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
                  'Manage FAQs',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add, edit, or remove Frequently Asked Questions.',
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
              onPressed: () => _openFaqDialog(faqController, null),
              icon: Icon(Icons.add_comment, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add New FAQ' : 'Add FAQ',
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
          if (faqController.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }

          if (faqController.faqs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No FAQs found. Add one above!'),
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
              itemCount: faqController.faqs.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final faq = faqController.faqs[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.circleQuestion,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          faq['category'] ?? 'General',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          faq['q'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      faq['a'] ?? '',
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.primaryGold,
                        ),
                        onPressed: () => _openFaqDialog(faqController, faq),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed:
                            () => _confirmDelete(faq['id'], faqController),
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

  void _openFaqDialog(
    AdminFaqController controller,
    Map<String, dynamic>? faq,
  ) {
    final catCtrl = TextEditingController(text: faq?['category'] ?? '');
    final qCtrl = TextEditingController(text: faq?['q'] ?? '');
    final aCtrl = TextEditingController(text: faq?['a'] ?? '');
    final bool isEditing = faq != null;

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
              Text(
                isEditing ? 'Edit FAQ' : 'Add New FAQ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: catCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g. Shipping, Payments)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qCtrl,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Answer',
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
                    if (qCtrl.text.isEmpty ||
                        aCtrl.text.isEmpty ||
                        catCtrl.text.isEmpty) {
                      Get.snackbar('Error', 'Please fill all fields.');
                      return;
                    }
                    if (isEditing) {
                      controller.updateFaq(
                        faq['id'],
                        catCtrl.text,
                        qCtrl.text,
                        aCtrl.text,
                      );
                    } else {
                      controller.addFaq(catCtrl.text, qCtrl.text, aCtrl.text);
                    }
                    Get.back();
                  },
                  child: Text(
                    isEditing ? 'UPDATE FAQ' : 'SAVE FAQ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, AdminFaqController controller) {
    Get.defaultDialog(
      title: 'Delete FAQ?',
      middleText: 'Are you sure you want to remove this question?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.deleteFaq(id);
        Get.back();
      },
    );
  }
}

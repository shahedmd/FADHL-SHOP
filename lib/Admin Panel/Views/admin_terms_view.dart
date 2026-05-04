import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/admin_term_controller.dart';
import '../Utils/global_colours.dart';

class AdminTermsView extends StatelessWidget {
  final bool isDesktop;
  const AdminTermsView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminTermsController controller = Get.put(AdminTermsController());

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
                  'Manage Terms & Conditions',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add, edit, or remove sections from your Terms page.',
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
              onPressed: () => _openTermDialog(controller, null),
              icon: Icon(Icons.add_circle, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add New Section' : 'Add Section',
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
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            );
          }

          if (controller.terms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No terms found. Add a section above!'),
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
              itemCount: controller.terms.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final term = controller.terms[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: const Icon(
                      Icons.file_copy,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    term['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      term['content'] ?? '',
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                        onPressed: () => _openTermDialog(controller, term),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDelete(term['id'], controller),
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

  void _openTermDialog(
    AdminTermsController controller,
    Map<String, dynamic>? term,
  ) {
    final titleCtrl = TextEditingController(text: term?['title'] ?? '');
    final contentCtrl = TextEditingController(text: term?['content'] ?? '');
    final bool isEditing = term != null;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700, // Made wider for long texts
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Section' : 'Add New Section',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Section Title (e.g. 1. Introduction)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200, // Fixed height for easy pasting
                child: TextField(
                  controller: contentCtrl,
                  maxLines: null, // Allows infinite lines
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Content Body',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
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
                    if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) {
                      Get.snackbar('Error', 'Please fill all fields.');
                      return;
                    }
                    if (isEditing) {
                      controller.updateTerm(
                        term['id'],
                        titleCtrl.text,
                        contentCtrl.text,
                      );
                    } else {
                      controller.addTerm(titleCtrl.text, contentCtrl.text);
                    }
                    Get.back();
                  },
                  child: Text(
                    isEditing ? 'UPDATE SECTION' : 'SAVE SECTION',
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

  void _confirmDelete(String id, AdminTermsController controller) {
    Get.defaultDialog(
      title: 'Delete Section?',
      middleText:
          'Are you sure you want to remove this section from Terms & Conditions?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.deleteTerm(id);
        Get.back();
      },
    );
  }
}

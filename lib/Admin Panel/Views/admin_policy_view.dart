import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Controllers/admin_policy_controller.dart';
import '../Utils/global_colours.dart';

class AdminPolicyView extends StatelessWidget {
  final bool isDesktop;
  const AdminPolicyView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminPolicyController controller = Get.put(AdminPolicyController());

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
                  'Manage Policies',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Privacy, Refund, and Cancellation Policies.',
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
              onPressed: () => _openPolicyDialog(controller, null),
              icon: Icon(Icons.add_moderator, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Add New Policy' : 'Add Policy',
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

          if (controller.policies.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No policies found. Add one above!'),
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
              itemCount: controller.policies.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final policy = controller.policies[index];
                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.shieldHalved,
                      color: AppColors.primaryGreen,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    policy['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      policy['content'] ?? '',
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
                        onPressed: () => _openPolicyDialog(controller, policy),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed:
                            () => _confirmDelete(policy['id'], controller),
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

  void _openPolicyDialog(
    AdminPolicyController controller,
    Map<String, dynamic>? policy,
  ) {
    final titleCtrl = TextEditingController(text: policy?['title'] ?? '');
    final contentCtrl = TextEditingController(text: policy?['content'] ?? '');
    final bool isEditing = policy != null;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Policy' : 'Add New Policy',
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
                  labelText: 'Policy Title (e.g. Privacy Policy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: TextField(
                  controller: contentCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Policy Content',
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
                      controller.updatePolicy(
                        policy['id'],
                        titleCtrl.text,
                        contentCtrl.text,
                      );
                    } else {
                      controller.addPolicy(titleCtrl.text, contentCtrl.text);
                    }
                    Get.back();
                  },
                  child: Text(
                    isEditing ? 'UPDATE POLICY' : 'SAVE POLICY',
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

  void _confirmDelete(String id, AdminPolicyController controller) {
    Get.defaultDialog(
      title: 'Delete Policy?',
      middleText: 'Are you sure you want to remove this policy?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor: AppColors.pureWhite,
      onConfirm: () {
        controller.deletePolicy(id);
        Get.back();
      },
    );
  }
}

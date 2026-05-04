import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/admin_management_controller.dart';
import '../Utils/global_colours.dart'; // Ensure AppColors is inside this file

class AdminManagementView extends StatelessWidget {
  final bool isDesktop;
  const AdminManagementView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminManagementController adminController = Get.put(
      AdminManagementController(),
    );
    final AuthController authController = Get.find<AuthController>();

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
                  'Staff & Admins',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen, // Updated
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage who has access to the Admin Panel.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen, // Updated
                foregroundColor: AppColors.primaryGold, // Updated
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openCreateAdminDialog(adminController),
              icon: Icon(Icons.shield, size: isDesktop ? 20 : 18),
              label: Text(
                isDesktop ? 'Create New Admin' : 'New Admin',
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
          if (adminController.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ), // Updated from hardcoded hex
              ),
            );
          }

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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminController.adminUsers.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final admin = adminController.adminUsers[index];
                final bool isMe =
                    admin['uid'] == authController.firebaseUser.value?.uid;

                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.2,
                    ), // Updated
                    child: const Icon(
                      Icons.verified_user,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        admin['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              AppColors
                                  .textDark, // Updated to use dark brand text
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen, // Updated
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: AppColors.pureWhite, // Updated
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${admin['email']}  •  ${admin['phone']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing:
                      isMe
                          ? null
                          : IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Revoke Admin Access',
                            onPressed:
                                () => _confirmRevoke(
                                  admin,
                                  adminController,
                                  authController,
                                ),
                          ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  void _openCreateAdminDialog(AdminManagementController adminController) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.pureWhite, // Updated
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Admin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen, // Updated
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (min 6 chars)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen, // Updated
                      foregroundColor: AppColors.primaryGold, // Updated
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        adminController.isCreating.value
                            ? null
                            : () {
                              if (emailCtrl.text.isEmpty ||
                                  passCtrl.text.length < 6) {
                                Get.snackbar(
                                  'Error',
                                  'Valid email and 6+ char password required.',
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              adminController.createNewAdmin(
                                nameCtrl.text,
                                phoneCtrl.text,
                                emailCtrl.text,
                                passCtrl.text,
                              );
                            },
                    child:
                        adminController.isCreating.value
                            ? const CircularProgressIndicator(
                              color: AppColors.primaryGold, // Updated
                            )
                            : const Text(
                              'AUTHORIZE ADMIN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
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

  void _confirmRevoke(
    Map<String, dynamic> admin,
    AdminManagementController adminController,
    AuthController authController,
  ) {
    Get.defaultDialog(
      title: 'Revoke Access?',
      middleText:
          'Are you sure you want to remove admin privileges from ${admin['name']}?',
      textConfirm: 'Revoke',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      backgroundColor:
          AppColors.pureWhite, // Added to ensure dialog background is clean
      titleStyle: const TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
      ), // Updated
      middleTextStyle: const TextStyle(color: AppColors.textDark), // Updated
      onConfirm: () {
        adminController.revokeAdminAccess(
          admin['uid'],
          authController.firebaseUser.value!.uid,
        );
        Get.back();
      },
    );
  }
}

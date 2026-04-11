import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/authcontroller.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final userData = authController.userData.value;

    if (userData == null || userData['isAdmin'] != true) {
      Future.microtask(() {
        if (Get.isSnackbarOpen != true) {
          Get.snackbar(
            'Access Denied',
            'You do not have permission to view this page.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      });

      return const RouteSettings(name: '/');
    }
    return null;
  }
}
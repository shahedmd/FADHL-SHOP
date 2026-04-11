import 'package:get/get.dart';
import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:flutter/material.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // If there is no user logged in, send them instantly to /auth without rendering the profile page
    if (AuthController.instance.firebaseUser.value == null) {
      return const RouteSettings(name: '/auth');
    }
    return null; // Let them pass
  }
}
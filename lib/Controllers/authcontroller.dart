import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Admin Panel/Controllers/admin_customer_controller.dart';
import '../Admin Panel/Controllers/admin_management_controller.dart';
import '../Admin Panel/Controllers/admin_order_controller.dart';
import '../Admin Panel/Controllers/admin_product_controller.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);
  Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.value = _auth.currentUser;
    firebaseUser.bindStream(_auth.authStateChanges());

    // Only fetch data on load if a user is already logged in
    if (firebaseUser.value != null) {
      _fetchUserData(firebaseUser.value);
    }
  }

  // ==========================================
  // SIGN UP (REGISTER)
  // ==========================================
  Future<void> registerUser(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final userDoc = {
        'uid': userCredential.user!.uid,
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userDoc);

      // Update local data immediately without waiting for a stream
      userData.value = userDoc;

      _handleSuccessfulAuth(
        'Welcome to FADHL!',
        'Your account has been created successfully.',
      );
    } catch (e) {
      isLoading.value = false;
      _showErrorSnackbar('Registration Failed', e.toString());
    }
  }

  // ==========================================
  // LOG IN
  // ==========================================
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch user data BEFORE routing to prevent heavy rendering lag on the next page
      await _fetchUserData(userCredential.user);

      _handleSuccessfulAuth('Welcome!', 'You have successfully logged in.');
    } catch (e) {
      isLoading.value = false;
      _showErrorSnackbar('Login Failed', 'Invalid email or password');
    }
  }

  // Helper method to keep routing and UI updates clean
  void _handleSuccessfulAuth(String title, String message) {
    isLoading.value = false;

    // ==========================================
    // 🚀 THE FIX: SMART ADMIN ROUTING
    // ==========================================
    // 1. Check if the logged-in user is the Admin!
    final bool isAdmin =
        userData.value != null && userData.value!['isAdmin'] == true;

    String targetRoute = '/';

    if (isAdmin) {
      // If the Boss logs in, hijack the route and go straight to the Dashboard!
      targetRoute = '/admin';
    } else {
      // Normal Customer Routing (Preserves deep links!)
      if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/auth') {
        targetRoute = Get.previousRoute;
      }
    }

    // 2. Show the success Snackbar
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF0A1F13),
      colorText: const Color(0xFFCEAB5F),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    // 3. Force a clean route reload
    Future.microtask(() {
      Get.offAllNamed(targetRoute);
    });
  }

  Future<void> _fetchUserData(User? user) async {
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          userData.value = doc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint("Failed to fetch user data: $e");
      }
    } else {
      userData.value = null;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    if (Get.isRegistered<AdminOrderManagementController>()) {
      final adminOrderCtrl = Get.find<AdminOrderManagementController>();
      await adminOrderCtrl.closeAllStreams();
      Get.delete<AdminOrderManagementController>(force: true);
    }

    if (Get.isRegistered<AdminControllerProductmanagement>()) {
      Get.delete<AdminControllerProductmanagement>(force: true);
    }
    if (Get.isRegistered<AdminManagementController>()) {
      Get.delete<AdminManagementController>(force: true);
    }
    if (Get.isRegistered<AdminCustomerController>()) {
      Get.delete<AdminCustomerController>(force: true);
    }

    userData.value = null;

    await _auth.signOut();

    isLoading.value = false;

    Get.offAllNamed('/');
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

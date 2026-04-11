import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> adminUsers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isAdmin', isEqualTo: true)
              .get();
      adminUsers.value =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch admins.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 WORLD-CLASS FIX: Create user without logging out the current admin!
  Future<void> createNewAdmin(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    isCreating.value = true;
    FirebaseApp? tempApp;

    try {
      // 1. Initialize a temporary background Firebase App
      tempApp = await Firebase.initializeApp(
        name: 'TemporaryAdminApp',
        options: Firebase.app().options,
      );

      // 2. Create the user on the temporary app (Leaves main session untouched)
      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: tempApp,
      ).createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 3. Save their data to Firestore using the MAIN app (which has Admin write privileges)
      final newAdminData = {
        'uid': userCredential.user!.uid,
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'isAdmin': true, // 🚀 Give them the keys to the castle!
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newAdminData);

      // 4. Update UI instantly
      adminUsers.add(newAdminData);

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        '$name is now an Admin!',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      // 5. Safely destroy the temporary app
      if (tempApp != null) {
        await tempApp.delete();
      }
      isCreating.value = false;
    }
  }

  Future<void> revokeAdminAccess(String uid, String currentAdminUid) async {
    if (uid == currentAdminUid) {
      Get.snackbar(
        'Action Denied',
        'You cannot revoke your own admin access!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).update({'isAdmin': false});
      adminUsers.removeWhere((admin) => admin['uid'] == uid);
      Get.snackbar(
        'Revoked',
        'Admin privileges removed.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to revoke access.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}

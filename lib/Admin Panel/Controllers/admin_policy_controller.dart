import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminPolicyController extends GetxController {
  var policies = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPolicies();
  }

  Future<void> fetchPolicies() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await _firestore.collection('policies').orderBy('createdAt').get();
      policies.value =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load policies.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPolicy(String title, String content) async {
    try {
      await _firestore.collection('policies').add({
        'title': title.trim(),
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'Policy added successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchPolicies();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add policy.');
    }
  }

  Future<void> updatePolicy(String id, String title, String content) async {
    try {
      await _firestore.collection('policies').doc(id).update({
        'title': title.trim(),
        'content': content.trim(),
      });
      Get.snackbar(
        'Success',
        'Policy updated.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchPolicies();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update policy.');
    }
  }

  Future<void> deletePolicy(String id) async {
    try {
      await _firestore.collection('policies').doc(id).delete();
      Get.snackbar('Success', 'Policy deleted.');
      fetchPolicies();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete policy.');
    }
  }
}

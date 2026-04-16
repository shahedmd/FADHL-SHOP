import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminTermsController extends GetxController {
  var terms = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await _firestore
              .collection('terms_conditions')
              .orderBy('createdAt')
              .get();
      terms.value =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load terms.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTerm(String title, String content) async {
    try {
      await _firestore.collection('terms_conditions').add({
        'title': title.trim(),
        'content': content.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'Section added successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchTerms();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add section.');
    }
  }

  Future<void> updateTerm(String id, String title, String content) async {
    try {
      await _firestore.collection('terms_conditions').doc(id).update({
        'title': title.trim(),
        'content': content.trim(),
      });
      Get.snackbar(
        'Success',
        'Section updated.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchTerms();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update section.');
    }
  }

  Future<void> deleteTerm(String id) async {
    try {
      await _firestore.collection('terms_conditions').doc(id).delete();
      Get.snackbar('Success', 'Section deleted.');
      fetchTerms();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete section.');
    }
  }
}
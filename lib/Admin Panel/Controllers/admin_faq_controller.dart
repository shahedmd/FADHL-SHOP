import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminFaqController extends GetxController {
  var faqs = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await _firestore
              .collection('faqs')
              .orderBy('createdAt', descending: true)
              .get();
      faqs.value =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load FAQs.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFaq(String category, String question, String answer) async {
    try {
      await _firestore.collection('faqs').add({
        'category': category.trim(),
        'q': question.trim(),
        'a': answer.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'FAQ added successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchFaqs();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add FAQ.');
    }
  }

  Future<void> updateFaq(
    String id,
    String category,
    String question,
    String answer,
  ) async {
    try {
      await _firestore.collection('faqs').doc(id).update({
        'category': category.trim(),
        'q': question.trim(),
        'a': answer.trim(),
      });
      Get.snackbar(
        'Success',
        'FAQ updated successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchFaqs();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update FAQ.');
    }
  }

  Future<void> deleteFaq(String id) async {
    try {
      await _firestore.collection('faqs').doc(id).delete();
      Get.snackbar('Success', 'FAQ deleted.');
      fetchFaqs();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete FAQ.');
    }
  }
}

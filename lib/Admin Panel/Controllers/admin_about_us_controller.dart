import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAboutUsController extends GetxController {
  // Observables
  var coreValues = <Map<String, dynamic>>[].obs;

  var storyHeading = 'Our Story'.obs;
  var storySubtitle = 'A Commitment to Excellence.'.obs;
  var storyBody = 'Loading...'.obs;

  var isLoading = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    await Future.wait([fetchStory(), fetchCoreValues()]);
    isLoading.value = false;
  }

  // ==========================================
  // MANAGE OUR STORY
  // ==========================================
  Future<void> fetchStory() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('settings').doc('our_story').get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        storyHeading.value = data['heading'] ?? 'Our Story';
        storySubtitle.value = data['subtitle'] ?? 'A Commitment to Excellence.';
        storyBody.value = data['body'] ?? 'Welcome to FADHL.';
      }
    } catch (e) {
      debugPrint('Error loading story: $e');
    }
  }

  Future<void> updateStory(String heading, String subtitle, String body) async {
    try {
      await _firestore.collection('settings').doc('our_story').set({
        'heading': heading.trim(),
        'subtitle': subtitle.trim(),
        'body': body.trim(),
      }, SetOptions(merge: true));

      storyHeading.value = heading;
      storySubtitle.value = subtitle;
      storyBody.value = body;

      Get.snackbar(
        'Success',
        'Our Story updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update story.');
    }
  }

  // ==========================================
  // MANAGE CORE VALUES
  // ==========================================
  Future<void> fetchCoreValues() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('core_values').orderBy('createdAt').get();
      coreValues.value =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      debugPrint('Error loading core values: $e');
    }
  }

  Future<void> addCoreValue(
    String title,
    String description,
    String iconName,
  ) async {
    try {
      await _firestore.collection('core_values').add({
        'title': title.trim(),
        'description': description.trim(),
        'iconName': iconName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Success',
        'Core Value added.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchCoreValues();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add core value.');
    }
  }

  Future<void> deleteCoreValue(String id) async {
    try {
      await _firestore.collection('core_values').doc(id).delete();
      Get.snackbar('Success', 'Core Value removed.');
      fetchCoreValues();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove core value.');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AboutUsController extends GetxController {
  // Observables for Core Values
  var coreValues = <Map<String, dynamic>>[].obs;

  // 🚀 Observables for Our Story (with default fallbacks)
  var storyHeading = 'Our Story'.obs;
  var storySubtitle = 'A Commitment to Excellence.'.obs;
  var storyBody = 'Loading our story...'.obs;

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

  // 🚀 FETCH STORY FROM FIREBASE
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

  // FETCH CORE VALUES
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
}

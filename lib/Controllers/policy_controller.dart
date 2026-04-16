import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PolicyController extends GetxController {
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
      // Fetch ordered by creation time so they stay in the order you added them
      QuerySnapshot snapshot =
          await _firestore.collection('policies').orderBy('createdAt').get();

      policies.value =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Policies.');
    } finally {
      isLoading.value = false;
    }
  }
}
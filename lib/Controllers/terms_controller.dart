import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TermsController extends GetxController {
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
      // Fetch ordered by creation time so they stay in the order you added them
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
      Get.snackbar('Error', 'Failed to load Terms & Conditions.');
    } finally {
      isLoading.value = false;
    }
  }
}

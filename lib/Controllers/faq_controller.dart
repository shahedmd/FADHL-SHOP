import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FaqController extends GetxController {
  var faqs = <Map<String, dynamic>>[].obs;
  var categories = <String>['All'].obs;

  var selectedCategory = 'All'.obs;
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

      List<Map<String, dynamic>> loadedFaqs = [];
      Set<String> loadedCategories = {'All'};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        loadedFaqs.add(data);

        if (data['category'] != null &&
            data['category'].toString().isNotEmpty) {
          loadedCategories.add(data['category']);
        }
      }

      faqs.value = loadedFaqs;
      categories.value = loadedCategories.toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load FAQs.');
    } finally {
      isLoading.value = false;
    }
  }
}

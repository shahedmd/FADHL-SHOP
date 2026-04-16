import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminShippingController extends GetxController {
  // Uses Map format to store prices
  var shippingAreas = <String, Map<String, dynamic>>{}.obs;
  var isLoading = true.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchShippingAreas();
  }

  Future<void> fetchShippingAreas() async {
    try {
      isLoading.value = true;
      DocumentSnapshot doc =
          await _firestore.collection('settings').doc('shipping_areas').get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> rawData = doc.data() as Map<String, dynamic>;
        Map<String, Map<String, dynamic>> parsedData = {};

        rawData.forEach((key, value) {
          if (value is Map) {
            parsedData[key] = Map<String, dynamic>.from(value);
          }
        });

        // Sort keys alphabetically
        var sortedKeys = parsedData.keys.toList()..sort();
        Map<String, Map<String, dynamic>> sortedData = {
          for (var k in sortedKeys) k: parsedData[k]!,
        };

        shippingAreas.value = sortedData;
      } else {
        shippingAreas.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shipping areas.');
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 ADDS DISTRICT WITH BASE PRICE
  Future<void> addDistrict(String name, double charge) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    try {
      await _firestore.collection('settings').doc('shipping_areas').set({
        cleanName: {
          '_district_charge':
              charge, // This is the default price for the district
        },
      }, SetOptions(merge: true));

      Get.snackbar('Success', '$cleanName added!');
      fetchShippingAreas();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add district.');
    }
  }

  // 🚀 DELETES WHOLE DISTRICT
  Future<void> deleteDistrict(String name) async {
    try {
      await _firestore.collection('settings').doc('shipping_areas').update({
        name: FieldValue.delete(),
      });
      Get.snackbar('Success', '$name removed.');
      fetchShippingAreas();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove district.');
    }
  }

  // 🚀 ADDS THANA WITH SPECIFIC PRICE
  Future<void> addThana(
    String district,
    String thanaName,
    double charge,
  ) async {
    final cleanThana = thanaName.trim();
    if (cleanThana.isEmpty) return;

    try {
      // Firebase dot notation allows updating a nested map directly!
      await _firestore.collection('settings').doc('shipping_areas').update({
        '$district.$cleanThana': charge,
      });

      Get.snackbar('Success', '$cleanThana added to $district.');
      fetchShippingAreas();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add Thana.');
    }
  }

  // 🚀 DELETES A THANA
  Future<void> removeThana(String district, String thanaName) async {
    try {
      await _firestore.collection('settings').doc('shipping_areas').update({
        '$district.$thanaName': FieldValue.delete(),
      });
      Get.snackbar('Success', '$thanaName removed.');
      fetchShippingAreas();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove Thana.');
    }
  }
}

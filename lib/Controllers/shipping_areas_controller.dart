import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  // Now stores Data as: { "Dhaka": { "_district_charge": 60, "Mirpur": 70, "Dhanmondi": 60 } }
  RxMap<String, Map<String, dynamic>> locationData =
      <String, Map<String, dynamic>>{}.obs;

  RxList<String> districts = <String>[].obs;
  RxList<String> currentThanas = <String>[].obs;

  RxnString selectedDistrict = RxnString();
  RxnString selectedThana = RxnString();

  RxBool isLoadingLocations = true.obs;

  // The magic variable that the CartController listens to!
  RxDouble currentDeliveryCharge = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      isLoadingLocations.value = true;
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('settings')
              .doc('shipping_areas')
              .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, Map<String, dynamic>> parsedData = {};

        data.forEach((key, value) {
          if (value is Map) {
            parsedData[key] = Map<String, dynamic>.from(value);
          }
        });

        locationData.value = parsedData;
        districts.value = parsedData.keys.toList()..sort();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load locations.');
    } finally {
      isLoadingLocations.value = false;
    }
  }

  void onDistrictChanged(String? newDistrict) {
    selectedDistrict.value = newDistrict;
    selectedThana.value = null; // Reset thana when district changes

    if (newDistrict != null && locationData.containsKey(newDistrict)) {
      Map<String, dynamic> districtData = locationData[newDistrict]!;

      // 🚀 1. Set the Default Charge for the District
      currentDeliveryCharge.value =
          (districtData['_district_charge'] ?? 0).toDouble();

      // 🚀 2. Load the Thanas (filtering out our secret _district_charge key)
      currentThanas.value =
          districtData.keys.where((k) => k != '_district_charge').toList()
            ..sort();
    } else {
      currentThanas.clear();
      currentDeliveryCharge.value = 0.0;
    }
  }

  // 🚀 NEW: When a Thana is picked, update the charge to the Thana's specific price!
  void onThanaChanged(String? newThana) {
    selectedThana.value = newThana;

    if (selectedDistrict.value != null && newThana != null) {
      Map<String, dynamic> dData = locationData[selectedDistrict.value]!;
      // Use Thana charge, if missing fall back to District charge
      currentDeliveryCharge.value =
          (dData[newThana] ?? dData['_district_charge'] ?? 0).toDouble();
    } else if (selectedDistrict.value != null) {
      // Revert to district base charge if they unselected a Thana
      currentDeliveryCharge.value =
          (locationData[selectedDistrict.value]!['_district_charge'] ?? 0)
              .toDouble();
    }
  }
}

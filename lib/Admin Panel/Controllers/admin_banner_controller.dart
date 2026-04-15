// lib/Admin Panel/Controllers/admin_banner_controller.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../Models/bannermodel.dart';

class AdminBannerController extends GetxController {
  final RxList<BannerModel> allBanners = <BannerModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllBanners();
  }

  // Fetch ALL banners (active and inactive) with Real-time Stream
  void fetchAllBanners() {
    FirebaseFirestore.instance.collection('Banners').snapshots().listen((
      snapshot,
    ) {
      // 🚀 FIX: Use assignAll() instead of .value for RxList to force UI refresh
      allBanners.assignAll(
        snapshot.docs.map((doc) {
          return BannerModel.fromMap(doc.data(), doc.id);
        }).toList(),
      );
      isLoading.value = false;
    });
  }

  // Toggle active status
  Future<void> toggleStatus(String id, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('Banners').doc(id).update({
      'isActive': !currentStatus,
    });
  }

  // Delete banner
  Future<void> deleteBanner(String id, String imageUrl) async {
    try {
      // 1. Delete from Firestore
      await FirebaseFirestore.instance.collection('Banners').doc(id).delete();
      // 2. Delete from Storage
      if (imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      Get.snackbar("Success", "Banner deleted successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Pick Image and Save/Update Banner (Returns bool to tell UI when to close)
  Future<bool> saveBanner({
    String? docId,
    required String title,
    required String subtitle,
    required String buttonText,
    required String targetCategory,
    Uint8List? imageBytes,
    String? existingImageUrl,
  }) async {
    try {
      isUploading.value = true; // Show loading spinner
      String imageUrl = existingImageUrl ?? '';

      // If user selected a new image, upload it
      if (imageBytes != null) {
        String fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(
          'Banners/$fileName',
        );

        UploadTask uploadTask = ref.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (imageUrl.isEmpty) {
        Get.snackbar("Error", "Please select an image");
        return false; // Stop process
      }

      // Create Map
      Map<String, dynamic> data = {
        'image': imageUrl,
        'title': title.trim(),
        'subtitle': subtitle.trim(),
        'buttonText': buttonText.trim(),
        'targetCategory':
            targetCategory.trim().isEmpty ? 'All' : targetCategory.trim(),
      };

      if (docId == null) {
        // Create new
        data['isActive'] = true; // Default to true when creating
        await FirebaseFirestore.instance.collection('Banners').add(data);
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection('Banners')
            .doc(docId)
            .update(data);
      }

      return true; // 🚀 Return true to tell the View to close the dialog
    } catch (e) {
      Get.snackbar("Error", "Failed to save banner: $e");
      return false; // Return false so dialog stays open if error
    } finally {
      isUploading.value = false; // Hide loading spinner
    }
  }
}
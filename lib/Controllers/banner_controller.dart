import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fadhl/Models/bannermodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  // 1. Safe initialization to prevent code cutoff
  final RxList<BannerModel> banners = RxList<BannerModel>();
  final RxBool isLoading = true.obs;
  final RxInt currentIndex = 0.obs;

  late PageController pageController;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    fetchBanners(); // Fetch from Firebase instantly
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  // Fetch only active banners from Firestore
  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('Banners')
              .where('isActive', isEqualTo: true)
              .get();

      banners.value =
          snapshot.docs.map((doc) {
            return BannerModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      // Start the auto-slider if we have banners
      if (banners.isNotEmpty) {
        startAutoPlay();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Auto-play logic (Slides every 5 seconds)
  void startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // ==========================================
      // 🚀 THE FIX: Ghost Screen Collision Check!
      // It will only slide if it is attached to exactly ONE screen.
      // ==========================================
      if (pageController.hasClients &&
          pageController.positions.length == 1 &&
          banners.isNotEmpty) {
        int nextPage = currentIndex.value + 1;

        if (nextPage >= banners.length) {
          nextPage = 0;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  // Updates the dot indicator when swiped manually
  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
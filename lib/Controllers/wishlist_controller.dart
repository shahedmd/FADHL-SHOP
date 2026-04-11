import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/productmodel.dart';

class WishlistController extends GetxController {
  // Reactive list of saved products
  var wishlistItems = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWishlistFromStorage();
    // GETX MAGIC: Save to hard drive every time the list changes!
    ever(wishlistItems, (_) => _saveWishlistToStorage());
  }

  // ==========================================
  // HARD DRIVE STORAGE (Wasm Compliant)
  // ==========================================
  Future<void> _saveWishlistToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> data =
        wishlistItems.map((item) => item.toMap()).toList();
    await prefs.setString('my_fadhl_wishlist', json.encode(data));
  }

  Future<void> _loadWishlistFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('my_fadhl_wishlist');

    if (savedData != null) {
      List<dynamic> decodedData = json.decode(savedData);
      wishlistItems.value =
          decodedData
              .map(
                (e) => ProductModel.fromMap(e as Map<String, dynamic>, e['id']),
              )
              .toList();
    }
  }

  // ==========================================
  // ACTIONS
  // ==========================================
  bool isFavorite(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isFavorite(product.id)) {
      wishlistItems.removeWhere((item) => item.id == product.id);
      Get.snackbar(
        'Removed',
        '${product.name} removed from wishlist.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      wishlistItems.add(product);
      Get.snackbar(
        'Saved!',
        '${product.name} added to wishlist.',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
        duration: const Duration(seconds: 1),
      );
    }
  }
}

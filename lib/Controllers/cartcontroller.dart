import 'dart:convert'; // Needed for JSON encoding/decoding
import 'package:fadhl/Controllers/shipping_areas_controller.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wasm-compliant storage


// 1. The Cart Item Model
class CartItem {
  final ProductModel product;
  RxInt quantity;

  CartItem({required this.product, required int initialQuantity})
    : quantity = initialQuantity.obs;

  Map<String, dynamic> toJson() => {
    'product': product.toMap(),
    'quantity': quantity.value,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: ProductModel.fromMap(json['product'], json['product']['id']),
    initialQuantity: json['quantity'],
  );
}

// 2. The Wasm-Compliant Cart Controller
class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Load the saved cart asynchronously
    _loadCartFromStorage();

    // 2. Save to SharedPreferences every time the cart changes
    ever(cartItems, (_) => _saveCartToStorage());
  }

  // ==========================================
  // WASM-COMPLIANT STORAGE LOGIC
  // ==========================================
  Future<void> _saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cartData =
        cartItems.map((item) => item.toJson()).toList();
    // Convert to a JSON string and save
    await prefs.setString('my_fadhl_cart', json.encode(cartData));
  }

  Future<void> _loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('my_fadhl_cart');

    if (savedData != null) {
      // Decode the JSON string back into objects
      List<dynamic> decodedData = json.decode(savedData);
      cartItems.value =
          decodedData
              .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList();
    }
  }

  // ==========================================
  // CART ACTIONS
  // ==========================================
  void addToCart(ProductModel product, int quantity) {
    int existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity.value += quantity;
      cartItems.refresh(); // Triggers save

      Get.snackbar(
        'Cart Updated',
        '${product.name} quantity increased!',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      cartItems.add(CartItem(product: product, initialQuantity: quantity));

      Get.snackbar(
        'Added to Cart',
        '${product.name} was added to your bag.',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void increaseQuantity(CartItem item) {
    item.quantity.value++;
    cartItems.refresh();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity.value > 1) {
      item.quantity.value--;
      cartItems.refresh();
    } else {
      removeFromCart(item.product.id);
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  // ==========================================
  // CALCULATIONS (UPDATED FOR DYNAMIC PRICING)
  // ==========================================
  int get totalItems => cartItems.length;

  double get subtotal {
    double total = 0;
    for (var item in cartItems) {
      total += (item.product.price * item.quantity.value);
    }
    return total;
  }

  // 🚀 THE FIX: NO MORE HARDCODED 120!
  double get deliveryCharge {
    // If cart is empty, shipping is 0
    if (subtotal == 0) return 0.0;

    // Grab the exact charge from LocationController
    if (Get.isRegistered<LocationController>()) {
      return Get.find<LocationController>().currentDeliveryCharge.value;
    }
    return 0.0;
  }

  double get grandTotal => subtotal + deliveryCharge;
}

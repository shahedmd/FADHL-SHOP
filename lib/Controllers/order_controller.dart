import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fadhl/Controllers/cartcontroller.dart';
import 'package:fadhl/Models/ordermodel.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> myOrders = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingOrders = false.obs;

  String generateOrderId() {
    final now = DateTime.now();
    final randomPart = now.millisecondsSinceEpoch.toString().substring(9);
    return 'ORD-${now.day}${now.month}-$randomPart';
  }

  // ==========================================
  // SAVE WHATSAPP ORDER TO FIREBASE
  // ==========================================
  Future<String> createWhatsAppOrder({
    required ProductModel product,
    required int quantity,
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) async {
    final String orderId = generateOrderId();

    try {
      // Push the order to the 'Orders' collection
      await _firestore.collection('Orders').doc(orderId).set({
        'orderId': orderId,
        'source': 'WhatsApp Direct', // Lets you know HOW they ordered
        'status': 'Pending - WhatsApp', // Needs admin to reply in chat
        'createdAt': FieldValue.serverTimestamp(),
        'totalAmount': product.price * quantity,

        // Inject the actual user data we passed in!
        'customerName': customerName,
        'customerId': customerId,
        'customerPhone': customerPhone,

        'shippingAddress': 'Pending',
        'orderstatus': 'Pending',
        'adminfeedback': 'No Feedback',
        'items': [
          {
            'productId': product.id,
            'name': product.name,
            'price': product.price,
            'quantity': quantity,
            'image': product.images.isNotEmpty ? product.images[0] : '',
          },
        ],
      });
    } catch (e) {
      debugPrint("Failed to save WhatsApp order to Firebase: $e");
    }

    return orderId;
  }

  // ==========================================
  // SAVE WEBSITE CHECKOUT TO FIREBASE
  // ==========================================
  // CHANGED: Now returns a Future<String?> instead of Future<bool>
  Future<String?> placeWebsiteOrder({
    required String name,
    required String phone,
    required String district,
    required String thana,
    required String address,
    required String billingName,
    required String billingAddress,
    required String paymentMethod,
    required String notes,
  }) async {
    final String orderId = generateOrderId();
    final CartController cart = Get.find<CartController>();

    final User? user = FirebaseAuth.instance.currentUser;
    final String customerId = user != null ? user.uid : 'Guest';

    List<Map<String, dynamic>> orderItems =
        cart.cartItems.map((item) {
          return {
            'productId': item.product.id,
            'name': item.product.name,
            'price': item.product.price,
            'quantity': item.quantity.value,
            'image':
                item.product.images.isNotEmpty ? item.product.images[0] : '',
          };
        }).toList();

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
        ),
        barrierDismissible: false,
      );

      await _firestore.collection('Orders').doc(orderId).set({
        'orderId': orderId,
        'source': 'Website Checkout',
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'customerId': customerId,
        'customerName': name,
        'customerPhone': phone,
        'shippingAddress': '$address, $thana, $district',
        'billingName': billingName.isEmpty ? name : billingName,
        'billingAddress':
            billingAddress.isEmpty
                ? '$address, $thana, $district'
                : billingAddress,
        'paymentMethod': paymentMethod,
        'subtotal': cart.subtotal,
        'deliveryCharge': cart.deliveryCharge,
        'totalAmount': cart.grandTotal,
        'items': orderItems,
        'specialNotes': notes,
        'adminFeedback': 'No Feedback',
      });

      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();

      cart.clearCart();

      // 🚀 THE FIX: Return the generated Order ID instead of 'true'!
      return orderId;
    } catch (e) {
      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
      Get.snackbar(
        'Checkout Failed',
        'Something went wrong: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      // Return null if it fails
      return null;
    }
  }

  // Make sure to import your new model at the top!
  // import '../models/order_model.dart';

  // ==========================================
  // TRACK ORDER LOGIC
  // ==========================================
  Future<void> trackOrder(String inputOrderId) async {
    final String cleanId = inputOrderId.trim();

    if (cleanId.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a valid Order ID.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // 1. Show Loading Dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
        ),
        barrierDismissible: false,
      );

      // 2. Search Firebase
      DocumentSnapshot doc =
          await _firestore.collection('Orders').doc(cleanId).get();

      // 3. Close Loading Dialog
      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();

      // 4. Validate and Route!
      if (doc.exists) {
        // Convert to our safe Model
        OrderModel foundOrder = OrderModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        // Close the tracking input dialog first!
        if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();

        // Route to the Tracking Screen, passing the order in memory
        Get.toNamed('/track-order', arguments: foundOrder);
      } else {
        Get.snackbar(
          'Not Found',
          'We could not find an order with ID: $cleanId',
          backgroundColor: const Color(0xFF0A1F13),
          colorText: const Color(0xFFCEAB5F),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
      Get.snackbar(
        'Error',
        'Failed to search for order. Check your internet connection.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchMyOrders() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      isLoadingOrders.value = true;

      // Query Firebase for ONLY their orders
      QuerySnapshot snapshot =
          await _firestore
              .collection('Orders')
              .where('customerId', isEqualTo: user.uid)
              .get();

      List<Map<String, dynamic>> orders =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      // World-Class sorting (Newest orders at the top)
      orders.sort((a, b) {
        Timestamp? timeA = a['createdAt'] as Timestamp?;
        Timestamp? timeB = b['createdAt'] as Timestamp?;
        if (timeA == null || timeB == null) return 0;
        return timeB.compareTo(timeA);
      });

      myOrders.value = orders;
    } catch (e) {
      debugPrint("Failed to fetch orders: $e");
    } finally {
      isLoadingOrders.value = false;
    }
  }
}

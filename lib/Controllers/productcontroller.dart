import 'package:fadhl/Controllers/order_controller.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ProductController extends GetxController {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  // ==========================================
  // 🚀 THE FIX: REACTIVE DYNAMIC CATEGORIES
  // ==========================================
  final RxList<String> categories = ['All'].obs; // Starts with just 'All'

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // 3. Fetch Data from Firebase
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Products').get();

      products.value =
          snapshot.docs.map((doc) {
            return ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      // ==========================================
      // 🚀 WORLD-CLASS DYNAMIC EXTRACTION
      // Extracts unique categories from the database automatically!
      // ==========================================
      final Set<String> uniqueCategories = {'All'}; // 'All' stays at the front
      for (var product in products) {
        if (product.category.isNotEmpty) {
          uniqueCategories.add(
            product.category,
          ); // Adds it to the set (prevents duplicates)
        }
      }
      categories.value = uniqueCategories.toList(); // Updates the UI instantly!
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load products. Check your internet connection.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // WORLD-CLASS BUSINESS LOGIC (WhatsApp Order)
  // ==========================================
  Future<void> orderViaWhatsApp(ProductModel product, int quantity) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFFCEAB5F))),
      barrierDismissible: false,
    );

    String cId = 'Unknown (WhatsApp)';
    String cName = 'Unknown (WhatsApp)';
    String cPhone = 'Pending';

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cId = user.uid;
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          cName = data['name'] ?? 'Unknown';
          cPhone = data['phone'] ?? 'Pending';
        }
      } catch (e) {
        debugPrint("Error fetching user for WhatsApp: $e");
      }
    }

    final OrderController orderController = Get.find<OrderController>();
    final String generatedOrderId = await orderController.createWhatsAppOrder(
      product: product,
      quantity: quantity,
      customerId: cId,
      customerName: cName,
      customerPhone: cPhone,
    );

    if (Get.isDialogOpen == true) {
      Navigator.of(Get.overlayContext!).pop();
    }

    final String phoneNumber = "8801946401297";
    final String productUrl = "https://fadhlshop.web.app/product/${product.id}";

    String message =
        "Hello FADHL! I want to place an order.\n\n*Order Ref:* $generatedOrderId\n*Product:* ${product.name}\n*Quantity:* $quantity\n*Link:* $productUrl\n";

    if (user != null) {
      message += "\n*My Details:*\n*Name:* $cName\n*Phone:* $cPhone\n";
    }

    message += "\nPlease confirm my order!";

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366),
                    size: 45,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Almost There!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A1F13),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Your Order Reference is '),
                      TextSpan(
                        text: generatedOrderId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCEAB5F),
                        ),
                      ),
                      const TextSpan(
                        text:
                            '.\n\nPlease hit "Send" in WhatsApp to confirm your order with our team!',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A1F13),
                      foregroundColor: const Color(0xFFCEAB5F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (Get.isDialogOpen == true) {
                        Navigator.of(Get.overlayContext!).pop();
                      }
                    },
                    child: const Text(
                      'GOT IT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp.',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
      );
    }
  }

  // 4. The Magic Filter (Getter)
  List<ProductModel> get filteredProducts {
    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.value) ||
          product.category.toLowerCase().contains(searchQuery.value);
      final matchesCategory =
          selectedCategory.value == 'All' ||
          product.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // 5. Update Methods
  void updateSearch(String query) => searchQuery.value = query.toLowerCase();
  void updateCategory(String category) => selectedCategory.value = category;

  Future<bool> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please write a review comment.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
        ),
        barrierDismissible: false,
      );

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      String realName =
          userDoc.data() != null
              ? (userDoc.data() as Map<String, dynamic>)['name'] ??
                  'Verified Customer'
              : 'Verified Customer';

      final newReview = {
        'reviewerName': realName,
        'customerId': user.uid,
        'rating': rating,
        'comment': comment.trim(),
        'date': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .update({
            'reviews': FieldValue.arrayUnion([newReview]),
          });

      int index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        products[index].reviews.add(newReview);
        products.refresh();
      }

      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
      Get.snackbar(
        'Thank You!',
        'Your review has been submitted.',
        backgroundColor: const Color(0xFF0A1F13),
        colorText: const Color(0xFFCEAB5F),
      );

      return true;
    } catch (e) {
      if (Get.isDialogOpen == true) Navigator.of(Get.overlayContext!).pop();
      Get.snackbar(
        'Error',
        'Failed to submit review. $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
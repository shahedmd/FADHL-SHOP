import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fadhl/Models/productmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminControllerProductmanagement extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isUploading = false.obs;
  final RxList<ProductModel> tableProducts = <ProductModel>[].obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxBool isLoadingTable = true.obs;
  final int _limit = 20;
  DocumentSnapshot? _lastVisible;
  final List<DocumentSnapshot> _pageStarts = [];
  final RxBool hasNextPage = true.obs;
  final RxInt currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts(isRefresh: true);
  }

  // Extracts distinct categories automatically from DB safely
  Future<void> fetchCategories() async {
    try {
      final snap = await _firestore.collection('Products').get();
      final Set<String> cats = {};

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data.containsKey('category') && data['category'] != null) {
          String catValue = data['category'].toString().trim();
          if (catValue.isNotEmpty) {
            cats.add(catValue);
          }
        }
      }

      availableCategories.assignAll(cats.toList());
    } catch (e) {
      debugPrint("Failed to fetch categories: $e");
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isLoadingTable.value = true;
        _lastVisible = null;
        _pageStarts.clear();
        currentPage.value = 1;
        hasNextPage.value = true;
      }

      Query query = _firestore.collection('Products').limit(_limit);
      if (_lastVisible != null) query = query.startAfterDocument(_lastVisible!);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        if (_pageStarts.length < currentPage.value) {
          _pageStarts.add(snapshot.docs.first);
        }
        _lastVisible = snapshot.docs.last;

        List<ProductModel> fetched =
            snapshot.docs
                .map(
                  (doc) => ProductModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ),
                )
                .toList();

        fetched.sort((a, b) => a.category.compareTo(b.category));
        tableProducts.value = fetched;

        hasNextPage.value = snapshot.docs.length == _limit;
      } else {
        if (isRefresh) tableProducts.clear();
        hasNextPage.value = false;
      }
    } catch (e) {
      debugPrint("Fetch Products Error: $e");
    } finally {
      isLoadingTable.value = false;
    }
  }

  void nextPage() {
    if (hasNextPage.value) {
      currentPage.value++;
      fetchProducts();
    }
  }

  void previousPage() async {
    if (currentPage.value > 1) {
      currentPage.value--;
      isLoadingTable.value = true;
      DocumentSnapshot startDoc = _pageStarts[currentPage.value - 1];
      QuerySnapshot snapshot =
          await _firestore
              .collection('Products')
              .startAtDocument(startDoc)
              .limit(_limit)
              .get();
      _lastVisible = snapshot.docs.last;
      List<ProductModel> fetched =
          snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
      fetched.sort((a, b) => a.category.compareTo(b.category));
      tableProducts.value = fetched;
      hasNextPage.value = true;
      isLoadingTable.value = false;
    }
  }

  // Advanced Search By Category & Name
  Future<void> searchProducts(String nameQuery, String categoryQuery) async {
    if (nameQuery.trim().isEmpty &&
        (categoryQuery.isEmpty || categoryQuery == 'All Categories')) {
      fetchProducts(isRefresh: true);
      return;
    }

    try {
      isLoadingTable.value = true;
      Query query = _firestore.collection('Products');

      if (categoryQuery.isNotEmpty && categoryQuery != 'All Categories') {
        query = query.where('category', isEqualTo: categoryQuery);
      }

      QuerySnapshot snapshot = await query.get();
      List<ProductModel> results =
          snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      if (nameQuery.trim().isNotEmpty) {
        results =
            results
                .where(
                  (p) => p.name.toLowerCase().contains(nameQuery.toLowerCase()),
                )
                .toList();
      }

      results.sort((a, b) => a.category.compareTo(b.category));
      tableProducts.value = results;
      hasNextPage.value = false;
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isLoadingTable.value = false;
    }
  }

  Future<List<String>> uploadProductImages(
    List<Uint8List> imageBytesList,
    List<String> fileNames,
  ) async {
    List<String> downloadUrls = [];
    isUploading.value = true;
    try {
      for (int i = 0; i < imageBytesList.length; i++) {
        String uniqueName =
            '${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
        Reference ref = FirebaseStorage.instance.ref().child(
          'Product_Images/$uniqueName',
        );
        UploadTask uploadTask = ref.putData(
          imageBytesList[i],
          SettableMetadata(contentType: 'image/webp'),
        );
        TaskSnapshot snapshot = await uploadTask;
        downloadUrls.add(await snapshot.ref.getDownloadURL());
      }
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Failed to upload images',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
    return downloadUrls;
  }

  // 🚀 REACTIVE SAVE (Auto-Refreshes UI & Prevents GetX Route Crashes!)
  Future<void> saveProduct(ProductModel product, {bool isNew = true}) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
        ),
        barrierDismissible: false,
      );

      if (isNew) {
        await _firestore
            .collection('Products')
            .doc(product.id)
            .set(product.toMap());
        tableProducts.insert(0, product); // Add to UI instantly
      } else {
        await _firestore
            .collection('Products')
            .doc(product.id)
            .update(product.toMap());
        int index = tableProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) tableProducts[index] = product; // Update UI instantly
      }

      if (!availableCategories.contains(product.category)) {
        availableCategories.add(product.category);
      }

      tableProducts.refresh(); // Refresh screen

      // 🚀 THE FIX: Use native Navigator to pop safely, bypassing the GetX Snackbar controller bug!
      if (Get.isDialogOpen == true) {
        Navigator.of(
          Get.overlayContext!,
          rootNavigator: true,
        ).pop(); // Close Loading Spinner
      }
      Navigator.of(
        Get.overlayContext!,
        rootNavigator: true,
      ).pop(); // Close the Product Modal

      // Delay the Snackbar by 300ms so the UI has time to close the dialog properly
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          'Product saved!',
          backgroundColor: const Color(0xFF0A1F13),
          colorText: const Color(0xFFCEAB5F),
        );
      });
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Navigator.of(
          Get.overlayContext!,
          rootNavigator: true,
        ).pop(); // Close Loading Spinner only
      }
      Get.snackbar(
        'Error',
        'Failed to save.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('Products').doc(productId).delete();
      tableProducts.removeWhere((p) => p.id == productId);
      tableProducts.refresh();
      Get.snackbar(
        'Deleted',
        'Product removed.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminOrderManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final RxList<Map<String, dynamic>> pendingOrders =
      <Map<String, dynamic>>[].obs;
  bool _isFirstLoad = true;

  final RxList<Map<String, dynamic>> tableOrders = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingTable = true.obs;

  // Filter Observable
  final RxString currentFilter = 'All'.obs;

  final int _limit = 20;
  DocumentSnapshot? _lastVisible;
  final List<DocumentSnapshot> _pageStarts = [];
  final RxBool hasNextPage = true.obs;
  final RxInt currentPage = 1.obs;

  final Map<String, Map<String, dynamic>> _pendingOrdersMap = {};
  int _listenInitCount = 0;

  StreamSubscription<QuerySnapshot>? _websiteStream;
  StreamSubscription<QuerySnapshot>? _whatsappStream;

  final List<String> _pendingKeywords = [
    'Pending',
    'pending',
    'PENDING',
    'Pending - WhatsApp',
    'Pending ',
    'pending ',
  ];

  void _showSafeSnackbar(
    String title,
    String message, {
    Color? bgColor,
    Color? textColor,
    Icon? icon,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: bgColor ?? const Color(0xFF0A1F13),
      colorText: textColor ?? const Color(0xFFCEAB5F),
      icon: icon,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _listenToPendingOrders();
    fetchOrders(isRefresh: true);
  }

  Future<void> closeAllStreams() async {
    await _websiteStream?.cancel();
    await _whatsappStream?.cancel();
    _websiteStream = null;
    _whatsappStream = null;
  }

  @override
  void onClose() {
    closeAllStreams();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _listenToPendingOrders() {
    void handleStreamUpdate(QuerySnapshot snapshot) {
      bool hasNew = false;
      int newCount = 0;

      for (var change in snapshot.docChanges) {
        String docId = change.doc.id;
        if (change.type == DocumentChangeType.added) {
          if (!_isFirstLoad && !_pendingOrdersMap.containsKey(docId)) {
            hasNew = true;
            newCount++;
          }
          _pendingOrdersMap[docId] = change.doc.data() as Map<String, dynamic>;
        } else if (change.type == DocumentChangeType.modified) {
          _pendingOrdersMap[docId] = change.doc.data() as Map<String, dynamic>;
        } else if (change.type == DocumentChangeType.removed) {
          _pendingOrdersMap.remove(docId);
        }
      }

      if (hasNew && !_isFirstLoad) {
        _playOrderSound();
        _showSafeSnackbar(
          '🚨 NEW ORDER!',
          'You have $newCount new pending order(s).',
          bgColor: const Color(0xFF25D366),
          textColor: Colors.white,
        );
      }

      var pOrders = _pendingOrdersMap.values.toList();
      pOrders.sort((a, b) {
        Timestamp tA = a['createdAt'] ?? Timestamp.now();
        Timestamp tB = b['createdAt'] ?? Timestamp.now();
        return tB.compareTo(tA);
      });

      final uniqueOrders = <String, Map<String, dynamic>>{};
      for (var o in pOrders) {
        String safeId = o['orderId']?.toString() ?? 'missing_id_${o.hashCode}';
        uniqueOrders[safeId] = o;
      }

      pendingOrders.value = uniqueOrders.values.toList();
    }

    _websiteStream = _firestore
        .collection('Orders')
        .where('status', whereIn: _pendingKeywords)
        .snapshots()
        .listen((snap) {
          handleStreamUpdate(snap);
          _listenInitCount++;
          if (_listenInitCount >= 2) _isFirstLoad = false;
        });

    _whatsappStream = _firestore
        .collection('Orders')
        .where('orderstatus', whereIn: _pendingKeywords)
        .snapshots()
        .listen((snap) {
          handleStreamUpdate(snap);
          _listenInitCount++;
          if (_listenInitCount >= 2) _isFirstLoad = false;
        });
  }

  void _playOrderSound() async {
    try {
      await _audioPlayer.play(
        UrlSource(
          'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3',
        ),
      );
    } catch (e) {
      debugPrint("Sound error: $e");
    }
  }

  // 🚀 Set the filter and immediately refresh the table
  void setFilter(String filter) {
    if (currentFilter.value == filter) return;
    currentFilter.value = filter;
    fetchOrders(isRefresh: true);
  }

  // 🚀 Dynamically creates the query based on your EXACT DB SCHEMA
  Query _buildBaseQuery() {
    Query query = _firestore.collection('Orders');

    if (currentFilter.value != 'All') {
      if (currentFilter.value == 'WhatsApp') {
        query = query.where('source', isEqualTo: 'WhatsApp Direct');
      } else if (currentFilter.value == 'Website') {
        query = query.where('source', isEqualTo: 'Website Checkout');
      } else if (currentFilter.value == 'Pending') {
        // Collects BOTH website pending and WhatsApp pending
        query = query.where('status', whereIn: _pendingKeywords);
      } else {
        query = query.where('status', isEqualTo: currentFilter.value);
      }
    }

    return query.orderBy('createdAt', descending: true);
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isLoadingTable.value = true;
        _lastVisible = null;
        _pageStarts.clear();
        currentPage.value = 1;
        hasNextPage.value = true;
      }

      Query query = _buildBaseQuery().limit(_limit);
      if (_lastVisible != null) query = query.startAfterDocument(_lastVisible!);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        if (_pageStarts.length < currentPage.value) {
          _pageStarts.add(snapshot.docs.first);
        }
        _lastVisible = snapshot.docs.last;
        tableOrders.value =
            snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
        hasNextPage.value = snapshot.docs.length == _limit;
      } else {
        if (isRefresh) tableOrders.clear();
        hasNextPage.value = false;
      }
    } catch (e) {
      debugPrint("Fetch Orders Error: $e");
    } finally {
      isLoadingTable.value = false;
    }
  }

  void nextPage() {
    if (hasNextPage.value) {
      currentPage.value++;
      fetchOrders();
    }
  }

  void previousPage() async {
    if (currentPage.value > 1) {
      currentPage.value--;
      isLoadingTable.value = true;
      DocumentSnapshot startDoc = _pageStarts[currentPage.value - 1];

      QuerySnapshot snapshot =
          await _buildBaseQuery().startAtDocument(startDoc).limit(_limit).get();

      _lastVisible = snapshot.docs.last;
      tableOrders.value =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
      hasNextPage.value = true;
      isLoadingTable.value = false;
    }
  }

  Future<void> searchGlobalOrder(String searchId) async {
    if (searchId.trim().isEmpty) {
      fetchOrders(isRefresh: true);
      return;
    }
    try {
      isLoadingTable.value = true;
      currentFilter.value = 'All'; // Reset filter so search overrides it

      QuerySnapshot snapshot =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: searchId.trim())
              .get();
      tableOrders.value =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
      hasNextPage.value = false;
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      isLoadingTable.value = false;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
        ),
        barrierDismissible: false,
      );

      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        await doc.reference.delete();
      }

      tableOrders.removeWhere((o) => o['orderId'] == orderId);
      tableOrders.refresh();

      Get.back();
      _showSafeSnackbar(
        'Deleted',
        'Order #$orderId permanently deleted.',
        bgColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } catch (e) {
      Get.back();
      _showSafeSnackbar(
        'Error',
        'Failed to delete order.',
        bgColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> applyDiscount(
    String orderId,
    double originalTotal,
    double discountAmount,
  ) async {
    try {
      double newTotal = originalTotal - discountAmount;
      if (newTotal < 0) newTotal = 0;
      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        await doc.reference.update({
          'discount': discountAmount,
          'totalAmount': newTotal,
        });
      }
      int index = tableOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        tableOrders[index]['discount'] = discountAmount;
        tableOrders[index]['totalAmount'] = newTotal;
        tableOrders.refresh();
      }
      _showSafeSnackbar('Discount Applied', 'Subtotal updated.');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        // Updates BOTH so it merges WhatsApp and Website order structures naturally
        await doc.reference.update({
          'orderstatus': newStatus,
          'status': newStatus,
        });
      }
      int index = tableOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        tableOrders[index]['orderstatus'] = newStatus;
        tableOrders[index]['status'] = newStatus;
        tableOrders.refresh();
      }
      _showSafeSnackbar('Status Updated', 'Order #$orderId is now $newStatus');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateAdminFeedback(String orderId, String feedback) async {
    try {
      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        // 🚀 Handled the 'adminfeedback' vs 'adminFeedback' database naming conflict safely
        await doc.reference.update({
          'adminfeedback': feedback,
          'adminFeedback': feedback,
        });
      }
      int index = tableOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        tableOrders[index]['adminfeedback'] = feedback;
        tableOrders[index]['adminFeedback'] = feedback;
        tableOrders.refresh();
      }
      _showSafeSnackbar('Notes Saved', 'Private notes updated.');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 🚀 NEW: Update Customer Name & Phone (For WhatsApp Orders)
  Future<void> updateCustomerDetails(
    String orderId,
    String newName,
    String newPhone,
  ) async {
    try {
      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        await doc.reference.update({
          'customerName': newName,
          'customerPhone': newPhone,
        });
      }
      // Update the table locally so the UI updates instantly
      int index = tableOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        tableOrders[index]['customerName'] = newName;
        tableOrders[index]['customerPhone'] = newPhone;
        tableOrders.refresh();
      }
      _showSafeSnackbar(
        'Customer Updated',
        'Name and phone number saved successfully.',
      );
    } catch (e) {
      debugPrint(e.toString());
      _showSafeSnackbar(
        'Error',
        'Failed to update customer details.',
        bgColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  // 🚀 NEW: Update Order Addresses
  Future<void> updateOrderAddresses(
    String orderId,
    String newShipping,
    String newBilling,
  ) async {
    try {
      QuerySnapshot snap =
          await _firestore
              .collection('Orders')
              .where('orderId', isEqualTo: orderId)
              .get();
      for (var doc in snap.docs) {
        // This will create 'billingAddress' if it didn't exist before (like in WhatsApp orders)
        await doc.reference.update({
          'shippingAddress': newShipping,
          'billingAddress': newBilling,
        });
      }
      // Update the table locally
      int index = tableOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        tableOrders[index]['shippingAddress'] = newShipping;
        tableOrders[index]['billingAddress'] = newBilling;
        tableOrders.refresh();
      }
      _showSafeSnackbar(
        'Addresses Updated',
        'Shipping and Billing addresses saved successfully.',
      );
    } catch (e) {
      debugPrint(e.toString());
      _showSafeSnackbar(
        'Error',
        'Failed to update addresses.',
        bgColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }
}

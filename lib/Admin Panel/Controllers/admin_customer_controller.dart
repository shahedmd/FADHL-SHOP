import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  final RxString selectedDateRange = 'This Month'.obs;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void onInit() {
    super.onInit();
    _setDateRange('This Month');
    fetchCustomers(); 
  }

  void updateDateFilter(String range, {DateTimeRange? customRange}) {
    selectedDateRange.value = range;
    if (range == 'Custom Range' && customRange != null) {
      startDate = customRange.start;
      // Set end date to the very end of the selected day (23:59:59)
      endDate = DateTime(
        customRange.end.year,
        customRange.end.month,
        customRange.end.day,
        23,
        59,
        59,
      );
    } else {
      _setDateRange(range);
    }
    fetchCustomers();
  }

  void _setDateRange(String range) {
    DateTime now = DateTime.now();
    switch (range) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'Last 7 Days':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'Last 14 Days':
        startDate = now.subtract(const Duration(days: 14));
        endDate = now;
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case 'Last Month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
      case 'All Time':
        startDate = null;
        endDate = null;
        break;
    }
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      customers.clear();

      Query query = _firestore.collection('Orders');

      // Apply Date Filter if it's not "All Time"
      if (startDate != null && endDate != null) {
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!),
            )
            .where(
              'createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate!),
            );
      }

      QuerySnapshot snapshot = await query.get();

      // 🚀 AGGREGATE BY PHONE NUMBER
      Map<String, Map<String, dynamic>> groupedCustomers = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String phone = data['customerPhone']?.toString().trim() ?? 'Unknown';

        // Skip entirely broken records
        if (phone.isEmpty || phone == 'Unknown') continue;

        if (!groupedCustomers.containsKey(phone)) {
          groupedCustomers[phone] = {
            'phone': phone,
            'name': data['customerName'] ?? 'Unknown',
            'customerId': data['customerId'] ?? 'Guest',
            'totalOrders': 0,
            'totalSpent': 0.0,
            'ordersList': <Map<String, dynamic>>[], // Store all their orders!
          };
        }

        // Add this order's data to the customer's profile
        groupedCustomers[phone]!['totalOrders'] += 1;
        groupedCustomers[phone]!['totalSpent'] +=
            (data['totalAmount'] ?? 0).toDouble();
        groupedCustomers[phone]!['ordersList'].add(data);
      }

      // Convert Map to List and sort by Highest Spender
      List<Map<String, dynamic>> finalCustomers =
          groupedCustomers.values.toList();
      finalCustomers.sort((a, b) => b['totalSpent'].compareTo(a['totalSpent']));

      customers.value = finalCustomers;
    } catch (e) {
      debugPrint("Failed to fetch customers: $e");
      Get.snackbar(
        'Error',
        'Failed to load customer data.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

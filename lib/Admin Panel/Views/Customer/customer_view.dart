import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controllers/admin_customer_controller.dart';
import '../../Utils/global_colours.dart';

class AdminCustomerView extends StatelessWidget {
  final bool isDesktop;
  const AdminCustomerView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final AdminCustomerController customerController = Get.put(
      AdminCustomerController(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // 1. HEADER & DATE FILTER
        // ==========================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Insights',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.w900,
                      color: brandGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View top spenders and order histories.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

            // 🚀 DATE RANGE SELECTOR
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: customerController.selectedDateRange.value,
                    icon: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    items:
                        [
                              'Today',
                              'Last 7 Days',
                              'Last 14 Days',
                              'This Month',
                              'Last Month',
                              'This Year',
                              'All Time',
                              'Custom Range',
                            ]
                            .map(
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (newValue) async {
                      if (newValue == 'Custom Range') {
                        DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder:
                              (context, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: brandGreen,
                                  ),
                                ),
                                child: child!,
                              ),
                        );
                        if (picked != null) {
                          customerController.updateDateFilter(
                            'Custom Range',
                            customRange: picked,
                          );
                        }
                      } else if (newValue != null) {
                        customerController.updateDateFilter(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ==========================================
        // 2. DATA TABLE
        // ==========================================
        Obx(() {
          if (customerController.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFCEAB5F)),
              ),
            );
          }
          if (customerController.customers.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No customers found in this date range.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration:
                isDesktop
                    ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    )
                    : null,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customerController.customers.length,
              separatorBuilder:
                  (_, __) => Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (context, index) {
                final customer = customerController.customers[index];

                return ListTile(
                  contentPadding: EdgeInsets.all(isDesktop ? 16 : 8),
                  leading: CircleAvatar(
                    backgroundColor: brandGold.withValues(alpha: 0.2),
                    child: Text(
                      customer['name'].toString().substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(customer['phone'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳${customer['totalSpent'].toStringAsFixed(0)}',
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${customer['totalOrders']} Orders',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen.withValues(alpha: 0.1),
                          foregroundColor: brandGreen,
                          elevation: 0,
                        ),
                        onPressed: () => _showCustomerOrdersModal(customer),
                        child: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 3. CUSTOMER HISTORY MODAL
  // ==========================================
  void _showCustomerOrdersModal(Map<String, dynamic> customer) {
    List<dynamic> orders = customer['ordersList'] ?? [];

    // Sort their orders (Newest first)
    orders.sort((a, b) {
      Timestamp tA = a['createdAt'] ?? Timestamp.now();
      Timestamp tB = b['createdAt'] ?? Timestamp.now();
      return tB.compareTo(tA);
    });

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandGreen,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer['name']}\'s Orders',
                          style: TextStyle(
                            color: brandGold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${customer['phone']}  •  Total Spent: ৳${customer['totalSpent']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    String dateStr =
                        order['createdAt'] != null
                            ? DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format((order['createdAt'] as Timestamp).toDate())
                            : 'Unknown Date';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${order['orderId']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '৳${order['totalAmount']}',
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _statusBadge(
                            order['orderstatus'] ??
                                order['status'] ??
                                'Pending',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color statusColor = Colors.orange;
    if (status == 'Processing') statusColor = Colors.blue;
    if (status == 'Shipped') statusColor = Colors.purple;
    if (status == 'Delivered') statusColor = Colors.green;
    if (status == 'Cancelled') statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

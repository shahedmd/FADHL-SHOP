import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controllers/admin_order_controller.dart';
import '../../Utils/global_colours.dart'; // Ensure AppColors is inside this file
import 'order_processing_modal.dart';

class OrdersView extends StatelessWidget {
  final bool isDesktop;

  const OrdersView({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final adminOrderController = Get.find<AdminOrderManagementController>();
    final TextEditingController searchController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🚀 RESPONSIVE HEADER (Search + Filter Dropdown)
        _buildHeader(adminOrderController, searchController),

        const SizedBox(height: 20),

        // TABLE VIEW
        Obx(() {
          if (adminOrderController.isLoadingTable.value) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ), // Updated
            );
          }
          if (adminOrderController.tableOrders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  "No orders found matching this filter.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          return Container(
            padding:
                isDesktop ? const EdgeInsets.all(24) : const EdgeInsets.all(0),
            decoration:
                isDesktop
                    ? BoxDecoration(
                      color: AppColors.pureWhite, // Updated
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    )
                    : null,
            child: Column(
              children: [
                if (isDesktop) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Order ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Action',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
                ...adminOrderController.tableOrders.map((order) {
                  return Column(
                    children: [
                      isDesktop
                          ? _buildDesktopOrderRow(order, adminOrderController)
                          : _buildMobileOrderCard(order, adminOrderController),
                      if (isDesktop) const Divider(height: 1),
                      if (!isDesktop) const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
          );
        }),

        // PAGINATION BAR
        Obx(
          () => Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed:
                      adminOrderController.currentPage.value > 1
                          ? () => adminOrderController.previousPage()
                          : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 12),
                  label: const Text('Prev', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.05,
                    ), // Updated
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Page ${adminOrderController.currentPage.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryGreen, // Updated
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed:
                      adminOrderController.hasNextPage.value
                          ? () => adminOrderController.nextPage()
                          : null,
                  icon: const Text('Next', style: TextStyle(fontSize: 13)),
                  label: const Icon(Icons.arrow_forward_ios, size: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🚀 Helper Layout Functions for Clean Responsiveness
  Widget _buildHeader(
    AdminOrderManagementController controller,
    TextEditingController searchController,
  ) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildSearchBox(controller, searchController),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: _buildFilterBox(controller)),
          const SizedBox(width: 12),
          _buildSearchButton(controller, searchController),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBox(controller, searchController),
          const SizedBox(height: 12),
          _buildFilterBox(controller),
          const SizedBox(height: 12),
          _buildSearchButton(controller, searchController),
        ],
      );
    }
  }

  Widget _buildSearchBox(
    AdminOrderManagementController controller,
    TextEditingController searchController,
  ) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search exactly (e.g. ORD-12345)',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
            onPressed: () {
              searchController.clear();
              controller.fetchOrders(isRefresh: true);
            },
          ),
        ),
        onSubmitted: (val) => controller.searchGlobalOrder(val),
      ),
    );
  }

  Widget _buildFilterBox(AdminOrderManagementController controller) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            value: controller.currentFilter.value,
            isExpanded: true,
            icon: const Icon(Icons.filter_list, color: Colors.grey, size: 20),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Orders')),
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Processing', child: Text('Processing')),
              DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              DropdownMenuItem(value: 'Returned', child: Text('Returned')),
              DropdownMenuItem(
                value: 'WhatsApp',
                child: Text('WhatsApp Orders'),
              ),
              DropdownMenuItem(value: 'Website', child: Text('Website Orders')),
            ],
            onChanged: (val) {
              if (val != null) {
                controller.setFilter(val);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(
    AdminOrderManagementController controller,
    TextEditingController searchController,
  ) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen, // Updated
          foregroundColor: AppColors.primaryGold, // Updated
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => controller.searchGlobalOrder(searchController.text),
        child: const Text('Search'),
      ),
    );
  }

  Widget _buildDesktopOrderRow(
    Map<String, dynamic> order,
    AdminOrderManagementController adminController,
  ) {
    String dateStr = 'Just Now';
    if (order['createdAt'] != null) {
      dateStr = DateFormat(
        'dd MMM yyyy',
      ).format((order['createdAt'] as Timestamp).toDate());
    }
    final String orderId = order['orderId']?.toString() ?? 'Unknown';
    // Using num? fallback ensures int64 data correctly renders
    final num total = order['totalAmount'] as num? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '#$orderId',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textDark, // Updated
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateStr,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order['customerName'] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark, // Updated
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '৳${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primaryGreen, // Updated
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(
                order['status'] ?? order['orderstatus'] ?? 'Pending',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold, // Updated
                      foregroundColor: AppColors.primaryGreen, // Updated
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => openOrderProcessingModal(order),
                    icon: const Icon(Icons.edit_document, size: 14),
                    label: const Text(
                      'Manage',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Delete Order',
                  onPressed:
                      () => _confirmDeleteOrder(orderId, adminController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOrderCard(
    Map<String, dynamic> order,
    AdminOrderManagementController adminController,
  ) {
    final String orderId = order['orderId']?.toString() ?? 'Unknown';
    final num total = order['totalAmount'] as num? ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite, // Updated
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '#$orderId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark, // Updated
              ),
            ),
            Text(
              '৳${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.primaryGreen, // Updated
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['customerName'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark, // Updated
                ),
              ),
              _statusBadge(
                order['status'] ?? order['orderstatus'] ?? 'Pending',
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _confirmDeleteOrder(orderId, adminController),
        ),
        onTap: () => openOrderProcessingModal(order),
      ),
    );
  }

  void _confirmDeleteOrder(
    String orderId,
    AdminOrderManagementController adminController,
  ) {
    Get.defaultDialog(
      title: 'Delete Order?',
      middleText:
          'Are you sure you want to permanently delete order #$orderId?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        adminController.deleteOrder(orderId);
        Get.back();
      },
    );
  }

  Widget _statusBadge(String status) {
    Color statusColor = Colors.orange;

    if (status.contains('Processing')) statusColor = Colors.blue;
    if (status.contains('Shipped')) statusColor = Colors.purple;
    // Updated 'Delivered' to use your brand green
    if (status.contains('Delivered')) statusColor = AppColors.primaryGreen;
    if (status.contains('Cancelled')) statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

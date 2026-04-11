import 'package:fadhl/Controllers/authcontroller.dart';
import 'package:fadhl/Controllers/order_controller.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_bottomnavbar.dart';
import 'package:fadhl/Widgers/Reuseable/responsive_headermenu.dart';
import 'package:fadhl/Widgers/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color brandGreen = const Color(0xFF0A1F13);
  final Color brandGold = const Color(0xFFCEAB5F);

  @override
  void initState() {
    super.initState();
    // Fetch orders the second this screen opens!
    Get.find<OrderController>().fetchMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final OrderController orderController = Get.find<OrderController>();
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          CustomHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ResponsiveLayout(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 40.0,
                      ),
                      child: Obx(() {
                        // Security Check: If they log out, kick them to home!
                        if (authController.firebaseUser.value == null) {
                          Future.microtask(() => Get.offAllNamed('/'));
                          return const SizedBox.shrink();
                        }

                        return isDesktop
                            ? _buildDesktopLayout(
                              authController,
                              orderController,
                            )
                            : _buildMobileLayout(
                              authController,
                              orderController,
                            );
                      }),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CustomFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LAYOUTS
  // ==========================================
  Widget _buildDesktopLayout(
    AuthController authController,
    OrderController orderController,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Profile Card
        Expanded(flex: 3, child: _buildProfileCard(authController)),
        const SizedBox(width: 30),
        // Right Column: Order History
        Expanded(flex: 7, child: _buildOrderHistory(orderController)),
      ],
    );
  }

  Widget _buildMobileLayout(
    AuthController authController,
    OrderController orderController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileCard(authController),
        const SizedBox(height: 24),
        _buildOrderHistory(orderController),
      ],
    );
  }

  // ==========================================
  // 1. PROFILE DETAILS CARD
  // ==========================================
  Widget _buildProfileCard(AuthController authController) {
    final userData = authController.userData.value;
    final String name = userData?['name'] ?? 'Loading...';
    final String email =
        userData?['email'] ?? authController.firebaseUser.value?.email ?? '';
    final String phone = userData?['phone'] ?? 'No phone added';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: brandGreen.withValues(alpha:  0.1),
            child: FaIcon(
              FontAwesomeIcons.solidUser,
              color: brandGold,
              size: 35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          _profileInfoRow(Icons.email_outlined, email),
          const SizedBox(height: 16),
          _profileInfoRow(Icons.phone_outlined, phone),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => authController.logout(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: brandGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. ORDER HISTORY LIST
  // ==========================================
  Widget _buildOrderHistory(OrderController orderController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: brandGreen,
            ),
          ),
          const SizedBox(height: 24),

          Obx(() {
            if (orderController.isLoadingOrders.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: brandGold),
                ),
              );
            }

            if (orderController.myOrders.isEmpty) {
              return _buildEmptyOrders();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderController.myOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orderController.myOrders[index];
                return _buildOrderCard(order);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String orderId = order['orderId'] ?? 'Unknown';
    final double totalAmount = (order['totalAmount'] ?? 0).toDouble();
    final String status = order['orderstatus'] ?? order['status'] ?? 'Pending';
    final List items = order['items'] ?? [];

    // Format the date securely
    String dateStr = 'Recently';
    if (order['createdAt'] != null) {
      final DateTime date = (order['createdAt'] as Timestamp).toDate();
      dateStr = DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(date); // Requires `intl` package
    }

    // Status Color Logic
    Color statusColor = Colors.orange;
    if (status.toLowerCase().contains('delivered') ||
        status.toLowerCase().contains('completed')) {
      statusColor = Colors.green;
    }
    if (status.toLowerCase().contains('cancelled')) statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:  0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Placed on: $dateStr',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // List of items in this order
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    '${item['quantity']}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '৳${item['price']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '৳${totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: brandGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          FaIcon(
            FontAwesomeIcons.boxOpen,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "You haven't placed any orders yet.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: brandGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => Get.offAllNamed('/'),
            child: const Text(
              'Start Shopping',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
